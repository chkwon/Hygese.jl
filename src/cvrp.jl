


function solve_cvrp(cvrp::CVRP, parameters=AlgorithmParameters(); maximum_number_of_vehicles=typemax(Cint), verbose=true, use_dist_mtx=false)
    n = cvrp.dimension
    x = cvrp.coordinates[:, 1]
    y = cvrp.coordinates[:, 2]
    serv_time = zeros(size(x))
    dem = cvrp.demand
    vehicleCapacity = cvrp.capacity

    if use_dist_mtx
        dist_mtx = zeros(n, n)
        for i in 1:n, j in 1:n
            dist_mtx[i, j] = cvrp.weights[i, j]
        end
        # need to input dist_mtx' instead of dist_mtx
        # Julia: column-first indexing
        # C: row-first indexing
        return c_api_solve_cvrp_dist_mtx(n, x, y, Matrix(dist_mtx'), serv_time, dem, vehicleCapacity, maximum_number_of_vehicles, parameters, verbose)
    else
        return c_api_solve_cvrp(n, x, y, serv_time, dem, vehicleCapacity, maximum_number_of_vehicles, parameters, verbose)
    end
end

function solve_cvrp(cvrp_file_path::AbstractString, parameters=AlgorithmParameters(); maximum_number_of_vehicles=typemax(Cint), verbose=true)
    cvrp = CVRPLIB.readCVRP(cvrp_file_path)
    return solve_cvrp(cvrp, parameters; maximum_number_of_vehicles=maximum_number_of_vehicles, verbose=verbose, use_dist_mtx=true)
end

function solve_cvrp(x::Vector, y::Vector, service_time::Vector, demand::Vector, vehicle_capacity::Integer, n_vehicles::Integer, parameters=AlgorithmParameters(); verbose=true)
    @assert length(x) == length(y) == length(service_time) == length(demand)
    return c_api_solve_cvrp(length(x), x, y, service_time, demand, vehicle_capacity, n_vehicles, parameters, verbose)
end

function solve_cvrp(
    dist_mtx::Matrix, service_time::Vector, demand::Vector, vehicle_capacity::Integer, n_vehicles::Integer, parameters=AlgorithmParameters(); 
    verbose=true, x_coords=zeros(length(demand)), y_coords=zeros(length(demand))
)
    @assert length(x_coords) == length(y_coords) == length(service_time) == length(demand)
    return c_api_solve_cvrp_dist_mtx(length(x_coords), x_coords, y_coords, Matrix(dist_mtx'), service_time, demand, vehicle_capacity, n_vehicles, parameters, verbose)
end


# const CVRP_KEYS = Dict(
#     "distance_matrix" => Matrix{Real},
#     "num_vehicles" => Integer,
#     "demands" => Vector{Real},
#     "vehicle_capacity" => Integer,
#     "service_times" => Vector{Real},
#     "x_coordinates" => Vector{Real},
#     "y_coordinates" => Vector{Real}
# )

function solve_cvrp(data::Dict, parameters=AlgorithmParameters(); verbose=true)
    use_dist_mtx = haskey(data, "distance_matrix")
    has_coordinates = haskey(data, "x_coordinates") && haskey(data, "y_coordinates")

    if !use_dist_mtx && !has_coordinates 
        error("Insufficient data input. Either coordinates or a distance matrix must be provided.")
    end

    n = use_dist_mtx ? size(data["distance_matrix"], 1) : length(data["x_coordinates"])
    service_time = get(data, "service_times", zeros(n)) 

    if !use_dist_mtx
        return solve_cvrp(
            data["x_coordinates"] :: Vector, 
            data["y_coordinates"] :: Vector, 
            service_time :: Vector,
            data["demands"] :: Vector, 
            data["vehicle_capacity"] :: Integer, 
            data["num_vehicles"] :: Integer, 
            parameters; 
            verbose=verbose
        )
    else 
        if has_coordinates 
            return solve_cvrp(
                data["distance_matrix"] :: Matrix, 
                service_time :: Vector,
                data["demands"] :: Vector, 
                data["vehicle_capacity"] :: Integer, 
                data["num_vehicles"] :: Integer, 
                parameters; 
                verbose=verbose,
                x_coords = data["x_coordinates"],
                y_coords = data["y_coordinates"]
            )
    
        else
            return solve_cvrp(
                data["distance_matrix"] :: Matrix, 
                service_time :: Vector,
                data["demands"] :: Vector, 
                data["vehicle_capacity"] :: Integer, 
                data["num_vehicles"] :: Integer, 
                parameters; 
                verbose=verbose
            )
        end    
    end
end