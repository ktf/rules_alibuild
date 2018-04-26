package(default_testonly = 1)

[sh_test(
  name= "run-{0}".format(test),
  srcs = ["test.sh"],
  args=["$(locations @{0}//:lib)".format(test)],
  data = ["@{0}//:lib".format(test), "@{0}//:include".format(test)],
  timeout = "short",
) for test in [
    "zlib",
    "UUID"
]]
