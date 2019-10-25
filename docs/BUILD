load("@io_bazel_stardoc//stardoc:stardoc.bzl", "stardoc")

stardoc(
    name = "docs",
    out = "docs.md",
    input = "//tools:codeowners.bzl",
    visibility = ["//:__pkg__"],
)
