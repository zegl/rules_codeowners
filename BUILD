load("//tools:codeowners.bzl", "codeowners", "generate_codeowners")

codeowners(
    name = "wildcard",
    pattern = "*",
    team = "@zegl",
)

generate_codeowners(
    name = "generate_codeowners",
    owners = [
        ":wildcard",
    ],
)

sh_test(
    name = "validate_codeowoners_up_to_date",
    srcs = ["//tools:diff.sh"],
    args = [
        "$(location :generate_codeowners.out)",
        "$(location CODEOWNERS)",
    ],
    data = [
        "CODEOWNERS",
        ":generate_codeowners.out",
    ],
)

sh_test(
    name = "stardoc_up_to_date",
    srcs = ["//tools:diff.sh"],
    args = [
        "$(location //tools:docs.md)",
        "$(location README_DOCS.md)",
    ],
    data = [
        "README_DOCS.md",
        "//tools:docs.md",
    ],
)
