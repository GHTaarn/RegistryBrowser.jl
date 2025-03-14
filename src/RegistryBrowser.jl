module RegistryBrowser

export registrybrowser

using TerminalPager: pager
using REPL.TerminalMenus: request, RadioMenu
using CodecZlib: GzipDecompressorStream
import Markdown, Pkg, TOML, Tar

const returnstr = "↶ Return"
const subsections = ["Package", "Versions", "Deps", "Compat"]
const pkgviewoptions = ["Locally cached information", "Last commit & README"]


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
    tmpdir = Dict{String,String}()
    cursor = Dict{AbstractVector{<:AbstractString},Int64}()

    pick_one(msg, options) = begin
        options = vcat(options, returnstr)
        pagesize = min(length(options), max(2, displaysize(stdout)[1] - 1))
        haskey(cursor, options) || (cursor[options] = 1)
        println(msg, " (or 'q' to return):")
        isel = request(RadioMenu(options; pagesize); cursor=cursor[options])
        if 1 <= isel < length(options)
            cursor[options] = isel
            return isel
        else
            return -1
        end
    end

    while true
        registries = filter(x->contains(x.name, registrypattern), Pkg.Registry.reachable_registries())
        if isempty(registries)
            println("No matching registries found")
            break
        end
        roptions = getfield.(registries, :name)
        iregistry = pick_one("Select registry", roptions)
        iregistry == -1 && break
        registry = registries[iregistry]
        registrypath = if isdir(registry.path)
            registry.path
        else
            if !haskey(tmpdir, registry.name)
                toml = TOML.parsefile(registry.path)
                tgzfile = joinpath(splitdir(registry.path)[1], toml["path"])
                tmpdir[registry.name] = open(Tar.extract ∘ GzipDecompressorStream, tgzfile)
            end
            tmpdir[registry.name]
        end
        while true
            packages = filter(contains(packagepattern), [p.name for p in values(registry.pkgs)]) |> sort
            ipackage = pick_one("Select package", packages)
            ipackage == -1 && break
            while true
                iaction = pick_one("Select what to display", pkgviewoptions)
                if iaction == 1
                    displaypackage(registry, packages[ipackage]; registrypath)
                elseif iaction == 2
                    displaypackageclone(registry, packages[ipackage]; registrypath)
                else
                    break
                end
            end
        end
    end
    foreach(d->rm(d; recursive=true), values(tmpdir))
end

function displaypackage(registry, package; registrypath)
    dirpath = joinpath(registrypath,
                       endswith(package, "_jll") ? "jll" : "",
                       package[1:1] |> uppercase,
                       package)
    io = IOBuffer()
    if isdir(dirpath)
        for sect in subsections
            write(io, "#", "-"^77)
            write(io, "\n#    $(registry.name) - $package - $sect.toml\n")
            write(io, "#", "-"^77, "\n\n")
            joinpath(dirpath,
                     sect * ".toml"
                    ) |> read |> (x -> write(io, x))
            write(io, "\n")
        end
    else
        uuid = filter(pp->pp.name==package, [(; p.name, p.uuid) for p in values(registry.pkgs)])[1].uuid
        println(io, "\n#", "-"^55)
        println(io, "#    Registry: $(registry.name), Package: $package")
        println(io, "#", "-"^55, "\n")
        println(io, "name = \"$package\"")
        println(io, "uuid = \"$uuid\"")
    end
    flush(io)
    seekstart(io)
    read(io, String) |> pager
end

function displaypackageclone(registry, package; registrypath)
    try
        tompath = joinpath(registrypath,
                           endswith(package, "_jll") ? "jll" : "",
                           package[1:1] |> uppercase,
                           package,
                           "Package.toml"
                          )
        repo = TOML.parse(read(tompath, String))["repo"]
        mktempdir() do tmppath
            run(`git clone --sparse --depth 1 $repo $tmppath`)
            lastlog = let iolog = IOBuffer()
                run(Cmd(`git log`; dir=tmppath), stdin, iolog, iolog)
                flush(iolog)
                seekstart(iolog)
                read(iolog, String)
            end
            "(Last commit on default branch)\n" *
            "```\n" *
            replace(lastlog, "```" => "(3 backticks)") *
            "\n```\n" *
            "---\n" *
            "(README.md from default branch)\n\n" *
            read(joinpath(tmppath, "README.md"), String) |> Markdown.parse |> pager
        end
    catch e1
        println(e1)
        print("Press return to continue")
        readline()
    end
end

end # module RegistryBrowser
