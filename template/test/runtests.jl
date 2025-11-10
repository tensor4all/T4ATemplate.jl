import {{{PKG}}}
using Test{{{AQUA_IMPORT}}}{{{JET_IMPORT}}}

{{{AQUA_TESTSET}}}
{{{#JET_TESTSET}}}VERSION >= v"1.9" && {{{JET_TESTSET}}}{{{/JET_TESTSET}}}
@testset "{{{PKG}}}.jl" begin
    # Write your tests here.
    # 
    # For debugging specific tests, comment out other include() statements
    # in this file and run only the test file you're debugging:
    # 
    # julia --project=. test/your_test_file.jl
    #
    # Or comment out includes in runtests.jl and run:
    #
    # julia --project=. test/runtests.jl
end

