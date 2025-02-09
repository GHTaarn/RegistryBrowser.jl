module RegistryBrowser

export registrybrowser

using InteractiveUtils: less
using REPL.TerminalMenus: request, RadioMenu
import Pkg

returnstr = "↶ Return"
modes = ["Package", "Versions", "Deps", "Compat", returnstr]

pick_one(msg, options; kwargs...) = (println(msg); RadioMenu(options; kwargs...) |> request)

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
            while true
                mode = pick_one("Select desired info (or 'q' to return):", modes)
                mode in [-1, length(modes)] && break
                joinpath(splitdir(registry.path)[1],
                         registry.name,
                         package[1:1] |> uppercase,
                         package,
                         modes[mode] * ".toml"
                        ) |> less
            end
        end
    end
end

end # module RegistryBrowser
