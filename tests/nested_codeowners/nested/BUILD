load("//tools:codeowners.bzl", "codeowners", "generate_codeowners")

generate_codeowners(
    name = "sub_codeowners",
    owners = [
        ":codeowners",
    ],
    visibility = ["//tests/nested_codeowners:__pkg__"],
)

codeowners(
    name = "codeowners",
    team = "@the-nested-devs",
)
