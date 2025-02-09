module RegistryBrowser

export registrybrowser

using InteractiveUtils: less
using REPL.TerminalMenus: request, RadioMenu
import Pkg

returnstr = "↶ Return"
modes = ["Package", "Versions", "Deps", "Compat", returnstr]

pick_one(msg, options; kwargs...) = (println(msg); RadioMenu(options; kwargs...) |> request)

"""
    registrybrowser(packagepattern=""; registrypattern="")

Launch an interactive browser in the terminal, making it possible to look
through all registries that are available to the Julia session and get
information about all packages in these registries.

Calling this function with a `packagepattern` restricts the shown packages
to packages whose names match `packagepattern`. Similarly, only registries
whose names match `registrypattern` will be shown. `packagepattern` and
`registrypattern` can be of either `AbstractString` or `Regex` type.
"""
function registrybrowser(packagepattern=""; registrypattern="")
    while true
        registries = filter(x->contains(x.name, registrypattern), Pkg.Registry.reachable_registries())
        roptions = vcat(getfield.(registries, :name), returnstr)
        pagesize = min(length(roptions), max(2, displaysize(stdout)[1] - 1))
        iregistry = pick_one("Select registry (or 'q' to return):", roptions; pagesize)
        iregistry in [-1, length(roptions)] && break
        registry = registries[iregistry]
        while true
            packages = filter(contains(packagepattern), [p.name for p in values(registry.pkgs)]) |> sort
            pagesize = min(length(packages) + 1, max(2, displaysize(stdout)[1] - 1))
            ipackage = pick_one("Select package (or 'q' to return):", vcat(packages, returnstr); pagesize)
            ipackage in [-1, length(packages) + 1] && break
            package = packages[ipackage]
            mktemp() do path, io
                for mode in modes[1:end-1]
                    write(io, "#", "-"^77)
                    write(io, "\n#    $(registry.name) - $package - $mode.toml\n")
                    write(io, "#", "-"^77, "\n\n")
                    joinpath(splitdir(registry.path)[1],
                             registry.name,
                             package[1:1] |> uppercase,
                             package,
                             mode * ".toml"
                            ) |> read |> (x -> write(io, x))
                    write(io, "\n")
                end
                flush(io)
                less(path)
            end
        end
    end
end

end # module RegistryBrowser
