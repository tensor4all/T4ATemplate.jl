# T4ATemplate.jl

A template generator for creating new Julia packages based on [TensorCrossInterpolation.jl](https://github.com/tensor4all/TensorCrossInterpolation.jl) patterns and [tensor4all](https://github.com/tensor4all) organization conventions.

## Features

- Test.jl-based tests (default) with debugging tips
- Documenter.jl documentation scaffold
- GitHub Actions CI with multiple Julia versions (1.9, LTS, latest)
- CompatHelper and TagBot automation
- JuliaFormatter configuration
- Optional TensorCrossInterpolation dependency

## Installation

```console
$ git clone git@github.com:tensor4all/T4ATemplate.jl.git
$ cd T4ATemplate.jl
$ julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

## Usage

### Basic Usage

To create a new package named `MyPkg.jl`:

```console
$ julia --project=. generate.jl MyPkg.jl
```

Or using the module directly:

```julia
julia> using T4ATemplate

julia> T4ATemplate.generate("MyPkg.jl")
```

### Advanced Usage

Create a package with TensorCrossInterpolation as a dependency:

```console
$ julia --project=. generate.jl MyPkg.jl --include-tci
```

Or specify a different GitHub user/organization:

```console
$ julia --project=. generate.jl MyPkg.jl --user myusername
```

### Generated Package Structure

```
MyPkg.jl/
├── LICENSE
├── Manifest.toml
├── Project.toml
├── README.md
├── .github/
│   └── workflows/
│       └── CI.yml
├── docs/
│   ├── Manifest.toml
│   ├── Project.toml
│   ├── make.jl
│   └── src/
│       └── index.md
├── src/
│   └── MyPkg.jl
└── test/
    └── runtests.jl
```

## Post-Creation Steps

### 1. Create GitHub Repository

Create a repository on GitHub (using `gh` CLI if available):

```console
$ gh repo create tensor4all/MyPkg.jl \
    --public \
    --description "Julia package for tensor4all" \
    --clone=false
```

### 2. Push to GitHub

The template already sets the remote URL. Push your code:

```console
$ cd MyPkg.jl
$ git push -u origin main
```

### 3. Add to JuliaUmbrella

Add the new package as a submodule to [JuliaUmbrella](https://github.com/tensor4all/JuliaUmbrella):

```console
$ cd /path/to/JuliaUmbrella
$ git submodule add git@github.com:tensor4all/MyPkg.jl.git
$ git commit -m "Add MyPkg.jl as submodule"
$ git push
```

### 4. Enable GitHub Pages

Enable GitHub Pages for documentation:
- Go to repository Settings → Pages
- Source: Deploy from a branch
- Branch: `main` / `docs`

### 5. Set up DOCUMENTER_KEY (Optional but Recommended)

To enable automatic documentation deployment, you need to set up a `DOCUMENTER_KEY` secret:

1. Generate a deploy key:
   ```julia
   julia> using Documenter, DocumenterTools
   julia> DocumenterTools.genkeys("tensor4all", "YourPkg.jl")
   ```

2. Add the private key as a GitHub secret:
   - Go to repository Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `DOCUMENTER_KEY`
   - Value: Paste the private key generated above
   - Click "Add secret"

**Note**: If `DOCUMENTER_KEY` is not set, the documentation job will still run but will skip deployment (with `continue-on-error: true`). This allows the CI to pass even without the key configured.

## Development Tips

### Running Tests

Run all tests:

```julia
julia> using Pkg; Pkg.test()
```

Or from command line:

```console
$ julia --project=. -e 'using Pkg; Pkg.test()'
```

### Debugging Specific Tests

For packages using `include()` statements in `test/runtests.jl` (like TensorCrossInterpolation.jl), you can comment out unnecessary includes and run only the test file you're debugging:

```console
$ julia --project=. test/your_test_file.jl
```

Or edit `test/runtests.jl` to comment out other includes and run:

```console
$ julia --project=. test/runtests.jl
```

### Testing Frameworks

- **Test.jl** (default): Used by TensorCrossInterpolation.jl and packages using Distributed for parallel computation
- **ReTestItems**: Used by some libraries (e.g., Quantics.jl, QuanticsGrids.jl), but not recommended for packages using Distributed

## Package Registration

### T4ARegistry

If your package should be registered in [T4ARegistry](https://github.com/tensor4all/T4ARegistry), use [T4ARegistrator.jl](https://github.com/tensor4all/T4ARegistrator.jl).

### General Registry

If your package is already registered in the official Julia registry, to register a new version, comment `@JuliaRegistrator register` in the library's issue, and the bot will create a PR to the official registry.

## Requirements

- Julia 1.9 or later
- All packages are under the [tensor4all GitHub organization](https://github.com/tensor4all)

## License

MIT License

