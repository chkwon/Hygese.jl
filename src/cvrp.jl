
function solve_cvrp(
    cvrp::CVRP, parameters=AlgorithmParameters(); 
    n_vehicles=C_INT_MAX, 
    verbose=true, use_dist_mtx=false, round=true
)
    n = cvrp.dimension
    x = cvrp.coordinates[:, 1]
    y = cvrp.coordinates[:, 2]
    demands = cvrp.demand
    vehicle_capacity = cvrp.capacity
    
    if cvrp.distance < Inf 
        isDurationConstraint = true
        duration_limit = cvrp.distance
    else
        isDurationConstraint = false
        duration_limit = C_DBL_MAX
    end    

    service_times = ones(size(x)) .* cvrp.service_time
    service_times[1] = 0.0

    if use_dist_mtx
        dist_mtx = zeros(n, n)
        for i in 1:n, j in 1:n
            dist_mtx[i, j] = cvrp.weights[i, j]
        end
        # need to input dist_mtx' instead of dist_mtx
        # Julia: column-major indexing
        # C: row-major indexing
        return c_api_solve_cvrp_dist_mtx(
            n, x, y, Matrix(dist_mtx'), service_times, demands, 
            vehicle_capacity, duration_limit, isDurationConstraint, 
            n_vehicles, parameters, verbose
        )
    else
        return c_api_solve_cvrp(
            n, x, y, service_times, demands, 
            vehicle_capacity, duration_limit, round, isDurationConstraint,
            n_vehicles, parameters, verbose)
    end
end


function solve_cvrp(
    x::Vector, y::Vector, demands::Vector, 
    vehicle_capacity::Real, 
    parameters=AlgorithmParameters(); 
    verbose=true, 
    round=true,  
    service_times=zeros(length(demands)), 
    duration_limit=Inf, 
    n_vehicles=C_INT_MAX
)
    @assert length(x) == length(y) == length(service_times) == length(demands)

    if duration_limit < Inf
        isDurationConstraint = true
    else
        isDurationConstraint = false
        duration_limit = C_DBL_MAX 
    end

    return c_api_solve_cvrp(
        length(demands), x, y, service_times, demands, 
        vehicle_capacity, duration_limit, round, isDurationConstraint,
        n_vehicles, parameters, verbose
    )
end

function solve_cvrp(
    dist_mtx::Matrix, demands::Vector, vehicle_capacity::Real, 
    parameters=AlgorithmParameters(); 
    verbose=true, 
    x_coordinates=Float64[], 
    y_coordinates=Float64[], 
    service_times=zeros(length(demands)), 
    duration_limit=Inf,
    n_vehicles=C_INT_MAX
)

    if length(x_coordinates) == 0 && length(y_coordinates) == 0
        @assert length(service_times) == length(demands)
    else
        @assert length(x_coordinates) == length(y_coordinates) == length(service_times) == length(demands)
    end
    
    if duration_limit < Inf
        isDurationConstraint = true
    else
        isDurationConstraint = false
        duration_limit = C_DBL_MAX 
    end

    return c_api_solve_cvrp_dist_mtx(
        length(demands), x_coordinates, y_coordinates, Matrix(dist_mtx'), service_times, demands, 
        vehicle_capacity, duration_limit, isDurationConstraint,
        n_vehicles, parameters, verbose
    )
end

