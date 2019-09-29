load("//tools:codeowners.bzl", "codeowners", "generate_codeowners")
load("//tools:codeowners_test.bzl", "failure_testing_test")

generate_codeowners(
    name = "github_codeowners",
    owners = [
        "//tests/hey/sub:codeowners",
        "//tests/hey:codeowners",
        "//tests/heyoo:codeowners",
        ":single_pattern_single_team",
        ":single_pattern_multi_team",
        ":multi_pattern_single_team",
        ":multi_pattern_multi_team",
        ":no_pattern_single_team",
        ":no_pattern_multi_team",
    ],
)

codeowners(
    name = "single_pattern_single_team",
    pattern = "*.a",
    team = "@the-a-team",
)

codeowners(
    name = "single_pattern_multi_team",
    pattern = "*.b",
    teams = ["@the-b1-team", "@the-b2-team"],
)

codeowners(
    name = "multi_pattern_single_team",
    patterns = ["*.c1", "c*2"],
    team = "@the-c-team",
)

codeowners(
    name = "multi_pattern_multi_team",
    patterns = ["*.d1", "d*2"],
    teams = ["@the-d1-team", "@the-d2-team"],
)

codeowners(
    name = "no_pattern_single_team",
    team = "@the-e-team",
)

codeowners(
    name = "no_pattern_multi_team",
    teams = ["@the-f1-team", "@the-f2-team"],
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


failure_testing_test(
    name = "both_pattern_and_patterns",
    expected = "Both pattern and patterns can not be set at the same time.",
    target_under_test = ":both_pattern_and_patterns_set_rule",
)

codeowners(
    name = "both_pattern_and_patterns_set_rule",
    tags = ["manual"],
    team = "@foo",
    pattern = "foo",
    patterns = ["bar", "baz"],
)