module Pkg2

struct PkgError <: Exception
    msg::AbstractString
    ex::Nullable{Exception}
end
PkgError(msg::AbstractString) = PkgError(msg, Nullable{Exception}())
function Base.showerror(io::IO, pkgerr::PkgError)
    print(io, pkgerr.msg)
    if !isnull(pkgerr.ex)
        pkgex = get(pkgerr.ex)
        if isa(pkgex, CompositeException)
            for cex in pkgex
                print(io, "\n=> ")
                showerror(io, cex)
            end
        else
            print(io, "\n")
            showerror(io, pkgex)
        end
    end
end

# DIR
const DIR_NAME = ".julia"
_pkgroot() = abspath(get(ENV,"JULIA_PKGDIR",joinpath(homedir(),DIR_NAME)))
isversioned(p::AbstractString) = ((x,y) = (VERSION.major, VERSION.minor); basename(p) == "v$x.$y")

function dir()
    b = _pkgroot()
    x, y = VERSION.major, VERSION.minor
    d = joinpath(b,"v$x.$y")
    if isdir(d) || !isdir(b) || !isdir(joinpath(b, "METADATA"))
        return d
    end
    return b
end
dir(pkg::AbstractString...) = normpath(dir(),pkg...)

include("types.jl")
include("reqs.jl")
include("query.jl")
# include("read.jl")
include("resolve.jl")


end
