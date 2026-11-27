load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//tools:codeowners.bzl", "codeowners", "generate_codeowners")

OWNERS = [
    ":unsorted",
    ":duplicate",
    ":escaped_space",
    ":opted_out",
    ":unowned",
]

generate_codeowners(
    name = "global_owners",
    global_owners = ["@m-global", "@b-global"],
    owners = OWNERS,
    sort_owners = True,
)

generate_codeowners(
    name = "global_owners_strict",
    global_owners = ["@m-global", "@b-global"],
    owners = OWNERS,
    sort_owners = True,
    validate = True,
)

# Without global_owners, and with a nested generate_codeowners that doesn't sort
generate_codeowners(
    name = "nested",
    owners = [":not_sorting"],
    sort_owners = True,
)

generate_codeowners(
    name = "not_sorting",
    owners = OWNERS,
)

codeowners(
    name = "unsorted",
    pattern = "*.a",
    teams = ["@z-team", "@a-team", "@m-team"],
)

codeowners(
    name = "duplicate",
    pattern = "*.b",
    teams = ["@b-team", "@a-team", "@b-team", "@m-global"],
)

codeowners(
    name = "escaped_space",
    pattern = "my\\ dir/",
    teams = ["@z-team", "@a-team"],
)

codeowners(
    name = "opted_out",
    include_global_owners = False,
    pattern = "secret/",
    teams = ["@z-security", "@a-security"],
)

codeowners(
    name = "unowned",
    pattern = "*.generated",
    unowned = True,
)

[
    sh_test(
        name = "validate_" + name,
        srcs = ["//tools:diff.sh"],
        args = [
            "$(location :%s.out)" % name,
            "$(location %s)" % golden,
        ],
        data = [
            golden,
            ":%s.out" % name,
        ],
    )
    for name, golden in [
        ("global_owners", "global_owners_golden"),
        ("global_owners_strict", "global_owners_golden"),
        ("nested", "nested_golden"),
    ]
]
