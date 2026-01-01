- Use the same language as in past conversations with the user (if it has been Japanese, use Japanese)

- All source code and documentation must be in English

- Each subdirectory is a git repository. If there is an AGENTS.md in each directory, read it when working on the corresponding library

- Each of some of the git repositories is an independent Julia package with its own Project.toml, src/, test/, and docs/ directories. Understand the package structure before making changes

- When working on a git repository, navigate into its directory and work as if it were a standalone package. Be aware of dependencies between packages

- **Running tests**: T4A packages use two test frameworks depending on their needs:
  - **ReTestItems**: For packages that don't use Distributed (e.g., T4AQuantics.jl, QuanticsGrids.jl)
  - **Standard Test.jl**: For packages that use Distributed for parallel computation (e.g., T4APartitionedTT.jl, T4ATCIAlgorithms.jl)

  **Full test suite** - Use `Pkg.test()` for both frameworks:
  ```bash
  julia --project=. -e "using Pkg; Pkg.test()" 2>&1 | tee test_output.log
  ```
  This automatically sets up test dependencies without modifying `Project.toml`.

  **Running specific tests for debugging**:

  For **ReTestItems packages** (check if `test/runtests.jl` uses `ReTestItems`):
  ```bash
  # Requires ReTestItems to be installed first
  julia --project=. -e "using ReTestItems; runtests(\"test/specific_tests.jl\")" 2>&1 | tee test_specific.log

  # Filter by test name (regex supported)
  julia --project=. -e "using ReTestItems; runtests(\"test/\"; name=\"test_name\")" 2>&1 | tee test_specific.log
  ```

  For **standard Test.jl packages** (check if `test/runtests.jl` uses `include`):
  ```bash
  # Include the specific test file directly
  julia --project=. -e "
    using PkgName  # Replace with actual package name
    using Test
    include(\"test/_util.jl\")  # If test utilities exist
    include(\"test/specific_tests.jl\")
  " 2>&1 | tee test_specific.log
  ```

  **Note**: Running specific tests directly requires test dependencies (ReTestItems, etc.) to be installed. If you install them in the project environment, `Project.toml` and `Manifest.toml` will be modified.

  **After debugging, revert these changes**:
  ```bash
  # Check what was added
  git diff Project.toml

  # If ONLY test deps were added (no other changes), safe to checkout
  git checkout Project.toml Manifest.toml

  # If you have other uncommitted changes, manually remove the added lines
  ```

  **Always save test output to files** using `tee` for debugging.

- **Handling Project.toml changes during testing**: If `Pkg.add` or similar operations during testing modify `Project.toml`, **always review the changes carefully** before committing:
  - First, use `git diff Project.toml` to see exactly what was added or changed
  - **Never** use `git checkout Project.toml` or `git checkout Manifest.toml` to blindly revert changes
  - Understand the diff, then manually remove only the unnecessary parts
  - **Never commit changes that promote test dependencies or weak dependencies to strong dependencies** - this is strictly forbidden. Test dependencies should remain in `[compat]` or `[extras]` sections, and weak dependencies should not be moved to `[deps]`
  - **Common issue**: Tools like Aqua.jl, JET.jl, etc. are often accidentally added to `Project.toml` during testing. However, when using `Pkg.test()`, these test tools are automatically available as test dependencies and should **not** be added to `[deps]`. If they appear in `Project.toml` after testing, remove them manually.

- If a package has a `.JuliaFormatter.toml` file, follow its formatting rules. Otherwise, follow standard Julia style guidelines

- When making changes that affect multiple packages, consider the dependency graph and test affected packages accordingly

- The `gh` (GitHub CLI) command is available locally and can be used for GitHub-related operations

- **Never push directly to main branch**: All changes must be made through pull requests. Create a branch, commit changes, push the branch, and create a PR. Wait for CI workflows to pass before merging.

- **Never use force push to main branch**: Force pushing (including `--force-with-lease`) to main is prohibited. If you need to rewrite history, do it on a feature branch and create a PR.

- All libraries are under the [tensor4all GitHub organization](https://github.com/tensor4all)

- Some libraries are registered in T4ARegistry. Use T4ARegistrator.jl to register them. T4ARegistrator.jl is a development tool that should be installed in the global environment, not added as a dependency in individual package Project.toml files. When manually registering packages in T4ARegistry, use HTTPS URLs (not SSH) in the `repo` field of Package.toml to ensure compatibility in environments without SSH access

- Some libraries are already registered in the official Julia registry. To register a new version, comment `@JuliaRegistrator register` in the library's issue, and the bot will create a PR to the official registry

- **Using `[sources]` for local development**: For T4A packages that depend on other T4A packages, add a `[sources]` section in Project.toml pointing to local paths during development. This enables seamless local development across interdependent packages.
  ```toml
  [sources]
  T4ATensorTrain = {path = "../T4ATensorTrain.jl"}
  T4AMatrixCI = {path = "../T4AMatrixCI.jl"}
  ```
  **Important**: `[sources]` entries are for local development only. **Always remove `[sources]` from Project.toml before committing.** The `[sources]` section should never be pushed to the repository.

- **Updating multiple interdependent Julia packages**: When you need to update many Julia libraries that depend on each other (e.g., after bumping an upstream package version), it is best to update and verify everything locally before pushing to remote.
  (a) Add `[sources]` entries in each package's Project.toml pointing to local paths for development.
  (b) Update all packages in dependency order. Verify that all packages pass tests and documentation builds locally.
  (c) Remove `[sources]` entries before committing. Commit changes to local working branches but do not push yet. Include version bumps in these commits.
  (d) Starting from the most upstream package, push the branch, create a PR, and merge after CI passes. After each merge, register the new version to T4ARegistry using T4ARegistrator.jl. Then proceed to the next downstream package.

  **If a problem occurs during step (d)**: If any package fails CI or encounters issues during this phase, go back to step (a) for that package and all its downstream dependencies. Fix the issue locally and verify all affected packages pass tests before attempting to push again.

  **Note**: Do not commit Manifest.toml files. They are auto-generated and will be resolved correctly by CI and other environments based on Project.toml.

