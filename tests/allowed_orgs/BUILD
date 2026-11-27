load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//tools:codeowners.bzl", "codeowners", "generate_codeowners")
load("//tools:codeowners_test.bzl", "failure_testing_test")

# Teams in the allowed orgs, compared case insensitively, users and email addresses
generate_codeowners(
    name = "github_codeowners",
    allowed_orgs = ["my-org"],
    fallback_owners = ["@My-Org/maintainers"],
    global_owners = ["@my-org/admins"],
    owners = [
        ":allowed",
        ":nested",
    ],
)

codeowners(
    name = "allowed",
    teams = [
        "@my-org/team",
        "@MY-ORG/other-team",
        "@some-user",
        "someone@example.com",
    ],
)

generate_codeowners(
    name = "nested",
    owners = [":allowed_nested"],
)

codeowners(
    name = "allowed_nested",
    pattern = "nested/",
    team = "@my-org/nested-team",
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

codeowners(
    name = "other_org",
    pattern = "*.other",
    teams = [
        "@my-org/team",
        "@other-org/team",
    ],
    tags = ["manual"],
)

failure_testing_test(
    name = "team_in_other_org",
    expected = "//tests/allowed_orgs:other_org: @other-org/team is a team outside the allowed_orgs",
    target_under_test = ":team_in_other_org_rule",
)

generate_codeowners(
    name = "team_in_other_org_rule",
    allowed_orgs = ["my-org"],
    owners = [":other_org"],
    tags = ["manual"],
)

# The rows of nested generate_codeowners are checked too
failure_testing_test(
    name = "nested_team_in_other_org",
    expected = "//tests/allowed_orgs:other_org: @other-org/team is a team outside the allowed_orgs",
    target_under_test = ":nested_team_in_other_org_rule",
)

generate_codeowners(
    name = "nested_team_in_other_org_rule",
    allowed_orgs = ["my-org"],
    owners = [":nested_other_org"],
    tags = ["manual"],
)

generate_codeowners(
    name = "nested_other_org",
    owners = [":other_org"],
    tags = ["manual"],
)

failure_testing_test(
    name = "global_owner_in_other_org",
    expected = "@other-org/admins is a team outside the allowed_orgs",
    target_under_test = ":global_owner_in_other_org_rule",
)

generate_codeowners(
    name = "global_owner_in_other_org_rule",
    allowed_orgs = ["my-org"],
    global_owners = ["@other-org/admins"],
    owners = [":allowed"],
    tags = ["manual"],
)

failure_testing_test(
    name = "fallback_owner_in_other_org",
    expected = "@other-org/maintainers is a team outside the allowed_orgs",
    target_under_test = ":fallback_owner_in_other_org_rule",
)

generate_codeowners(
    name = "fallback_owner_in_other_org_rule",
    allowed_orgs = ["my-org"],
    fallback_owners = ["@other-org/maintainers"],
    owners = [":allowed"],
    tags = ["manual"],
)

# An owner that is not a user, a team or an email address fails, with or without allowed_orgs
failure_testing_test(
    name = "owner_without_at",
    expected = "team must be a GitHub user or team starting with @, or an email address, got \"my-org/team\"",
    target_under_test = ":owner_without_at_rule",
)

codeowners(
    name = "owner_without_at_rule",
    tags = ["manual"],
    team = "my-org/team",
)

failure_testing_test(
    name = "owner_with_space",
    expected = "team must be a GitHub user or team starting with @, or an email address, got \"@my-org/team @other\"",
    target_under_test = ":owner_with_space_rule",
)

codeowners(
    name = "owner_with_space_rule",
    tags = ["manual"],
    team = "@my-org/team @other",
)
