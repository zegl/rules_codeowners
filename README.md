# rules_codeowners

Use Bazel to create GitHub CODEOWNERS.

Add something like this to BUILD files in your WORKSPACE.

```bzl
load("//tools:codeowners.bzl", "codeowners")

codeowners(
    name = "codeowners",
    team = "@org/foo2",
    visibility = ["//visibility:public"],
)
```

And something like this to the root BUILD file, to tie it all together, the list
of all codeowners files can be generated with a Bazel query: `bazel query 'kind(codeowners, //...)'`

```bzl
load("//tools:codeowners.bzl", "generate_codeowners")

generate_codeowners(
    name = "codeowners",
    owners = [
        "//test/hey/sub:codeowners",
        "//test/hey:codeowners",
        "//test/heyoo:codeowners",
    ],
)
```

The `generate_codeowners` rule (`//:codeowners`), can be built with Bazel to create
the complete CODEOWNERS file, the generated file will be located at `bazel-bin/codeowners` by default.

`bazel build //:codeowners`
