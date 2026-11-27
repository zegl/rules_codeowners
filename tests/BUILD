load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@rules_shell//shell:sh_test.bzl", "sh_test")
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
        ":single_pattern_unowned",
        ":multi_pattern_unowned",
    ],
)

generate_codeowners(
    name = "github_codeowners_strict",
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
        ":single_pattern_unowned",
        ":multi_pattern_unowned",
    ],
    validate=True,
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

codeowners(
    name = "single_pattern_unowned",
    pattern = "*.generated",
    unowned = True,
)

codeowners(
    name = "multi_pattern_unowned",
    patterns = ["*.lock", "vendor/"],
    unowned = True,
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

sh_test(
    name = "validate_codeowners_strict",
    srcs = ["//tools:diff.sh"],
    args = [
        "$(location :github_codeowners_strict.out)",
        "$(location github_codeowners_golden)",
    ],
    data = [
        "github_codeowners_golden",
        ":github_codeowners_strict.out",
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
    expected = "Either team or teams must be set, or unowned = True.",
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
failure_testing_test(
    name = "unowned_and_team_set",
    expected = "unowned can not be combined with team or teams.",
    target_under_test = ":unowned_and_team_set_rule",
)

codeowners(
    name = "unowned_and_team_set_rule",
    tags = ["manual"],
    team = "@foo",
    unowned = True,
)

failure_testing_test(
    name = "unowned_and_teams_set",
    expected = "unowned can not be combined with team or teams.",
    target_under_test = ":unowned_and_teams_set_rule",
)

codeowners(
    name = "unowned_and_teams_set_rule",
    tags = ["manual"],
    teams = ["@foo", "@bar"],
    unowned = True,
)

# The header must be written verbatim, never evaluated by the shell.
generate_codeowners(
    name = "github_codeowners_shell_metachars_comment",
    generated_comment = "# Run `mise run codeowners` $(touch /tmp/pwned) $HOME \"quoted\" 'single' \\n",
    owners = [
        "//tests/hey:codeowners",
    ],
)

sh_test(
    name = "validate_codeowners_shell_metachars_comment",
    srcs = ["//tools:diff.sh"],
    args = [
        "$(location :github_codeowners_shell_metachars_comment.out)",
        "$(location github_codeowners_shell_metachars_comment_golden)",
    ],
    data = [
        "github_codeowners_shell_metachars_comment_golden",
        ":github_codeowners_shell_metachars_comment.out",
    ],
)

# Only codeowners and generate_codeowners can be owners, their rows are known when the build is analysed
failure_testing_test(
    name = "plain_file_owner",
    expected = "does not have mandatory providers: 'CodeownersInfo'",
    target_under_test = ":plain_file_owner_rule",
)

generate_codeowners(
    name = "plain_file_owner_rule",
    owners = [":plain_file"],
    tags = ["manual"],
)

write_file(
    name = "plain_file",
    out = "plain_file.txt",
    content = ["/tests/ @the-a-team"],
    tags = ["manual"],
)

# A "#" would turn the rest of the row into a comment
failure_testing_test(
    name = "hash_in_pattern",
    expected = "pattern can not contain a # or a newline",
    target_under_test = ":hash_in_pattern_rule",
)

codeowners(
    name = "hash_in_pattern_rule",
    pattern = "#notes.md",
    tags = ["manual"],
    team = "@the-a-team",
)
