load("//tools:codeowners.bzl", "codeowners", "generate_codeowners")
load("//tools:codeowners_test.bzl", "failure_testing_test")

generate_codeowners(
    name = "github_codeowners",
    owners = [
        "//tests/hey/sub:codeowners",
        "//tests/hey:codeowners",
        "//tests/heyoo:codeowners",
        ":py_files",
        ":multi_team",
    ],
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

failure_testing_test(
    name = "both_team_and_teams_set",
    expected = "Both team and teams can not be set at the same time.",
    target_under_test = ":both_team_and_teams_set_rule",
)

codeowners(
    name = "both_team_and_teams_set_rule",
    tags = ["manual"],
    team = "@foo",
    teams = [
        "@the-css-team",
        "@the-html-team",
    ],
)

failure_testing_test(
    name = "neither_team_nor_teams_set",
    expected = "Either team or teams must be set.",
    target_under_test = ":neither_team_nor_teams_set_rule",
)

codeowners(
    name = "neither_team_nor_teams_set_rule",
    tags = ["manual"],
)
