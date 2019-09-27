load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

SKYLIB_VERSION = "3154dbbc41da755a345afd8545e3152726e17c16"
SKYLIB_HASH = "e398846400ab763a96a854f6fe0313b61ccaeb778d91a2e2cbccd2a60e34eece"

http_archive(
    name = "bazel_skylib",
    sha256 = SKYLIB_HASH,
    strip_prefix = "bazel-skylib-%s" % SKYLIB_VERSION,
    urls = ["https://github.com/bazelbuild/bazel-skylib/archive/%s.tar.gz" % SKYLIB_VERSION],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
