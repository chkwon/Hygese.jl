# # System Independent Types
# @assert Cint == Int32
# @assert Cdouble == Float64

# Must match with AlgorithmParameters.h in HGS-CVRP: https://github.com/vidalt/HGS-CVRP
Base.@kwdef mutable struct AlgorithmParameters
    nbGranular::Int32 = 20
    mu::Int32 = 25
    lambda::Int32 = 40
    nbElite::Int32 = 4
    nbClose::Int32 = 5
    targetFeasible::Float64 = 0.2
    seed::Int32 = 0
    nbIter::Int32 = 20000
    timeLimit::Float64 = 0.0
    useSwapStar::Int32 = 1 # 1 = true, 0 = false
end

mutable struct C_SolutionRoute
    length::Cint
    path::Ptr{Cint}
end

mutable struct C_Solution
    cost::Cdouble
    time::Cdouble
    n_routes::Cint
    routes::Ptr{C_SolutionRoute}
end

mutable struct RoutingSolution
    cost::Float64
    time::Float64
    routes::Vector{Vector{Int}}

    function RoutingSolution(sol_ptr::Ptr{C_Solution})
        sol = unsafe_load(sol_ptr)
        routes = Vector{Vector{Int}}(undef, sol.n_routes)
        for i in eachindex(routes)
            r = unsafe_load(sol.routes, i)
            path = unsafe_wrap(Array, r.path, r.length)
            routes[i] = unsafe_wrap(Array, r.path, r.length) .+ 1 # customer numbering offset
        end
        return new(sol.cost, sol.time, routes)
    end
end



function convert_destroy(c_sol_ptr::Ptr{C_Solution})
    # copy C structs to Julia structs
    j_sol = RoutingSolution(c_sol_ptr)

    # don't forget to delete pointers, important to avoid memory leaks
    ccall((:delete_solution, LIBHGSCVRP), Cvoid, (Ptr{C_Solution},), c_sol_ptr)

    return j_sol
end



"""
    function c_api_solve_cvrp(
        n::Integer,
        x::Vector,
        y::Vector,
        service_time::Vector,
        demand::Vector,
        vehicle_capacity::Float64,
        duration_limit::Float64,
        isRoundingInteger::Bool,
        isDurationConstraint::Bool,
        n_vehicles::Integer,
        parameters::AlgorithmParameters,
        verbose::Bool
    )

`x`, `y`, `service_time`, `demand` all require at least `n` elements.
Anything after `n` elements are ignored.

The first element should be the depot.
The next `n-1` elements should be customers.

"""
function c_api_solve_cvrp(
    n::Integer,
    x::Vector,
    y::Vector,
    service_time::Vector,
    demand::Vector,
    vehicle_capacity::Real,
    duration_limit::Real,
    isRoundingInteger::Bool,
    isDurationConstraint::Bool,
    n_vehicles::Integer,
    parameters::AlgorithmParameters,
    verbose::Bool
)

    @assert service_time[1] == 0.0
    @assert demand[1] == 0.0

    c_solution_ptr = ccall(
        (:solve_cvrp, LIBHGSCVRP),
        Ptr{C_Solution},
        (
            Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble},
            Cdouble, Cdouble, Cchar, Cchar,
            Cint, Ptr{AlgorithmParameters}, Cchar
        ),
        n, Cdouble.(x), Cdouble.(y), Cdouble.(service_time), Cdouble.(demand),
        vehicle_capacity, duration_limit, isRoundingInteger, isDurationConstraint,
        n_vehicles, Ref(parameters), verbose
    )

    return convert_destroy(c_solution_ptr)
end

function c_api_solve_cvrp_dist_mtx(
    n::Integer,
    x::Vector,
    y::Vector,
    dist_mtx::Matrix, # row-first matrix as in C
    service_time::Vector,
    demand::Vector,
    vehicle_capacity::Real,
    duration_limit::Real,
    isDurationConstraint::Bool,
    n_vehicles::Integer,
    parameters::AlgorithmParameters,
    verbose::Bool
)

    @assert service_time[1] == 0.0
    @assert demand[1] == 0.0

    if length(x) == length(y) == n
        x_ptr = Cdouble.(x)
        y_ptr = Cdouble.(y)
    else
        x_ptr = y_ptr = C_NULL
    end

    c_solution_ptr = ccall(
        (:solve_cvrp_dist_mtx, LIBHGSCVRP),
        Ptr{C_Solution},
        (
            Cint, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble},
            Cdouble, Cdouble, Cchar,
            Cint, Ptr{AlgorithmParameters}, Cchar
        ),
        n, x_ptr, y_ptr, Cdouble.(dist_mtx), Cdouble.(service_time), Cdouble.(demand),
        vehicle_capacity, duration_limit, isDurationConstraint,
        n_vehicles, Ref(parameters), verbose
    )

    return convert_destroy(c_solution_ptr)
end


