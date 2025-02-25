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
Only relatively basic information about the packages can be displayed, this
includes name, uuid, url, versions, dependencies and compatibility constraints.
Packages will not be downloaded or installed.

Also note that `registrybrowser` uses the locally cached registry information,
so if this is not sufficiently up to date, then the cache should first be
updated, e.g. with

```julia
using Pkg
pkg"registry update"
```

## Feedback

Please submit bug reports and enhancement/feature requests on the
[issues page](https://github.com/GHTaarn/RegistryBrowser.jl/issues)
or as
[pull requests](https://github.com/GHTaarn/RegistryBrowser.jl/pulls).

