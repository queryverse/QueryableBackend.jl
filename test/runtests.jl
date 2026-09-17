using TestItemRunner

include("test_queryablebackend.jl")
include("test_new_operators.jl")

@run_package_tests
