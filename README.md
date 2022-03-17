# Hygese.jl 

[![Build Status](https://github.com/chkwon/Hygese.jl/workflows/CI/badge.svg?branch=master)](https://github.com/chkwon/Hygese.jl/actions?query=workflow%3ACI)
[![codecov](https://codecov.io/gh/chkwon/Hygese.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/chkwon/Hygese.jl)

**A solver for the Capacitated Vehicle Routing Problem (CVRP)**

This package provides a simple Julia wrapper for the [HGS-CVRP](https://github.com/vidalt/HGS-CVRP) solver through [its C interface](https://github.com/chkwon/HGS-CVRP).

This package requires a C++ compiler and `cmake` installed on your computer.

Install:
```julia
] add https://github.com/chkwon/Hygese.jl
```

Use:
```julia
using Hygese
ap = AlgorithmParameters(timeLimit=1.3, seedRNG=3) # timeLimit in seconds, seedRNG is the seed for random values.
result = solve_cvrp(<path_to_vrp_file>; verbose=true) # verbose=false to turn off all outputs
```
- `result.cost` = the total cost of routes
- `result.time` = the computational time taken by HGS
- `results.routes` = the list of visited customers by each route, not including the depot (index 1). 
In the [CVRPLIB](http://vrp.atd-lab.inf.puc-rio.br/index.php/en/) instances, the node numbering starts from `1`, and the depot is typically node `1`.  However, the solution reported in CVRPLIB uses numbering starts from `0`. 

For example, [`P-n19-k2`](http://vrp.atd-lab.inf.puc-rio.br/media/com_vrp/instances/P/P-n19-k2.vrp) instance has the following nodes:
```
1 30 40
2 37 52
3 49 43
4 52 64
5 31 62
6 52 33
7 42 41
8 52 41
9 57 58
10 62 42
11 42 57
12 27 68
13 43 67
14 58 27
15 37 69
16 61 33
17 62 63
18 63 69
19 45 35
```
and the depot is node `1`.  But the [solution reported](http://vrp.atd-lab.inf.puc-rio.br/media/com_vrp/instances/P/P-n19-k2.sol) is:
```
Route #1: 4 11 14 12 3 17 16 8 6 
Route #2: 18 5 13 15 9 7 2 10 1 
Cost 212
```
The last element `1` in Route #2 above represents the node number `2` with coordinate `(37, 52)`. 

This package returns `visited_customers` with the original node numbering.
For the above example, 
```julia 
using Hygese, CVRPLIB
inst_name = "P-n19-k2"
cvrp, cvrp_file, cvrp_sol_file = CVRPLIB.readCVRP(inst_name)
result = solve_cvrp(cvrp)
```
returns 
```julia
julia> result.routes
2-element Vector{Vector{Int64}}:
 [19, 6, 14, 16, 10, 8, 3, 11, 2]
 [7, 9, 17, 18, 4, 13, 15, 12, 5]
```
To retrieve the CVRPLIB solution reporting format: 
```julia
julia> reporting(result.routes)
2-element Vector{Vector{Int64}}:
 [18, 5, 13, 15, 9, 7, 2, 10, 1]
 [6, 8, 16, 17, 3, 12, 14, 11, 4]
```


## CVRP interfaces

In all data the first element is for the depot.
- `x` = x coordinates of nodes, size of `n`
- `y` = x coordinates of nodes, size of `n`
- `dist_mtx` = the distance matrix, size of `n` by `n`.
- `service_time` = service time in each node 
- `demand` = the demand in each node
- `vehicle_capacity` = the capacity of the vehicles
- `n_vehicles` = the maximum number of available vehicles

Three possibilities:
- Only by the x, y coordinates. The Euclidean distances are used. 
```julia
ap = AlgorithmParameters(timeLimit=3.2) # seconds
result = solve_cvrp(x, y, service_time, demand, vehicle_capacity, n_vehicles, ap; verbose=true)
```
- Only by the distance matrix.
```julia
ap = AlgorithmParameters(timeLimit=3.2) # seconds
result = solve_cvrp(dist_mtx, service_time, demand, vehicle_capacity, n_vehicles, ap; verbose=true)
```
- Using the distance matrix, with optional x, y coordinate information. The objective function is calculated based on the distance matrix, but the x, y coordinates just provide some helpful information. The distance matrix may not be consistent with the coordinates. 
```julia
ap = AlgorithmParameters(timeLimit=3.2) # seconds
result = solve_cvrp(dist_mtx, service_time, demand, vehicle_capacity, n_vehicles, ap; x_coords=x, y_coords=y, verbose=true)
```

## TSP interfaces 

As TSP is a special case of CVRP, the same solver can be used for solving TSP. 

The following interfaces are provided:

- Reading `.tsp` or `.atsp` files via `TSPLIB.jl`:
```julia
tsp = TSPLIB.readTSP("br17.atsp")
ap = AlgorithmParameters(timeLimit=1.2)
result = solve_tsp(tsp, ap; use_dist_mtx=true)
```

- By the coordinates, by the distance matrix, or by both:
```julia
result1 = solve_tsp(x, y, ap)
result2 = solve_tsp(dist_mtx, ap)
result3 = solve_tsp(dist_mtx, ap; x_coords=x, y_coords=y)
```

## AlgorithmParamters

The paramters for the HGS algorithm with default values are:
```julia
Base.@kwdef mutable struct AlgorithmParameters
    nbGranular :: Cint = 20
    mu :: Cint = 25
    lambda :: Cint = 40
    nbElite :: Cint = 4
    nbClose :: Cint = 5
    targetFeasible :: Cdouble = 0.2
    penaltyIncrease :: Cdouble = 1.20
    penaltyDecrease :: Cdouble = 0.85
    repairProb :: Cdouble = 0.5
    seedRNG :: Cint = 0
    nbIter :: Cint = 20000
    timeLimit :: Cdouble = Cdouble(typemax(Cint))
    isRoundingInteger :: Cchar = 1
end
```

## Related Packages
- [CVRPLIB.jl](https://github.com/chkwon/CVRPLIB.jl)
- [TSPLIB.jl](https://github.com/matago/TSPLIB.jl)
- [LKH.jl](https://github.com/chkwon/LKH.jl)
- [Concorde.jl](https://github.com/chkwon/Concorde.jl)


- [hygese](https://github.com/chkwon/hygese): A Python wrapper for HGS-CVRP
