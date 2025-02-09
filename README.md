# RegistryBrowser

Interactively browse through registries and the packages that they contain.

## Installation

```julia
using Pkg
pkg"add http://github.com/GHTaarn/RegistryBrowser.jl"
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

# Feedback

Please submit bug reports and feature requests to
https://github.com/GHTaarn/RegistryBrowser.jl/issues
or
https://github.com/GHTaarn/RegistryBrowser.jl/pulls

