load("//tools:codeowners.bzl", "generate_codeowners", "codeowners")

generate_codeowners(
    name = "github_codeowners",
    owners = [
        "//tests/hey/sub:codeowners",
        "//tests/hey:codeowners",
        "//tests/heyoo:codeowners",
        ":py_files",
    ],
)

codeowners(
    name = "py_files",
    pattern = "*.py",
    team = "@the-python-dev",
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

generate_codeowners(
    name = "github_codeowners_other_order",
    owners = [
        "//tests/hey:codeowners",
        "//tests/hey/sub:codeowners",
        "//tests/heyoo:codeowners",
    ],
)

sh_test(
    name = "validate_codeowners_other_order",
    srcs = ["//tools:diff.sh"],
    args = [
        "$(location :github_codeowners_other_order.out)",
        "$(location github_codeowners_other_order_golden)",
    ],
    data = [
        "github_codeowners_other_order_golden",
        ":github_codeowners_other_order.out",
    ],
)
