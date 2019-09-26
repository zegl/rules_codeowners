load("//tools:codeowners.bzl", "codeowners", "generate_codeowners")
load("//tools:codeowners_test.bzl", "failure_testing_test")

generate_codeowners(
    name = "github_codeowners",
    owners = [
        ":a",
        ":b",
        ":c",
    ],
    global_owners = "@epic-team",
)

codeowners(
    name = "a",
    pattern = "*.a",
    team = "@team-a",
)

codeowners(
    name = "b",
    pattern = "*.b",
    team = "@team-b",
    include_global_owners = False,
)

codeowners(
    name = "c",
    pattern = "*.c",
    team = "@team-c",
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
