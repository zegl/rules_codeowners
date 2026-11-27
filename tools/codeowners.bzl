CodeownersInfo = provider(
    doc = "The CODEOWNERS rows of a codeowners or generate_codeowners target, without the generated header.",
    fields = {
        "rows": "File with the rows, and any comments above them.",
        "include_global_owners": "Whether the global_owners of a generate_codeowners should be added to the rows.",
    },
)

# Only returned by generate_codeowners, used to detect nested generate_codeowners
_GenerateCodeownersInfo = provider(
    doc = "Marks a generate_codeowners target.",
    fields = {
        "global_owners": "The global_owners of the generate_codeowners.",
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
    if ctx.attr.unowned and not ctx.attr.include_global_owners:
        fail("include_global_owners has no effect when unowned = True, unowned rows never get the global owners.")

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
        CodeownersInfo(
            rows = ctx.outputs.outfile,
            # Adding owners to an unowned row would make it owned
            include_global_owners = ctx.attr.include_global_owners and not ctx.attr.unowned,
        ),
    ]

codeowners = rule(
    implementation = _codeowners_impl,
    doc = """
A codeowners-rule represents one or many rows in a CODEOWNERS file.

`team` and `teams` are mutually exclusive.
`pattern` and `patterns` are mutually exclusive.
`unowned` can not be combined with `team` or `teams`.

The `global_owners` of the `generate_codeowners` are added to the rows, unless `include_global_owners = False`
or `unowned = True`.
""",
    attrs = {
        "comment": attr.string(mandatory = False, doc = "A comment to print above the rows, after a blank line. Each line of it becomes a `#` line in the generated CODEOWNERS."),
        "team": attr.string(mandatory = False, doc = "The GitHub team that should get ownership of the matching files. One of team, teams and unowned must be set."),
        "teams": attr.string_list(mandatory = False, doc = "A list of the GitHub teams that should get ownership of the matching files. One of team, teams and unowned must be set."),
        "unowned": attr.bool(default = False, mandatory = False, doc = "Set to True to explicitly mark the matching files as having no owner. The row is written without any teams, which overrides ownership from earlier rows. Can not be combined with team or teams."),
        "include_global_owners": attr.bool(default = True, mandatory = False, doc = "Set to False to not add the `global_owners` of the `generate_codeowners` to these rows."),
        "pattern": attr.string(mandatory = False, doc = "A pattern of files (eg: '*.bzl') that the team(s) should get ownership of. In the generated CODEOWNERS, the path to this target will be prepended to the pattern."),
        "patterns": attr.string_list(mandatory = False, doc = "A list of patterns, one row will be printed per pattern. See docs of `pattern` for more info."),
    },
    outputs = {
        "outfile": "%{name}.out",
    },
)

def _generate_codeowners_impl(ctx):
    rows = ctx.actions.declare_file(ctx.label.name + ".rows")

    # Pairs of (file, whether the global owners should be added to its rows)
    all_ownership_files = []
    for owner in ctx.attr.owners:
        if _GenerateCodeownersInfo in owner:
            # Nested generate_codeowners only contribute their rows as text, so it's not possible to know which
            # of them opted out of the global owners.
            if len(ctx.attr.global_owners) > 0:
                fail("global_owners can not be combined with nested generate_codeowners, %s is a generate_codeowners." % owner.label)
            if len(owner[_GenerateCodeownersInfo].global_owners) > 0:
                fail("A generate_codeowners with global_owners can not be nested in another generate_codeowners, %s sets global_owners." % owner.label)

        # A nested generate_codeowners contributes its rows without its header
        if CodeownersInfo in owner:
            info = owner[CodeownersInfo]
            all_ownership_files.append((info.rows, info.include_global_owners))
        else:
            all_ownership_files.extend([(file, True) for file in owner.files.to_list()])

    global_owners = ctx.attr.global_owners
    if ctx.attr.sort_owners:
        # The "*" row is written as it is, so sort it here
        global_owners = sorted({owner: None for owner in global_owners}.keys())

    args = []

    for file, include_global_owners in all_ownership_files:
        args.append(file.path)

        # Use the path to the target, and validate that all rows in the output matches
        # this path.
        must_have_prefix = file.path[len(file.root.path):-len(file.basename)]

        if must_have_prefix == "/":
            must_have_prefix = ""

        args.append(must_have_prefix)
        args.append("1" if include_global_owners else "0")

    ctx.actions.run_shell(
        outputs = [ctx.outputs.outfile, rows],
        inputs = [file for file, _ in all_ownership_files],
        arguments = args,
        env = {
            "OUTFILE": ctx.outputs.outfile.path,
            "ROWSFILE": rows.path,
            "VALIDATE": "1" if ctx.attr.validate else "0",
            # Passed as data, never spliced into the script, so the shell
            # does not evaluate backticks, $(...), quotes etc. in it.
            "GENERATED_COMMENT": ctx.attr.generated_comment,
            "GLOBAL_OWNERS": " ".join(global_owners),
            "SORT_OWNERS": "1" if ctx.attr.sort_owners else "0",
            # Owners are sorted by their bytes, not by the collation of the host's locale
            "LC_ALL": "C",
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
# With add_global=1, the GLOBAL_OWNERS that are not already owners of a row are added to the end of it.
# With SORT_OWNERS=1, the owners of each row are sorted, and duplicates are removed.
filter_rows () {
    file=$1
    must_have_prefix=$2
    add_global=$3

    awk -v prefix="$must_have_prefix" -v validate="$VALIDATE" -v add_global="$add_global" -v global="$GLOBAL_OWNERS" -v sort="$SORT_OWNERS" '
        /^#/ || /^$/ { print; next }
        /#/ { next }
        {
            # The prefix is compared as a literal string, at the start of the row
            if (validate == 1 && prefix != "" && index($0, prefix) != 1) { next }
            matched++
            if (add_global != 1 && sort != 1) { print; next }

            # The path is the first field, and the fields after it that an escaped space ("\\ ") split it into
            k = 1
            while (k < NF && $k ~ /\\\\$/) { k++ }
            row = $1
            for (i = 2; i <= k; i++) { row = row " " $i }
            n = 0
            for (i = k + 1; i <= NF; i++) { owners[++n] = $i }

            if (add_global == 1) {
                g = split(global, globals, " ")
                for (i = 1; i <= g; i++) {
                    found = 0
                    for (j = 1; j <= n; j++) {
                        if (owners[j] == globals[i]) { found = 1; break }
                    }
                    if (!found) { owners[++n] = globals[i] }
                }
            }

            if (sort == 1) {
                # Insertion sort, the rows are short. Appending "" compares the owners as strings.
                for (i = 2; i <= n; i++) {
                    owner = owners[i]
                    for (j = i - 1; j >= 1 && (owners[j] "") > (owner ""); j--) { owners[j + 1] = owners[j] }
                    owners[j + 1] = owner
                }
            }

            for (i = 1; i <= n; i++) {
                if (sort == 1 && i > 1 && owners[i] == owners[i - 1]) { continue }
                row = row " " owners[i]
            }
            print row
        }
        END { if (validate == 1 && matched == 0) { exit 1 } }
    ' "$file" || echoerr "Potentially malicious input detected, path did not match '${must_have_prefix}' (file = '${file}')"
}

body=$(mktemp)
trap 'rm -f "$body"' EXIT

# The global owners own everything that no other row matches. This row must be first, as the last matching row wins.
if [ -n "$GLOBAL_OWNERS" ]; then
    printf '* %s\n' "$GLOBAL_OWNERS" >> "$body"
fi

while [ "$#" -gt 0 ]; do
    file=$1
    must_have_prefix=$2
    add_global=$3
    shift 3

    filter_rows "$file" "$must_have_prefix" "$add_global" >> "$body"
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
        CodeownersInfo(rows = rows, include_global_owners = True),
        _GenerateCodeownersInfo(global_owners = ctx.attr.global_owners),
    ]

generate_codeowners = rule(
    implementation = _generate_codeowners_impl,
    doc = """
Creates a GitHub-compatible CODEOWNERS file based on the `owners`.

When `global_owners` is set, a `*` row with the global owners is written first, and the global owners are added to
all other rows (unless the `codeowners` sets `include_global_owners = False`, or `unowned = True`). A
`generate_codeowners` with `global_owners` can not include, or be included in, another `generate_codeowners`.
""",
    attrs = {
        "generated_comment": attr.string(
            doc = "A comment to insert at the top of the generated file",
            default = "# This file was generated by rules_codeowners / Bazel. Don't edit it directly",
        ),
        "owners": attr.label_list(mandatory = True, doc = "A list of codeowners and generate_codeowners. One generate_codeowners can include another generate_codeowners to achieve nested rules."),
        "global_owners": attr.string_list(mandatory = False, doc = "A list of GitHub teams that own all files. They are written as a `*` row first in the file, and added to the rows of all `codeowners`, so that they can approve changes everywhere. Can not be combined with nested generate_codeowners."),
        "validate": attr.bool(default = False, doc = "Set to True to enable strict validation of codeowners values. Disabled by default.", mandatory = False),
        "sort_owners": attr.bool(default = False, mandatory = False, doc = "Set to True to sort the owners of each row (by their bytes, after the `global_owners` are added), and remove duplicate owners. This applies to the rows of nested generate_codeowners too."),
    },
    outputs = {
        "outfile": "%{name}.out",
    },
)
