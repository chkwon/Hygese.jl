

const version = "0.1.0"
const HGS_CVRP_SRC = "https://github.com/chkwon/HGS-CVRP/archive/v$(version).tar.gz"

const HGS_CVRP_WIN = "https://github.com/chkwon/HGS_CVRP_jll.jl/releases/download/HGS_CVRP-v0.1.0%2B0/libhgscvrp.v0.1.0.x86_64-w64-mingw32-cxx11.tar.gz"

const SRC_DIR = "HGS-CVRP-$version"

import BinDeps

function build_HGS()
    cd(SRC_DIR)
    mkdir("build")
    cd("build")
    run(`cmake -DCMAKE_BUILD_TYPE=Release ../`)
    run(`make hgscvrp`)

    return joinpath(@__DIR__, SRC_DIR, "build", "libhgscvrp")
end

function download_HGS_LIB_WIN()
    rm("win", recursive=true, force=true)
    mkdir("win")
    lib_tarball = joinpath(@__DIR__, "win", "hgs_win.tar.gz")
    download(HGS_CVRP_WIN, lib_tarball)
    cd("win")
    run(BinDeps.unpack_cmd(lib_tarball, ".", ".gz", ".tar"))

    return joinpath(@__DIR__, "win", "bin", "libhgscvrp")
end

function download_HGS()
    src_tarball = joinpath(@__DIR__, "hgs_cvrp.tar.gz")
    download(HGS_CVRP_SRC, src_tarball)
    rm(SRC_DIR, recursive=true, force=true)
    run(BinDeps.unpack_cmd(src_tarball, ".", ".gz", ".tar"))
end

function install_HGS()
    lib = get(ENV, "HGS_CVRP_SHARED_LIBRARY", nothing)
    if !haskey(ENV, "HGS_CVRP_SHARED_LIBRARY")
        if Sys.iswindows()
            lib = download_HGS_LIB_WIN()
        else
            download_HGS()
            lib = build_HGS()
        end
        ENV["HGS_CVRP_SHARED_LIBRARY"] = lib
    end

    if lib === nothing
        error("Environment variable `HGS_CVRP_SHARED_LIBRARY` not found.")
    else
        # pr2392 = joinpath(@__DIR__, LKH_VERSION, "pr2392.par")
        # run(`$(executable) $(pr2392)`)
    end

    open(joinpath(@__DIR__, "deps.jl"), "w") do io
        write(io, "const LIBHGSCVRP = \"$(escape_string(lib))\"\n")
    end
end

install_HGS()

