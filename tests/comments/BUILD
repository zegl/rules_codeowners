load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//tools:codeowners.bzl", "codeowners", "generate_codeowners")

generate_codeowners(
    name = "github_codeowners",
    owners = [
        ":no_comment",
        ":single_line_comment",
        ":multi_line_comment",
        "//tests/comments/nested:nested_codeowners",
    ],
)

generate_codeowners(
    name = "github_codeowners_strict",
    owners = [
        ":no_comment",
        ":single_line_comment",
        ":multi_line_comment",
        "//tests/comments/nested:nested_codeowners",
    ],
    validate = True,
)

codeowners(
    name = "no_comment",
    team = "@the-a-team",
)

codeowners(
    name = "single_line_comment",
    comment = "Owned by the B team",
    pattern = "*.b",
    team = "@the-b-team",
)

codeowners(
    name = "multi_line_comment",
    comment = """Owned by the C team

since they wrote it""",
    patterns = [
        "*.c1",
        "*.c2",
    ],
    team = "@the-c-team",
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
