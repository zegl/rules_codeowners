load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

skylib_version = "9aa308e1ef0f0f0543e3d58f3b3c5488c087c8c1"

http_archive(
    name = "bazel_skylib",
    sha256 = "35081ec272bf1bbad229a9c8054e0555793ad095e9cef3f6bb4b8c54d00285c5",
    strip_prefix = "bazel-skylib-9aa308e1ef0f0f0543e3d58f3b3c5488c087c8c1",
    urls = ["https://github.com/bazelbuild/bazel-skylib/archive/9aa308e1ef0f0f0543e3d58f3b3c5488c087c8c1.tar.gz"],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()
