- Use the same language as in past conversations with the user (if it has been Japanese, use Japanese)

- All source code and documentation must be in English

- Each subdirectory is a git repository. If there is an AGENTS.md in each directory, read it when working on the corresponding library

- Each of some of the git repositories is an independent Julia package with its own Project.toml, src/, test/, and docs/ directories. Understand the package structure before making changes

- When working on a git repository, navigate into its directory and work as if it were a standalone package. Be aware of dependencies between packages

- **When running tests, always redirect stdout and stderr to files and use tee for real-time output**: **Always save test output to files** - this is critical because test output contains detailed error messages, stack traces, and diagnostic information that you'll need for debugging. Without saving to files, you would need to run tests twice: once to see what happened, and again to capture the details. Using `tee` allows you to see progress in real-time while simultaneously saving everything to files. Example:
  ```bash
  julia --project=. test/runtests.jl 2>&1 | tee test_output.log
  ```
  Or to separate stdout and stderr while still seeing both in real-time:
  ```bash
  julia --project=. test/runtests.jl > >(tee test_stdout.log) 2> >(tee test_stderr.log >&2)
  ```
  **Important**: Always save test output to files. The saved logs are essential for debugging failures, understanding test behavior, and reviewing detailed error messages without re-running tests.

- **Handling Project.toml changes during testing**: If `Pkg.add` or similar operations during testing modify `Project.toml`, **always review the changes carefully** before committing:
  - First, use `git diff Project.toml` to see exactly what was added or changed
  - **Never** use `git checkout Project.toml` or `git checkout Manifest.toml` to blindly revert changes
  - Understand the diff, then manually remove only the unnecessary parts
  - **Never commit changes that promote test dependencies or weak dependencies to strong dependencies** - this is strictly forbidden. Test dependencies should remain in `[compat]` or `[extras]` sections, and weak dependencies should not be moved to `[deps]`
  - **Common issue**: Tools like Aqua.jl, JET.jl, etc. are often accidentally added to `Project.toml` during testing. However, when using `Pkg.test()`, these test tools are automatically available as test dependencies and should **not** be added to `[deps]`. If they appear in `Project.toml` after testing, remove them manually.

- Some libraries use ReTestItems as their test framework (e.g., Quantics.jl, QuanticsGrids.jl, TreeTCI.jl, SimpleTensorTrains.jl). However, ReTestItems has compatibility issues with libraries that use Distributed for parallel computation, so those libraries use the standard Test.jl framework instead

- **For ReTestItems packages, you can run individual test files**: ReTestItems supports running specific test files by passing file paths to `runtests()`. This is useful for debugging specific tests without running the entire test suite. Examples:
  ```bash
  # Run a specific test file
  julia --project=. -e "using ReTestItems; runtests(\"test/binaryop_tests.jl\")"
  
  # Run multiple specific test files
  julia --project=. -e "using ReTestItems; runtests(\"test/binaryop_tests.jl\", \"test/mul_tests.jl\")"
  
  # Run with specific options (e.g., single worker for debugging)
  julia --project=. -e "using ReTestItems; runtests(\"test/binaryop_tests.jl\"; nworkers=1)"
  ```
  Note: The file paths should be relative to the package root directory. Always redirect output to files when debugging:
  ```bash
  julia --project=. -e "using ReTestItems; runtests(\"test/binaryop_tests.jl\")" 2>&1 | tee test_binaryop.log
  ```

- If a package has a `.JuliaFormatter.toml` file, follow its formatting rules. Otherwise, follow standard Julia style guidelines

- When making changes that affect multiple packages, consider the dependency graph and test affected packages accordingly

- The `gh` (GitHub CLI) command is available locally and can be used for GitHub-related operations

- **Never push directly to main branch**: All changes must be made through pull requests. Create a branch, commit changes, push the branch, and create a PR. Wait for CI workflows to pass before merging.

- **Never use force push to main branch**: Force pushing (including `--force-with-lease`) to main is prohibited. If you need to rewrite history, do it on a feature branch and create a PR.

- All libraries are under the [tensor4all GitHub organization](https://github.com/tensor4all)

- Some libraries are registered in T4ARegistry. Use T4ARegistrator.jl to register them. T4ARegistrator.jl is a development tool that should be installed in the global environment, not added as a dependency in individual package Project.toml files. When manually registering packages in T4ARegistry, use HTTPS URLs (not SSH) in the `repo` field of Package.toml to ensure compatibility in environments without SSH access

- Some libraries are already registered in the official Julia registry. To register a new version, comment `@JuliaRegistrator register` in the library's issue, and the bot will create a PR to the official registry

- **Using `[sources]` for local development (strongly recommended for T4A packages)**: For T4A packages that depend on other T4A packages, it is strongly recommended to add a `[sources]` section in Project.toml pointing to local paths. This enables seamless local development across interdependent packages.
  ```toml
  [sources]
  T4ATensorTrain = {path = "../T4ATensorTrain.jl"}
  TensorCrossInterpolation = {path = "../TensorCrossInterpolation.jl"}
  ```
  **Benefits**:
  - When local paths exist (e.g., in the umbrella repository), Julia uses the local versions automatically
  - When local paths don't exist (e.g., in CI or user environments), Julia falls back to the registered versions from the registry
  - No need to add/remove `[sources]` entries during development workflows
  - Makes cross-package development and testing much smoother

- **Updating multiple interdependent Julia packages**: When you need to update many Julia libraries that depend on each other (e.g., after bumping an upstream package version), it is best to update and verify everything locally before pushing to remote.
  (a) Ensure `[sources]` entries in each package's Project.toml point to local paths (should already be present if following the recommendation above).
  (b) Update all packages in dependency order. Commit changes to local working branches but do not push yet. Include version bumps in these commits.
  (c) Verify that all packages pass tests and documentation builds locally.
  (d) Starting from the most upstream package, push the branch, create a PR, and merge after CI passes. After each merge, register the new version to T4ARegistry using T4ARegistrator.jl. Then proceed to the next downstream package.
  
  **If a problem occurs during step (d)**: If any package fails CI or encounters issues during this phase, go back to step (a) for that package and all its downstream dependencies. Fix the issue locally and verify all affected packages pass tests before attempting to push again. Always strive to maintain local consistency before pushing to remote.
  
  **Note**: Do not commit Manifest.toml files. They are auto-generated and will be resolved correctly by CI and other environments based on Project.toml.

