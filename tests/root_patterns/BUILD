load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//tools:codeowners.bzl", "codeowners", "generate_codeowners")
load("//tools:codeowners_test.bzl", "failure_testing_test")

generate_codeowners(
    name = "github_codeowners",
    global_owners = ["@global"],
    owners = [
        ":package",
        ":root_paths",
    ],
)

codeowners(
    name = "package",
    team = "@the-a-team",
)

# Rows for files outside the package, anchored at the root of the repository
codeowners(
    name = "root_paths",
    comment = "Outside the package",
    patterns = [
        "//dashboards/root_patterns/",
        "//docs/threat-models/root_patterns.yaml",
        "*.go",
    ],
    team = "@the-a-team",
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

# A // pattern inside the package is allowed by validate
generate_codeowners(
    name = "github_codeowners_strict",
    owners = [":inside_package"],
    validate = True,
)

codeowners(
    name = "inside_package",
    pattern = "//tests/root_patterns/sub/",
    team = "@the-a-team",
)

sh_test(
    name = "validate_codeowners_strict",
    srcs = ["//tools:diff.sh"],
    args = [
        "$(location :github_codeowners_strict.out)",
        "$(location github_codeowners_strict_golden)",
    ],
    data = [
        "github_codeowners_strict_golden",
        ":github_codeowners_strict.out",
    ],
)

failure_testing_test(
    name = "outside_package_with_validate",
    expected = "writes the row /dashboards/root_patterns/, which is outside its package /tests/root_patterns/",
    target_under_test = ":outside_package_with_validate_rule",
)

generate_codeowners(
    name = "outside_package_with_validate_rule",
    owners = [":root_paths"],
    tags = ["manual"],
    validate = True,
)

# validate checks the rows of nested generate_codeowners too
failure_testing_test(
    name = "nested_outside_package_with_validate",
    expected = "writes the row /dashboards/root_patterns/, which is outside its package /tests/root_patterns/",
    target_under_test = ":nested_outside_package_with_validate_rule",
)

generate_codeowners(
    name = "nested_outside_package_with_validate_rule",
    owners = [":nested"],
    tags = ["manual"],
    validate = True,
)

generate_codeowners(
    name = "nested",
    owners = [":root_paths"],
    tags = ["manual"],
)
