load("//tools:codeowners.bzl", "codeowners", "generate_codeowners")

# Its header is left out of the CODEOWNERS that includes it, its comments are kept
generate_codeowners(
    name = "nested_codeowners",
    owners = [
        ":first",
        ":second",
    ],
    visibility = ["//tests/comments:__pkg__"],
)

codeowners(
    name = "first",
    comment = "Nested",
    team = "@the-nested-team",
)

codeowners(
    name = "second",
    pattern = "*.d",
    team = "@the-d-team",
)
