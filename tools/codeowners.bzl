CodeownersInfo = provider(
    doc = "The CODEOWNERS rows of a codeowners or generate_codeowners target, without the generated header.",
    fields = {
        "rows": "File with the rows, and any comments above them.",
    },
)

def _comment_lines(comment):
    if len(comment) == 0:
        return []

    # A blank line separates the comment from the rows above it
    return [""] + [("# " + line).rstrip() for line in comment.split("\n")]

def _codeowners_impl(ctx):
    path = "/" + ctx.label.package + "/"

    # The PATH will be set to the empty string,
    # if the codeowners is defined in the ROOT of the WORKSPACE
    if ctx.label.package == "":
        path = ""

    has_teams = len(ctx.attr.team) > 0 or len(ctx.attr.teams) > 0
    if ctx.attr.unowned and has_teams:
        fail("unowned can not be combined with team or teams.")
    if not ctx.attr.unowned and not has_teams:
        fail("Either team or teams must be set, or unowned = True.")
    if len(ctx.attr.team) > 0 and len(ctx.attr.teams) > 0:
        fail("Both team and teams can not be set at the same time.")
    if len(ctx.attr.pattern) > 0 and len(ctx.attr.patterns) > 0:
        fail("Both pattern and patterns can not be set at the same time.")

    # Unowned entries are written without any owners, which makes GitHub
    # treat the matching files as having no code owner.
    teams = ctx.attr.teams
    if len(ctx.attr.team) > 0:
        teams = [ctx.attr.team]

    # Default to empty pattern (matching path only)
    patterns = [""]
    if len(ctx.attr.patterns) > 0:
        patterns = ctx.attr.patterns
    elif len(ctx.attr.pattern) > 0:
        patterns = [ctx.attr.pattern]

    rows = [" ".join([path + pattern] + teams) for pattern in patterns]
    content = "\n".join(_comment_lines(ctx.attr.comment) + rows)

    ctx.actions.write(
        output = ctx.outputs.outfile,
        content = content,
    )

    return [
        DefaultInfo(files = depset([ctx.outputs.outfile])),
        CodeownersInfo(rows = ctx.outputs.outfile),
    ]

codeowners = rule(
    implementation = _codeowners_impl,
    doc = """
A codeowners-rule represents one or many rows in a CODEOWNERS file.

`team` and `teams` are mutually exclusive.
`pattern` and `patterns` are mutually exclusive.
`unowned` can not be combined with `team` or `teams`.
""",
    attrs = {
        "comment": attr.string(mandatory = False, doc = "A comment to print above the rows, after a blank line. Each line of it becomes a `#` line in the generated CODEOWNERS."),
        "team": attr.string(mandatory = False, doc = "The GitHub team that should get ownership of the matching files. One of team, teams and unowned must be set."),
        "teams": attr.string_list(mandatory = False, doc = "A list of the GitHub teams that should get ownership of the matching files. One of team, teams and unowned must be set."),
        "unowned": attr.bool(default = False, mandatory = False, doc = "Set to True to explicitly mark the matching files as having no owner. The row is written without any teams, which overrides ownership from earlier rows. Can not be combined with team or teams."),
        "pattern": attr.string(mandatory = False, doc = "A pattern of files (eg: '*.bzl') that the team(s) should get ownership of. In the generated CODEOWNERS, the path to this target will be prepended to the pattern."),
        "patterns": attr.string_list(mandatory = False, doc = "A list of patterns, one row will be printed per pattern. See docs of `pattern` for more info."),
    },
    outputs = {
        "outfile": "%{name}.out",
    },
)

def _generate_codeowners_impl(ctx):
    rows = ctx.actions.declare_file(ctx.label.name + ".rows")

    all_ownership_files = []
    for owner in ctx.attr.owners:
        # A nested generate_codeowners contributes its rows without its header
        if CodeownersInfo in owner:
            all_ownership_files.append(owner[CodeownersInfo].rows)
        else:
            all_ownership_files.extend(owner.files.to_list())

    args = []

    for file in all_ownership_files:
        args.append(file.path)

        # Use the path to the target, and validate that all rows in the output matches
        # this path.
        must_have_prefix = file.path[len(file.root.path):-len(file.basename)]

        if must_have_prefix == "/":
            must_have_prefix = ""

        args.append(must_have_prefix)

    ctx.actions.run_shell(
        outputs = [ctx.outputs.outfile, rows],
        inputs = all_ownership_files,
        arguments = args,
        env = {
            "OUTFILE": ctx.outputs.outfile.path,
            "ROWSFILE": rows.path,
            "VALIDATE": "1" if ctx.attr.validate else "0",
            # Passed as data, never spliced into the script, so the shell
            # does not evaluate backticks, $(...), quotes etc. in it.
            "GENERATED_COMMENT": ctx.attr.generated_comment,
        },
        command = """
set -euo pipefail

echoerr() {
    echo "$@" 1>&2;
    exit 1
}

# Comment lines (starting with #) and blank lines are kept as they are. Other lines containing a # are skipped.
# With VALIDATE=1, rows that don't match the path of the target that wrote them are skipped, and a file where no row
# matches fails the build.
filter_rows () {
    file=$1
    must_have_prefix=$2

    awk -v prefix="$must_have_prefix" -v validate="$VALIDATE" '
        /^#/ || /^$/ { print; next }
        /#/ { next }
        {
            if (validate == 1 && $0 !~ prefix) { next }
            matched++
            print
        }
        END { if (validate == 1 && matched == 0) { exit 1 } }
    ' "$file" || echoerr "Potentially malicious input detected, path did not match '${must_have_prefix}' (file = '${file}')"
}

body=$(mktemp)
trap 'rm -f "$body"' EXIT

while [ "$#" -gt 0 ]; do
    file=$1
    must_have_prefix=$2
    shift
    shift

    filter_rows "$file" "$must_have_prefix" >> "$body"
done

# Squeeze runs of blank lines into one and drop trailing ones. A leading one stays, to separate the rows from those
# above them when this generate_codeowners is nested in another.
awk 'NF == 0 { blank = 1; next } { if (blank) { print "" } blank = 0; print }' "$body" > "$ROWSFILE"

printf '%s\n\n' "$GENERATED_COMMENT" > "$OUTFILE"
awk 'NF == 0 && !printed { next } { printed = 1; print }' "$ROWSFILE" >> "$OUTFILE"
        """,
    )

    return [
        DefaultInfo(files = depset([ctx.outputs.outfile])),
        CodeownersInfo(rows = rows),
    ]

generate_codeowners = rule(
    implementation = _generate_codeowners_impl,
    doc = """
Creates a GitHub-compatible CODEOWNERS file based on the `owners`.
""",
    attrs = {
        "generated_comment": attr.string(
            doc = "A comment to insert at the top of the generated file",
            default = "# This file was generated by rules_codeowners / Bazel. Don't edit it directly",
        ),
        "owners": attr.label_list(mandatory = True, doc = "A list of codeowners and generate_codeowners. One generate_codeowners can include another generate_codeowners to achieve nested rules."),
        "validate": attr.bool(default = False, doc = "Set to True to enable strict validation of codeowners values. Disabled by default.", mandatory = False),
    },
    outputs = {
        "outfile": "%{name}.out",
    },
)
