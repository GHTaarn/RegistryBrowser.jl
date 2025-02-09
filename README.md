# RegistryBrowser

Interactively browse through [Julia](https://julialang.org) registries and
the packages that they contain.

## Installation

Run the following code in the [Julia](https://julialang.org) REPL:

```julia
using Pkg
pkg"add https://github.com/GHTaarn/RegistryBrowser.jl"
```

## Use

Call the `registrybrowser` function with optional pattern arguments for
registry and package names, e.g.

```julia
using RegistryBrowser

registrybrowser(r"^Linear"; registrypattern="General")
```

Hereafter an intuitive interactive browser will be displayed in the terminal.
Only relatively basic information about the packages can be displayed, this
includes name, uuid, url, versions, dependencies and compatibility constraints.
Packages will not be downloaded or installed.

## Feedback

Please submit bug reports and feature requests to
https://github.com/GHTaarn/RegistryBrowser.jl/issues
or
https://github.com/GHTaarn/RegistryBrowser.jl/pulls

