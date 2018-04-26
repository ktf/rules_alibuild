workspace(name = "rules_alibuild")

git_repository(
    name = "io_bazel_rules_python",
    remote = "https://github.com/bazelbuild/rules_python.git",
    commit = "master",
)


load("//alibuild:alibuild.bzl", "alibuild_repository", "alidist_repository", "alibuild_package")

# For tests only
alibuild_repository(
  name = "alibuild",
  pip_version = "v1.5.3",
)

alidist_repository(
  name = "alidist",
  repo = "alisw/alidist",
  revision = "master",
  defaults_file = "//alibuild:defaults-bazel.sh"
)

alibuild_package(
  name = "zlib",
  alidist = "@alidist",
  alibuild = "@alibuild",
  defaults = "bazel"
)
alibuild_package(
  name = "UUID",
  alidist = "@alidist",
  alibuild = "@alibuild",
  defaults = "bazel"
)
