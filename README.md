# rules_alibuild

Rules for importing aliBuild packages into Bazel.

## Rules

* [alidist_repository](#alidist_repository)
* [alibuild_repository](#alibuild_repository)
* [alibuild_package](#alibuild_package)

## Setup

Add the following to your `WORKSPACE` file, and select a `$COMMIT` accordingly.

```bzl
http_archive(
    name = "rules_alibuild",
    strip_prefix = "rules_alibuild-$COMMIT",
    urls = ["https://github.com/ktf/rules_alibuild/archive/$COMMIT.tar.gz"],
)

load("@rules_alibuild//alibuild:alibuild.bzl", "alibuild_repository", "alidist_repository", "alibuild_package")
```

## Example

```bzl
alidist_repository(
    name="alidist"
    repo="alisw/alidist",
    revision = "master", # Any tag or commit hash
)

alibuild_package(
    name = "ROOT",
    repository = "@alidist",
    defaults = "o2"
)
```

## Rules

### alibuild_repository

Name a specific revision of alibuild or a local checkout.

```bzl
alibuild_repository(name, pip_version, repo, path, version, stripPrefix)
```

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <p><code>Name; required</code></p>
        <p>A unique name for this target</p>
      </td>
    </tr>
    <tr>
      <td><code>revision</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>Git commit hash or tag identifying the version of alibuild
           to use.</p>
      </td>
    </tr>
  </tbody>
</table>

### alidist_repository

Name a specific revision of alidist on GitHub or a local checkout.

```bzl
alidist_repository(name, repo, revision, defaults_file, defaults_file_content)
```

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <p><code>Name; required</code></p>
        <p>A unique name for this target</p>
      </td>
    </tr>
    <tr>
      <td><code>revision</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>Git commit hash or tag identifying the version of alidist
           to use.</p>
      </td>
    </tr>
  </tbody>
</table>

### alibuild_package

Make the content of a alibuild built package available in the Bazel workspace.

```bzl
alibuild_package(name, attribute_path, nix_file, nix_file_content,
                 path, repository, build_file, build_file_content)
```

If neither `repository` or `path` are specified, `<nixpkgs>` is
assumed. Specifying one of `repository` or `path` is strongly
recommended. The two are mutually exclusive.

<table class="table table-condensed table-bordered table-params">
  <colgroup>
    <col class="col-param" />
    <col class="param-description" />
  </colgroup>
  <thead>
    <tr>
      <th colspan="2">Attributes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>name</code></td>
      <td>
        <p><code>Name; required</code></p>
        <p>A unique name for this target</p>
      </td>
    </tr>
    <tr>
      <td><code>attribute_path</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>Select an attribute from the top-level Nix expression being
           evaluated. The attribute path is a sequence of attribute
           names separated by dots.</p>
      </td>
    </tr>
    <tr>
      <td><code>nix_file</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>A file containing an expression for a Nix derivation.</p>
      </td>
    </tr>
    <tr>
      <td><code>nix_file_content</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>An expression for a Nix derivation.</p>
      </td>
    </tr>
    <tr>
      <td><code>repository</code></td>
      <td>
        <p><code>Label; optional</code></p>
        <p>A Nixpkgs repository label. Specify one of `path` or
		   `repository`.</p>
      </td>
    </tr>
    <tr>
      <td><code>path</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>The path to the directory containing Nixpkgs, as
           interpreted by `nix-build`. Specify one of `path` or
		   `repository`.</p>
      </td>
    </tr>
    <tr>
      <td><code>build_file</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>The file to use as the BUILD file for this repository. This
           attribute is a label relative to the main workspace. The
           file does not need to be named BUILD, but can be.</p>
      </td>
    </tr>
    <tr>
      <td><code>build_file_content</code></td>
      <td>
        <p><code>String; optional</code></p>
        <p>The content for the BUILD file for this repository.</p>
      </td>
    </tr>
  </tbody>
</table>

# Thanks

Adapted to alibuild starting from [rules_nixpkgs](https://github.com/tweag/rules_nixpkgs).
