load("//tools:codeowners.bzl", "codeowners", "generate_codeowners")

generate_codeowners(
    name = "github_codeowners",
    owners = [
        ":sub_1",
        ":not_nested",
        "//tests/nested_codeowners/nested:sub_codeowners",
    ],
)

generate_codeowners(
    name = "sub_1",
    owners = [
        ":py_files",
        ":multi_team",
    ]
)

codeowners(
    name = "py_files",
    pattern = "*.py",
    team = "@the-python-dev",
)

codeowners(
    name = "multi_team",
    pattern = "*.html",
    teams = [
        "@the-css-team",
        "@the-html-team",
    ],
)

codeowners(
    name = "not_nested",
    pattern = "BUILD",
    team = "@not-nested-team",
)

sh_test(
    name = "validate_codeowners",
    srcs = ["//tools:diff.sh"],
    args = [
        "$(location :github_codeowners.out)",
        "$(location github_codeowners_golden)",
    ],
    data = [
        "github_codeowners_golden",
        ":github_codeowners.out",
    ],
)
