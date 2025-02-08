module RegistryBrowser

export registrybrowser

using InteractiveUtils: less
using REPL.TerminalMenus: request, RadioMenu
import Pkg


"""
    registry_list(reg::AbstractString, args...)

List the packages in the registry `reg`.

`args` may be any of the following: `:name`, `:path`, `:uuid`, `:registry_path`.
If it is empty, `:name` is assumed.
"""
function registry_list(registryname::AbstractString, args...)
    fields = isempty(args) ? (:name, ) : args
    registries = Pkg.Registry.reachable_registries()
    for registry in registries
        if registry.name == registryname
            return sort([(length(fields) == 1 ? getfield(pkg.second, fields[1]) : [getfield(pkg.second, f) for f in fields]) for pkg in collect(registry.pkgs)])
        end
    end
    error("Registry $registryname is not reachable")
end

returnstr = "↶ Return"
modes = ["Package", "Versions", "Deps", "Compat", returnstr]

pick_one(msg, options; kwargs...) = (println(msg); RadioMenu(options; kwargs...) |> request)

function registrybrowser(packagepattern=""; registrypattern="")
    while true
        rregistries = filter(x->contains(x.name, registrypattern), Pkg.Registry.reachable_registries())
        registries = getfield.(rregistries, :name)
        pagesize = min(length(registries) + 1, max(2, displaysize(stdout)[1] - 1))
        iregistry = pick_one("Select registry (or 'q' to return):", vcat(registries, returnstr); pagesize)
        iregistry in [-1, length(registries) + 1] && break
        while true
            packages = filter(contains(packagepattern), registry_list(registries[iregistry]))
            pagesize = min(length(packages) + 1, max(2, displaysize(stdout)[1] - 1))
            ipackage = pick_one("Select package (or 'q' to return):", vcat(packages, returnstr); pagesize)
            ipackage in [-1, length(packages) + 1] && break
            package = packages[ipackage]
            while true
                mode = pick_one("Select desired info (or 'q' to return):", modes)
                mode in [-1, length(modes)] && break
                joinpath(splitdir(rregistries[iregistry].path)[1],
                         rregistries[iregistry].name,
                         package[1:1] |> uppercase,
                         package,
                         modes[mode] * ".toml"
                        ) |> less
            end
        end
    end
end

end # module RegistryBrowser
