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
