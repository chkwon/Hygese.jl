using CVRPLIB, TSPLIB 

# Write your package code here.
include("../deps/deps.jl") # const LIBHGSCVRP
include("c_api.jl")
include("cvrp.jl")
include("tsp.jl")

const DBL_MAX = floatmax(Cdouble)

function reporting(visited_customers)
    routes = deepcopy(visited_customers)
    for r in routes 
        r .-= 1 
    end 
    return routes
end 