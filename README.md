# rules_codeowners

Use Bazel to create GitHub CODEOWNERS.

CODEOWNERS on GitHub is flawed in the way that there can only be one CODEOWNERS file.

`rules_codeowners` allows you to define the CODEOWNERS at all levels in the repo, and then generating the final CODEOWNERs file.

## Usage

_See also: [README_DOCS.md](https://github.com/zegl/rules_codeowners/blob/master/README_DOCS.md)_

In the WORKSPACE:

There are currently no releases, use a commit of your choice as the version.

```bzl
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

RULES_CODEOWNERS_VERSION = "de6749190dcc5209427799b1e9777f79ab623702"
RULES_CODEOWNERS_SHA = "9277d41fefe2eded54ab1d3eeaebbef9ad28713291373a635079868980c6ead0"

http_archive(
    name = "rules_codeowners",
    strip_prefix = "rules_codeowners-%s" % RULES_CODEOWNERS_VERSION,
    sha256 = RULES_CODEOWNERS_SHA,
    url = "https://github.com/zegl/rules_codeowners/archive/%s.zip" % RULES_CODEOWNERS_VERSION,
)
```

In BUILD files:

```bzl
load("@rules_codeowners//tools:codeowners.bzl", "codeowners", "generate_codeowners")

# Define one or many codeowners, should be added at multiple levels in the repo
codeowners(
    name = "team_rule",

    # Set either team or teams to assign the GitHub team ownership
    team = "@org/foo",
    # teams = ["@org/team1", "@org/team2"],

    visibility = ["//visibility:public"],

    # Optional rules below
    pattern = "*.js", # Adds pattern to the end of the path if this rule label is
                      # //foo/bar:codeowner, this would create an entry for /foo/bar/*.js

    patterns = ["*.js", "*.ts"] # Same as pattern, but generates multiple rows, one for each pattern.
                                # Only one of pattern and patterns can be set at the same time.
)

# The generate_codeowners rule ties together multiple codeowners (and generate_codeowners) rules, and
# generates the final CODEOWNERS file.
#
# A generate_codeowners can use another generate_codeowners in the `owners` list,
# to effectively delegate access to modify the CODOWNERS in a part of the code-tree.
generate_codeowners(
    name = "generate_codeowners",
    owners = [
        ":team_rule",
    ],
)
```


The `generate_codeowners` rule (`//:generate_codeowners`), can be built with Bazel to create
the complete CODEOWNERS file, the generated file will be located at `bazel-bin/generate_codeowners.out` by default.

```bash
bazel build //:generate_codeowners
```

## Making sure that the CODEOWNERS is up to date

It's not possible for Bazel to output files to the workspace, but it _is_ possible to compare the current CODEOWNERS
with the generated version, to remind you that it's out of date with a `sh_test`.


```bzl
sh_test(
    name = "validate_codeowoners_up_to_date",
    srcs = ["@rules_codeowners//tools:diff.sh"],
    args = [
        "$(location :generate_codeowners.out)",
        "$(location CODEOWNERS)",
    ],
    data = [
        "CODEOWNERS",
        ":generate_codeowners.out",
    ],
)
```
