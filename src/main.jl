using CVRPLIB, TSPLIB 

# Write your package code here.
include("../deps/deps.jl") # const LIBHGSCVRP
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