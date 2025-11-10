module T4ATemplate

using ArgParse: @add_arg_table!, ArgParseSettings, parse_args
using PkgTemplates
using TOML

const T4A_TEMPLATE_DIR = Ref{String}(joinpath(pkgdir(@__MODULE__), "template"))

export generate

"""
    generate(pkgname::AbstractString; user="tensor4all", include_tci=false)

Generate a new Julia package using the T4A template.

# Arguments
- `pkgname`: Name of the package (e.g., "MyPkg.jl")
- `user`: GitHub user/organization (default: "tensor4all")
- `include_tci`: Whether to include TensorCrossInterpolation as a dependency (default: false)
"""
function generate(pkgname::AbstractString; user="tensor4all", include_tci=false)
    plugins = [
        ProjectFile(; version=v"0.1.0"),
        Git(;
            ignore=[".CondaPkg", ".ipynb_checkpoints", "*.gif", "*.png", ".DS_Store"],
            manifest=false,
            ssh=true,
        ),
        GitHubActions(;
            file=joinpath(T4A_TEMPLATE_DIR[], "CI.yml"),
            extra_versions=["1.9", "lts", "1"],
        ),
        Formatter(;
            file=joinpath(T4A_TEMPLATE_DIR[], "JuliaFormatter.toml"), style="blue"
        ),
        Documenter{GitHubActions}(),
        CompatHelper(),
        TagBot(),
        Readme(;
            inline_badges=true,
            badge_order=DataType[GitHubActions, Documenter{GitHubActions}]
        ),
        Tests(;
            file=joinpath(T4A_TEMPLATE_DIR[], "test", "runtests.jl"),
            aqua=true,
            aqua_kwargs=(; ambiguities=false, deps_compat=false),
            jet=true,
        ),
    ]

    t4atemplate = Template(;
        user=user,
        julia=v"1.9",
        dir=pwd(),
        plugins=plugins,
    )

    # Create package
    result = t4atemplate(pkgname)
    
    # Add dependencies if requested by editing Project.toml directly
    if include_tci
        pkg_path = joinpath(pwd(), pkgname)
        project_file = joinpath(pkg_path, "Project.toml")
        project = TOML.parsefile(project_file)
        
        # Add TensorCrossInterpolation to deps
        if !haskey(project, "deps")
            project["deps"] = Dict{String, Any}()
        end
        project["deps"]["TensorCrossInterpolation"] = "b261b2ec-6378-4871-b32e-9173bb050604"
        
        # Write back to file
        open(project_file, "w") do io
            TOML.print(io, project)
        end
    end
    
    return result
end

function generate()
    s = ArgParseSettings()
    @add_arg_table! s begin
        "pkgname"
        help = "Specify the name of the package, for example, `MyPkg.jl`."
        required = true
        "--user"
        help = "GitHub user/organization (default: tensor4all)"
        default = "tensor4all"
        "--include-tci"
        help = "Include TensorCrossInterpolation as a dependency"
        action = :store_true
    end
    parsed_args = parse_args(ARGS, s)
    pkgname::String = parsed_args["pkgname"]
    user::String = parsed_args["user"]
    include_tci::Bool = parsed_args["include-tci"]
    return generate(pkgname; user=user, include_tci=include_tci)
end

end # module

