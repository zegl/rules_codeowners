load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//tools:codeowners.bzl", "codeowners", "generate_codeowners")
load("//tools:codeowners_test.bzl", "failure_testing_test")

generate_codeowners(
    name = "github_codeowners",
    global_owners = ["@global-1", "@global-2"],
    owners = [
        ":single_team",
        ":multi_pattern",
        ":already_global",
        ":opted_out",
        ":unowned",
        ":with_comment",
    ],
)

generate_codeowners(
    name = "github_codeowners_strict",
    global_owners = ["@global-1", "@global-2"],
    owners = [
        ":single_team",
        ":multi_pattern",
        ":already_global",
        ":opted_out",
        ":unowned",
        ":with_comment",
    ],
    validate = True,
)

codeowners(
    name = "single_team",
    pattern = "*.a",
    team = "@team-a",
)

codeowners(
    name = "multi_pattern",
    patterns = ["*.b1", "*.b2"],
    teams = ["@team-b1", "@team-b2"],
)

# A global owner that already owns the row is not added twice
codeowners(
    name = "already_global",
    pattern = "*.c",
    teams = ["@global-2", "@team-c"],
)

codeowners(
    name = "opted_out",
    pattern = "secret/",
    include_global_owners = False,
    team = "@security",
)

codeowners(
    name = "unowned",
    pattern = "*.generated",
    unowned = True,
)

codeowners(
    name = "with_comment",
    comment = "Docs",
    pattern = "*.md",
    team = "@docs",
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

# The rows of a nested generate_codeowners get the global owners, as their own include_global_owners says
generate_codeowners(
    name = "github_codeowners_nested",
    global_owners = ["@global-1", "@global-2"],
    owners = [
        ":single_team",
        ":nested_without_global_owners",
    ],
)

generate_codeowners(
    name = "nested_without_global_owners",
    owners = [
        ":multi_pattern",
        ":already_global",
        ":opted_out",
        ":unowned",
        ":with_comment",
    ],
)

sh_test(
    name = "validate_codeowners_nested",
    srcs = ["//tools:diff.sh"],
    args = [
        "$(location :github_codeowners_nested.out)",
        "$(location github_codeowners_golden)",
    ],
    data = [
        "github_codeowners_golden",
        ":github_codeowners_nested.out",
    ],
)

failure_testing_test(
    name = "nested_with_global_owners",
    expected = "A generate_codeowners with global_owners can not be nested in another generate_codeowners",
    target_under_test = ":nested_with_global_owners_rule",
)

generate_codeowners(
    name = "nested_with_global_owners_rule",
    owners = [":nested_global_owners"],
    tags = ["manual"],
)

generate_codeowners(
    name = "nested_global_owners",
    global_owners = ["@global"],
    owners = [":single_team"],
    tags = ["manual"],
)

# The fallback owners join the global owners in the "*" row only
generate_codeowners(
    name = "github_codeowners_fallback",
    fallback_owners = ["@fallback-b", "@global-2", "@fallback-a"],
    global_owners = ["@global-1", "@global-2"],
    owners = [
        ":single_team",
        ":nested_without_global_owners",
    ],
)

sh_test(
    name = "validate_codeowners_fallback",
    srcs = ["//tools:diff.sh"],
    args = [
        "$(location :github_codeowners_fallback.out)",
        "$(location github_codeowners_fallback_golden)",
    ],
    data = [
        "github_codeowners_fallback_golden",
        ":github_codeowners_fallback.out",
    ],
)

# Without global owners, the fallback owners are the only owners of the "*" row
generate_codeowners(
    name = "github_codeowners_only_fallback",
    fallback_owners = ["@fallback-b", "@fallback-a"],
    owners = [":single_team"],
)

sh_test(
    name = "validate_codeowners_only_fallback",
    srcs = ["//tools:diff.sh"],
    args = [
        "$(location :github_codeowners_only_fallback.out)",
        "$(location github_codeowners_only_fallback_golden)",
    ],
    data = [
        "github_codeowners_only_fallback_golden",
        ":github_codeowners_only_fallback.out",
    ],
)

failure_testing_test(
    name = "nested_with_fallback_owners",
    expected = "A generate_codeowners with fallback_owners can not be nested in another generate_codeowners",
    target_under_test = ":nested_with_fallback_owners_rule",
)

generate_codeowners(
    name = "nested_with_fallback_owners_rule",
    owners = [":nested_fallback_owners"],
    tags = ["manual"],
)

generate_codeowners(
    name = "nested_fallback_owners",
    fallback_owners = ["@fallback"],
    owners = [":single_team"],
    tags = ["manual"],
)

failure_testing_test(
    name = "unowned_and_not_include_global_owners",
    expected = "include_global_owners has no effect when unowned = True",
    target_under_test = ":unowned_and_not_include_global_owners_rule",
)

codeowners(
    name = "unowned_and_not_include_global_owners_rule",
    include_global_owners = False,
    tags = ["manual"],
    unowned = True,
)
