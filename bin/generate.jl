#!/usr/bin/env julia

function write_toml(f::Function, names::String...)
    path = joinpath(names...) * ".toml"
    mkpath(dirname(path))
    open(path, "w") do io
        f(io)
    end
end

toml_key(str::String) = ismatch(r"[^\w-]", str) ? repr(str) : str
toml_key(strs::String...) = join(map(toml_key, [strs...]), '.')

prefix = joinpath(homedir(), ".julia", "registries", "Uncurated")

write_toml(prefix, "registry") do io
    repo = "https://github.com/JuliaRegistries/Uncurated.git"
    uuid = string(uuid5(uuid_registry, repo))
    println(io, "name = ", repr("Uncurated"))
    println(io, "uuid = ", repr(uuid))
    println(io, "repo = ", repr(repo))
    println(io, "description = \"\"\"")
    print(io, """
        Official uncurated Julia package registry where people can
        register any package they want without too much debate about
        naming and without enforced standards on documentation or
        testing. We nevertheless encourage documentation, testing and
        some amount of consideration when choosing package names.
        """)
    println(io, "\"\"\"")
end

write_toml(prefix, "packages") do io
    for (pkg, p) in sort!(collect(pkgs), by=(p->p.uuid.value)∘last)
        println(io, p.uuid, " = ", repr(pkg))
    end
end

buckets = Dict()
for (pkg, p) in pkgs
    bucket = string(uppercase(first(pkg)))
    push!(get!(buckets, bucket, []), (pkg, p))
end

for (bucket, b_pkgs) in buckets
    for (pkg, p) in b_pkgs
        write_toml(prefix, bucket, pkg, "package") do io
            println(io, "name = ", repr(pkg))
            println(io, "uuid = ", repr(string(p.uuid)))
            println(io, "repo = ", repr(p.url))
        end
        write_toml(prefix, bucket, pkg, "versions") do io
            for (i, (ver, v)) in enumerate(sort!(collect(p.versions), by=first))
                i > 1 && println(io)
                println(io, "[", toml_key(string(ver)), "]")
                println(io, "hash-sha1 = ", repr(v.sha1))
            end
        end
    end
end
