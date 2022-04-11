
function solve_tsp(tsp::TSP, parameters=AlgorithmParameters(); verbose=true, use_dist_mtx=false)
    n = tsp.dimension
    x = tsp.nodes[:, 1]
    y = tsp.nodes[:, 2]
    serv_time = zeros(size(x))
    dem = ones(size(x))
    dem[1] = 0.0

    vehicleCapacity = n
    maximum_number_of_vehicles = 1
    

    isRoundingInteger = true
    isDurationConstraint = false
    duration_limit = DBL_MAX

    if use_dist_mtx
        c_dist_mtx = Matrix(tsp.weights')
        for i in 1:n
            c_dist_mtx[i, i] = 0.0
        end
        # need to input dist_mtx' instead of dist_mtx
        # Julia: column-first indexing
        # C: row-first indexing
        return c_api_solve_cvrp_dist_mtx(
            n, x, y, c_dist_mtx, serv_time, dem, vehicleCapacity, duration_limit, isDurationConstraint,
            maximum_number_of_vehicles, parameters, verbose
        )
    else
        return c_api_solve_cvrp(
            n, x, y, serv_time, dem, 
            vehicleCapacity, duration_limit, isRoundingInteger, isDurationConstraint, maximum_number_of_vehicles, parameters, verbose
        )
    end
end


function solve_tsp(dist_mtx::Matrix, parameters=AlgorithmParameters(); verbose=true, x_coordinates=Float64[], y_coordinates=Float64[])
    n = size(dist_mtx, 1)

    serv_time = zeros(n)
    dem = ones(n)
    dem[1] = 0.0

    vehicleCapacity = n
    maximum_number_of_vehicles = 1
    
    c_dist_mtx = Matrix(dist_mtx')
    for i in 1:n
        c_dist_mtx[i, i] = 0.0
    end

    duration_limit = DBL_MAX
    isDurationConstraint = false 

    # need to input dist_mtx' instead of dist_mtx
    # Julia: column-first indexing
    # C: row-first indexing
    return c_api_solve_cvrp_dist_mtx(
        n, x_coordinates, y_coordinates, c_dist_mtx, serv_time, dem, 
        vehicleCapacity, duration_limit, isDurationConstraint,
        maximum_number_of_vehicles, parameters, verbose
    )
end
function solve_tsp(x::Vector, y:: Vector, parameters=AlgorithmParameters(); verbose=true)
    n = length(x)
    serv_time = zeros(n)
    dem = ones(n)
    dem[1] = 0.0
    vehicleCapacity = n
    maximum_number_of_vehicles = 1
    
    isRoundingInteger = true 
    duration_limit = DBL_MAX
    isDurationConstraint = false

    return c_api_solve_cvrp(
        n, x, y, serv_time, dem, 
        vehicleCapacity, duration_limit, isRoundingInteger, isDurationConstraint,
        maximum_number_of_vehicles, parameters, verbose
    )
end



