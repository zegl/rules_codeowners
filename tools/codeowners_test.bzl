load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _failure_testing_test_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, ctx.attr.expected)
    return analysistest.end(env)

failure_testing_test = analysistest.make(
    _failure_testing_test_impl,
    expect_failure = True,
    attrs = {
        "expected": attr.string(mandatory = True),
    },
)
