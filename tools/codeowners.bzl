CodeownersInfo = provider(
    doc = "The CODEOWNERS rows of a codeowners or generate_codeowners target, without the generated header.",
    fields = {
        "entries": """The rows, and the comment and blank lines above them, in order. Each is a struct with:
`text`: the comment or blank line, or None for a row.
`path`: the path of the row, or None for a comment or blank line.
`owners`: the owners of the row.
`include_global_owners`: whether the global_owners of a generate_codeowners should be added to the row.
`label`: the label of the codeowners that wrote the row.
`package_path`: the path of that codeowners' package, which the row is expected to start with.""",
    },
)

# Only returned by generate_codeowners, used to detect nested generate_codeowners
_GenerateCodeownersInfo = provider(
    doc = "Marks a generate_codeowners target.",
    fields = {
        "global_owners": "The global_owners of the generate_codeowners.",
    },
)

def _line(text):
    return struct(text = text, path = None, owners = [], include_global_owners = False, label = None, package_path = None)

def _row(path, owners, include_global_owners, label, package_path):
    return struct(
        text = None,
        path = path,
        owners = owners,
        include_global_owners = include_global_owners,
        label = label,
        package_path = package_path,
    )

def _with_owners(row, owners):
    return _row(row.path, owners, row.include_global_owners, row.label, row.package_path)

def _entry_text(entry):
    if entry.text != None:
        return entry.text
    return " ".join([entry.path] + entry.owners)

def _comment_lines(comment):
    if len(comment) == 0:
        return []

    # A blank line separates the comment from the rows above it
    return [""] + [("# " + line).rstrip() for line in comment.split("\n")]

def _check_value(label, attr, value):
    # A "#" starts a comment, and a newline starts a new row, so either would change the meaning of the row
    if "#" in value or "\n" in value:
        fail("%s: %s can not contain a # or a newline, got %s" % (label, attr, repr(value)))

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

    for team in teams:
        _check_value(ctx.label, "team", team)
    for pattern in patterns:
        _check_value(ctx.label, "pattern", pattern)

    # Adding owners to an unowned row would make it owned
    include_global_owners = ctx.attr.include_global_owners and not ctx.attr.unowned

    entries = [_line(line) for line in _comment_lines(ctx.attr.comment)]
    for pattern in patterns:
        # A pattern starting with // is anchored at the root of the repository, instead of at this package
        if pattern.startswith("//"):
            row_path = pattern[1:]
        else:
            row_path = path + pattern
        entries.append(_row(row_path, teams, include_global_owners, str(ctx.label), path))

    ctx.actions.write(
        output = ctx.outputs.outfile,
        content = "\n".join([_entry_text(entry) for entry in entries]),
    )

    return [
        DefaultInfo(files = depset([ctx.outputs.outfile])),
        CodeownersInfo(entries = entries),
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
        "pattern": attr.string(mandatory = False, doc = "A pattern of files (eg: '*.bzl') that the team(s) should get ownership of. In the generated CODEOWNERS, the path to this target will be prepended to the pattern. A pattern starting with `//` is anchored at the root of the repository instead, eg `//docs/foo/` becomes `/docs/foo/`, so a package can own files outside of it."),
        "patterns": attr.string_list(mandatory = False, doc = "A list of patterns, one row will be printed per pattern. See docs of `pattern` for more info."),
    },
    outputs = {
        "outfile": "%{name}.out",
    },
)

def _row_owners(row, global_owners, sort_owners):
    owners = list(row.owners)
    if row.include_global_owners:
        for owner in global_owners:
            if owner not in owners:
                owners.append(owner)
    if sort_owners:
        # Starlark compares strings by their bytes
        owners = sorted({owner: None for owner in owners}.keys())
    return owners

def _render(entries):
    """The lines of the entries, with runs of blank lines squeezed into one, and no leading or trailing ones."""
    lines = []
    blank = False
    for entry in entries:
        text = _entry_text(entry)
        if text.strip() == "":
            blank = True
            continue
        if blank and lines:
            lines.append("")
        blank = False
        lines.append(text)
    return lines

def _generate_codeowners_impl(ctx):
    for owner in ctx.attr.owners:
        # The rows of a nested generate_codeowners get the global owners of the one that includes it, as their own
        # include_global_owners says. Its own "*" row would replace the ownership of all rows above it.
        if _GenerateCodeownersInfo in owner:
            if len(owner[_GenerateCodeownersInfo].global_owners) > 0:
                fail("A generate_codeowners with global_owners can not be nested in another generate_codeowners, %s sets global_owners." % owner.label)

    for owner in ctx.attr.global_owners:
        _check_value(ctx.label, "global_owners", owner)

    global_owners = ctx.attr.global_owners
    if ctx.attr.sort_owners:
        # The "*" row is written as it is, so sort it here
        global_owners = sorted({owner: None for owner in global_owners}.keys())

    entries = []
    for owner in ctx.attr.owners:
        for entry in owner[CodeownersInfo].entries:
            if entry.text == None:
                if ctx.attr.validate and not entry.path.startswith(entry.package_path):
                    fail("%s writes the row %s, which is outside its package %s. validate = True only allows rows in the package of their codeowners." % (entry.label, entry.path, entry.package_path))
                entry = _with_owners(entry, _row_owners(entry, global_owners, ctx.attr.sort_owners))
            entries.append(entry)

    # The global owners own everything that no other row matches. This row must be first, as the last matching row wins.
    # It is not part of the entries, so it's left out when this generate_codeowners is nested in another.
    lines = _render(entries)
    if len(global_owners) > 0:
        lines = ["* " + " ".join(global_owners)] + lines

    content = ctx.attr.generated_comment + "\n\n"
    if lines:
        content += "\n".join(lines) + "\n"

    ctx.actions.write(
        output = ctx.outputs.outfile,
        content = content,
    )

    return [
        DefaultInfo(files = depset([ctx.outputs.outfile])),
        CodeownersInfo(entries = entries),
        _GenerateCodeownersInfo(global_owners = ctx.attr.global_owners),
    ]

generate_codeowners = rule(
    implementation = _generate_codeowners_impl,
    doc = """
Creates a GitHub-compatible CODEOWNERS file based on the `owners`.

When `global_owners` is set, a `*` row with the global owners is written first, and the global owners are added to
all other rows (unless the `codeowners` sets `include_global_owners = False`, or `unowned = True`). This includes the
rows of nested `generate_codeowners`, which can not set `global_owners` themselves.
""",
    attrs = {
        "generated_comment": attr.string(
            doc = "A comment to insert at the top of the generated file",
            default = "# This file was generated by rules_codeowners / Bazel. Don't edit it directly",
        ),
        "owners": attr.label_list(mandatory = True, providers = [CodeownersInfo], doc = "A list of codeowners and generate_codeowners. One generate_codeowners can include another generate_codeowners to achieve nested rules."),
        "global_owners": attr.string_list(mandatory = False, doc = "A list of GitHub teams that own all files. They are written as a `*` row first in the file, and added to the rows of all `codeowners`, so that they can approve changes everywhere, including the rows of nested generate_codeowners. Can not be set on a generate_codeowners that is nested in another."),
        "validate": attr.bool(default = False, doc = "Set to True to fail the build when a row is outside the package of its `codeowners`, which a pattern starting with `//` allows. This applies to the rows of nested generate_codeowners too.", mandatory = False),
        "sort_owners": attr.bool(default = False, mandatory = False, doc = "Set to True to sort the owners of each row (by their bytes, after the `global_owners` are added), and remove duplicate owners. This applies to the rows of nested generate_codeowners too."),
    },
    outputs = {
        "outfile": "%{name}.out",
    },
)
