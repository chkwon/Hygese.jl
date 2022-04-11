


function solve_cvrp(cvrp::CVRP, parameters=AlgorithmParameters(); maximum_number_of_vehicles=typemax(Cint), verbose=true, use_dist_mtx=false, round=true)
    n = cvrp.dimension
    x = cvrp.coordinates[:, 1]
    y = cvrp.coordinates[:, 2]
    dem = cvrp.demand
    vehicleCapacity = cvrp.capacity
    
    if cvrp.distance < Inf 
        isDurationConstraint = true
        duration_limit = cvrp.distance
    else
        isDurationConstraint = false
        duration_limit = DBL_MAX
    end    

    serv_time = ones(size(x)) .* cvrp.service_time
    serv_time[1] = 0.0

    if use_dist_mtx
        dist_mtx = zeros(n, n)
        for i in 1:n, j in 1:n
            dist_mtx[i, j] = cvrp.weights[i, j]
        end
        # need to input dist_mtx' instead of dist_mtx
        # Julia: column-major indexing
        # C: row-major indexing
        return c_api_solve_cvrp_dist_mtx(
            n, x, y, Matrix(dist_mtx'), serv_time, dem, 
            vehicleCapacity, duration_limit, isDurationConstraint, 
            maximum_number_of_vehicles, parameters, verbose
        )
    else
        return c_api_solve_cvrp(
            n, x, y, serv_time, dem, 
            vehicleCapacity, duration_limit, round, isDurationConstraint,
            maximum_number_of_vehicles, parameters, verbose)
    end
end


function solve_cvrp(
    x::Vector, y::Vector, service_time::Vector, demand::Vector, 
    vehicle_capacity::Real, n_vehicles::Integer, 
    parameters=AlgorithmParameters(); 
    verbose=true, duration_limit=Inf, round=true
)
    @assert length(x) == length(y) == length(service_time) == length(demand)

    if duration_limit < Inf
        isDurationConstraint = true
    else
        isDurationConstraint = false
        duration_limit = DBL_MAX 
    end

    return c_api_solve_cvrp(
        length(demand), x, y, service_time, demand, 
        vehicle_capacity, duration_limit, round, isDurationConstraint,
        n_vehicles, parameters, verbose
    )
end

function solve_cvrp(
    dist_mtx::Matrix, service_time::Vector, demand::Vector, 
    vehicle_capacity::Real, n_vehicles::Integer, 
    parameters=AlgorithmParameters(); 
    verbose=true, duration_limit=Inf,
    x_coordinates=Float64[], y_coordinates=Float64[]
)

    if length(x_coordinates) == 0 && length(y_coordinates) == 0
        @assert length(service_time) == length(demand)
    else
        @assert length(x_coordinates) == length(y_coordinates) == length(service_time) == length(demand)
    end
    
    if duration_limit < Inf
        isDurationConstraint = true
    else
        isDurationConstraint = false
        duration_limit = DBL_MAX 
    end

    return c_api_solve_cvrp_dist_mtx(
        length(demand), x_coordinates, y_coordinates, Matrix(dist_mtx'), service_time, demand, 
        vehicle_capacity, duration_limit, isDurationConstraint,
        n_vehicles, parameters, verbose
    )
end

