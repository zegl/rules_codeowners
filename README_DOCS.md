<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a name="#codeowners"></a>

## codeowners

<pre>
codeowners(<a href="#codeowners-name">name</a>, <a href="#codeowners-pattern">pattern</a>, <a href="#codeowners-patterns">patterns</a>, <a href="#codeowners-team">team</a>, <a href="#codeowners-teams">teams</a>)
</pre>


A codeowners-rule represents one or many rows in a CODEOWNERS file.

`team` and `teams` are mutually exclusive.
`pattern` and `patterns` are mutually exclusive.


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| pattern |  A pattern of files (eg: '*.bzl') that the team(s) should get ownership of. In the generated CODEOWNERS, the path to this target will be prepended to the pattern.   | String | optional | "" |
| patterns |  A list of patterns, one row will be printed per pattern. See docs of <code>pattern</code> for more info.   | List of strings | optional | [] |
| team |  The GitHub team that should get ownership of the matching files. One of team and teams must be set.   | String | optional | "" |
| teams |  A list of the GitHub teams that should get ownership of the matching files. One of team and teams must be set.   | List of strings | optional | [] |


<a name="#generate_codeowners"></a>

## generate_codeowners

<pre>
generate_codeowners(<a href="#generate_codeowners-name">name</a>, <a href="#generate_codeowners-owners">owners</a>)
</pre>


Creates a GitHub-compatible CODEOWNERS file based on the `owners`.


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :-------------: | :-------------: | :-------------: | :-------------: | :-------------: |
| name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| owners |  A list of codeowners and generate_codeowners. One generate_codeowners can include another generate_codeonwers to effective acheive nested rules.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |


