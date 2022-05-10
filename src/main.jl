using CVRPLIB, TSPLIB 
using HGSCVRP_jll

const LIBHGSCVRP = HGSCVRP_jll.get_libhgscvrp_path()

include("c_api.jl")
include("cvrp.jl")
include("tsp.jl")

const C_DBL_MAX = floatmax(Cdouble)
const C_INT_MAX = typemax(Cint)

function reporting(visited_customers)
    routes = deepcopy(visited_customers)
    for r in routes 
        r .-= 1 
    end 
    return routes
end 