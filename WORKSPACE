workspace(name = "rules_codeowners")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

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

STARDOC_VERSION = "4378e9b6bb2831de7143580594782f538f461180"
STARDOC_HASH = "84495f9c4da6455105e471249983172a8d23b185cf5283f3b762f2fd2b91b2c0"

http_archive(
    name = "io_bazel_stardoc",
    sha256 = STARDOC_HASH,
    strip_prefix = "stardoc-%s" % STARDOC_VERSION,
    urls = ["https://github.com/bazelbuild/stardoc/archive/%s.tar.gz" % STARDOC_VERSION],
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")
stardoc_repositories()
