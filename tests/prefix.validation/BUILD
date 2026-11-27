load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//tools:codeowners.bzl", "generate_codeowners")

# Rows that contain the package path, but don't start with it, or only match it
# when "." is read as a regex wildcard. Strict validation must skip them.
write_file(
    name = "rows",
    out = "rows.txt",
    content = [
        "/tests/prefix.validation/ @the-ok-team",
        "/evil/tests/prefix.validation/ @the-evil-team",
        "/tests/prefixXvalidation/ @the-evil-team",
        "",
    ],
)

generate_codeowners(
    name = "github_codeowners_strict",
    owners = [":rows"],
    validate = True,
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
