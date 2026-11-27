load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//tools:codeowners.bzl", "generate_codeowners")

# Each file below holds one valid row for this package, followed by rows that
# strict validation must skip. A row is valid only if it starts with
# "/tests/prefix.validation/". The valid row keeps the file from failing the
# build, which happens when no row in a file matches.

# Rows that start with the package path.
write_file(
    name = "valid",
    out = "valid.txt",
    content = [
        "/tests/prefix.validation/ @the-ok-team",
        "/tests/prefix.validation/*.go @the-go-team",
        "/tests/prefix.validation/sub/ @the-sub-team",
        "/tests/prefix.validation/**/*.md @the-docs-team",
        "",
    ],
)

# Rows that contain the package path, but don't start with it.
write_file(
    name = "contains_package_path",
    out = "contains_package_path.txt",
    content = [
        "/tests/prefix.validation/a @the-ok-team",
        "/evil/tests/prefix.validation/ @the-evil-team",
        "/evil/tests/prefix.validation/*.go @the-evil-team",
        "**/tests/prefix.validation/ @the-evil-team",
        "",
    ],
)

# Rows that only match if the "." in the package path is read as a regex
# wildcard.
write_file(
    name = "dot_as_wildcard",
    out = "dot_as_wildcard.txt",
    content = [
        "/tests/prefix.validation/b @the-ok-team",
        "/tests/prefixXvalidation/ @the-evil-team",
        "/tests/prefix-validation/ @the-evil-team",
        "/tests/prefix/validation/ @the-evil-team",
        "",
    ],
)

# Rows for a sibling package whose name starts with this package's name.
write_file(
    name = "sibling_package",
    out = "sibling_package.txt",
    content = [
        "/tests/prefix.validation/c @the-ok-team",
        "/tests/prefix.validation2/ @the-evil-team",
        "/tests/prefix.validation-other/ @the-evil-team",
        "/tests/prefix.validation @the-evil-team",
        "",
    ],
)

# Rows for a parent directory or the whole repository.
write_file(
    name = "parent_directory",
    out = "parent_directory.txt",
    content = [
        "/tests/prefix.validation/d @the-ok-team",
        "/tests/ @the-evil-team",
        "/tests/* @the-evil-team",
        "/ @the-evil-team",
        "* @the-evil-team",
        "",
    ],
)

# Rows without a leading "/". GitHub matches these anywhere in the repository.
write_file(
    name = "not_anchored",
    out = "not_anchored.txt",
    content = [
        "/tests/prefix.validation/e @the-ok-team",
        "tests/prefix.validation/ @the-evil-team",
        "prefix.validation/ @the-evil-team",
        "*.md @the-evil-team",
        "",
    ],
)

generate_codeowners(
    name = "github_codeowners_strict",
    owners = [
        ":valid",
        ":contains_package_path",
        ":dot_as_wildcard",
        ":sibling_package",
        ":parent_directory",
        ":not_anchored",
    ],
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
