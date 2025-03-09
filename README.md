# RegistryBrowser.jl

Interactively browse through [Julia](https://julialang.org) registries and
the packages that they contain.

## Installation

Run the following code in the [Julia](https://julialang.org) REPL:

```julia
using Pkg
pkg"add RegistryBrowser"
```

## Use

Call the `registrybrowser` function with optional pattern arguments for
registry and package names, e.g.

```julia
using RegistryBrowser

registrybrowser(r"^Linear"; registrypattern="General")
```

Hereafter an intuitive interactive browser will be displayed in the terminal.

For each package one can choose to either display locally cached information
(which includes name, uuid, url, versions, dependencies and compatibility
constraints) or to fetch some key information from the online repository
(the last entry in the commit log of the default branch and the `README.md`
file of the default branch).

The local cache can be updated with

```julia
using Pkg
pkg"registry update"
```

Viewing information from the online repository is only possible if `git`
version 2.25 or higher is installed. This can be checked from the REPL with

```julia
run(`git --version`)
```

## Feedback

Please submit bug reports and enhancement/feature requests on the
[issues page](https://github.com/GHTaarn/RegistryBrowser.jl/issues)
or as
[pull requests](https://github.com/GHTaarn/RegistryBrowser.jl/pulls).

