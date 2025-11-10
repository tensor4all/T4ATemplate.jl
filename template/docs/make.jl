using {{{PKG}}}
using Documenter

DocMeta.setdocmeta!({{{PKG}}}, :DocTestSetup, :(using {{{PKG}}}); recursive=true)

makedocs(;
    modules=[{{{PKG}}}],
    authors="tensor4all contributors",
    sitename="{{{PKG}}}.jl",
    format=Documenter.HTML(;
        canonical="https://github.com/{{{USER}}}/{{{PKG}}}.jl",
        edit_link="main",
        assets=String[]),
    pages=[
        "Home" => "index.md",
    ]
)

deploydocs(;
    repo="github.com/{{{USER}}}/{{{PKG}}}.jl.git",
    devbranch="main",
)

