"""Rules for importing alibuild packages."""


def _alibuild_repository_impl(ctx):
  ctx.file('BUILD')
  # XXX Hack because ctx.path below bails out if resolved path not a regular file.
  ctx.file(ctx.name)
  stripPrefix = ctx.attr.stripPrefix
  if stripPrefix == None:
    stripPrefix = "alibuild-" + ctx.attr.revision
  if ctx.attr.pip_version and ctx.attr.repo:
    fail("'pip_version' and 'repo' fields are mutually exclusive.")
  if ctx.attr.repo:
    ctx.download_and_extract(
      url = "https://github.com/%s/archive/%s.tar.gz" % (
          ctx.attr.repo,
          ctx.attr.version
          ),
      stripPrefix=stripPrefix
    )
  install_path = ctx.path("")
  if ctx.attr.repo:
    ctx.execute(["pip", "install", "-e", ".", "-t", install_path])
  elif ctx.attr.pip_version:
    pip = ctx.which("pip")
    command = [pip, "install", "alibuild==%s" % ctx.attr.pip_version, "-t", install_path, "--upgrade"]
    print(command)
    ctx.execute(command)

alibuild_repository = repository_rule(
  implementation = _alibuild_repository_impl,
  attrs = {
    "pip_version": attr.string(),
    "repo": attr.string(),
    "path": attr.string(),
    "version": attr.string(),
    "stripPrefix": attr.string(),
  },
  local = False,
)

def _alidist_repository_impl(ctx):
  if ctx.attr.defaults_file and ctx.attr.defaults_file_content:
    fail("Specify one of 'defaults_file' or 'defaults_file_content', but not both.")
  elif ctx.attr.defaults_file:
    ctx.symlink(ctx.attr.defaults_file, "defaults-bazel.sh")
  elif ctx.attr.defaults_file_content:
    ctx.file("defaults-bazel.sh", content = ctx.attr.defaults_file_content)
  else:
    pass
  ctx.file('BUILD')
  # XXX Hack because ctx.path below bails out if resolved path not a regular file.
  ctx.file(ctx.name)
  ctx.download_and_extract(
    url = "https://github.com/%s/archive/%s.tar.gz" % (
        ctx.attr.repo,
        ctx.attr.revision
        ),
    stripPrefix = "alidist-" + ctx.attr.revision,
  )

alidist_repository = repository_rule(
  implementation = _alidist_repository_impl,
  attrs = {
    "repo": attr.string(),
    "revision": attr.string(),
    "defaults_file": attr.label(),
    "defaults_file_content": attr.string()
  },
  local = False,
)

def _alibuild_package_impl(ctx):
  if ctx.attr.build_file and ctx.attr.build_file_content:
    fail("Specify one of 'build_file' or 'build_file_content', but not both.")
  elif ctx.attr.build_file:
    ctx.symlink(ctx.attr.build_file, "BUILD")
  elif ctx.attr.build_file_content:
    ctx.file("BUILD", content = ctx.attr.build_file_content)
  else:
    ctx.template("BUILD", Label("@rules_alibuild//alibuild:BUILD.pkg"))

  # We support either downloading alidist or passing a path to it
  path = []
  if ctx.attr.alidist and ctx.attr.alidist_path:
    fail("'alidist' and 'alidist_path' fields are mutually exclusive.")
  if ctx.attr.alidist:
    # XXX Another hack: the repository label typically resolves to
    # some top-level package in the external workspace. So we use
    # dirname to get the actual workspace path.
    path = ["-c", "{0}".format(ctx.path(ctx.attr.alidist).dirname)]
  if ctx.attr.alidist_path:
    path = ["-c", "{0}".format(ctx.attr.alidist_path)]

  package = ctx.attr.name
  if ctx.attr.package:
    package = ctx.attr.package

  alibuild_path = "{0}/bin/aliBuild".format(ctx.path(ctx.attr.alibuild).dirname)
  if alibuild_path == None:
    fail("Could not find %s. Please add it via alibuild_repository to your WORKSPACE." %(ctx.attr.alibuild))

  alibuild_defaults = ctx.attr.defaults
  if not alibuild_defaults:
    alibuild_defaults = "release"

  install_path = ctx.path("").dirname
  alibuild_build = [alibuild_path, "build"] + path + [package] + ["-w", install_path] + ["-z", "bazel", "--debug"] + ["--defaults", alibuild_defaults]
  print("%s" % alibuild_build)

  # Large enough integer that Bazel can still parse. We don't have
  # access to MAX_INT and 0 is not a valid timeout so this is as good
  # as we can do.
  timeout = 1073741824
  res = ctx.execute(alibuild_build, quiet = False, timeout = timeout)
  #if res.return_code == 0:
  #  output_path = res.stdout.splitlines()[-1]
  #else:
  #  fail("Cannot build alibuild package %s." % ctx.attr.name)
  #print(output_path)
  output_path = "%s/osx_x86-64/%s/latest-bazel-%s" % (install_path, package, alibuild_defaults)

  # Build a forest of symlinks (like new_local_package() does) to the
  # Nix store.

  find_path = ctx.which("find")
  if find_path == None:
    fail("Could not find the 'find' command. Please ensure it is in your PATH.")

  find_command = [find_path, "-L", output_path, "-maxdepth", "1"]
  print(find_command)
  res = ctx.execute(find_command)
  if res.return_code == 0:
    for i in res.stdout.splitlines():
      basename = i.rpartition("/")[-1]
      ctx.symlink(i, ctx.path(basename))
  else:
    fail(res.stderr)

alibuild_package = repository_rule(
  implementation = _alibuild_package_impl,
  attrs = {
    "package": attr.string(),
    "defaults": attr.string(),
    "alidist": attr.label(),
    "alidist_path": attr.string(),
    "alibuild": attr.label(),
    "alibuild_path": attr.string(),
    "build_file": attr.label(),
    "build_file_content": attr.string()
  },
  local = True,
  environ = [],
)
