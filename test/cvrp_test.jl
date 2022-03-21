
@testset "P-n19-k2 by coordinates" begin
    cvrp, _, _ = CVRPLIB.readCVRPLIB("P-n19-k2")
    ap = AlgorithmParameters(timeLimit=1.8)
    result = solve_cvrp(cvrp, ap; verbose=true)
    @test result.cost <= 212 * 1.01
end

@testset "P-n19-k2 by dist_mtx with coordinates" begin
    cvrp, _, _ = CVRPLIB.readCVRPLIB("P-n19-k2")
    ap = AlgorithmParameters(timeLimit=2.1)
    result = solve_cvrp(cvrp, ap; verbose=true, use_dist_mtx=true)
    @test result.cost <= 212 * 1.01
end

@testset "P-n19-k2 by dist_mtx without coordinates" begin
    cvrp, _, _ = CVRPLIB.readCVRPLIB("P-n19-k2")
    cvrp.coordinates = zeros(size(cvrp.coordinates))
    ap = AlgorithmParameters(timeLimit=1.23)
    result = solve_cvrp(cvrp, ap; verbose=true, use_dist_mtx=true)
    @test result.cost <= 212 * 1.01
end

@testset "X-n101-k25" begin
    cvrp, _, _ = CVRPLIB.readCVRPLIB("X-n101-k25")

    ap = AlgorithmParameters(timeLimit=3)
    result = solve_cvrp(cvrp, ap; verbose=true)

    @show result.cost
    @show result.time
    visited_customers = result.routes

    @show typeof(visited_customers), size(visited_customers)

    report_visited_customers = reporting(visited_customers)
    for i in eachindex(report_visited_customers)
        @test report_visited_customers[i] == visited_customers[i] .- 1 
    end
end    


@testset "A-n32-k5.vrp file read" begin
    cvrp = CVRPLIB.readCVRP("A-n32-k5.vrp")
    ap = AlgorithmParameters(timeLimit=2.3)
    result = solve_cvrp(cvrp, ap; verbose=true)
    @test result.cost <= 784 * 1.01

    result = solve_cvrp("A-n32-k5.vrp", ap)
    @test result.cost <= 784 * 1.01
end

@testset "x, y, dist_mtx CVRP" begin
    cvrp, _, _ = CVRPLIB.readCVRPLIB("A-n32-k5")
    x = cvrp.coordinates[:, 1]
    y = cvrp.coordinates[:, 2]
    dist_mtx = cvrp.weights
    service_time = zeros(cvrp.dimension)
    demand = cvrp.demand
    capacity = cvrp.capacity
    n_vehicles = 5

    ap = AlgorithmParameters(timeLimit=1.8)

    result1 = solve_cvrp(x, y, service_time, demand, cvrp.capacity, n_vehicles, ap; verbose=true)
    result2 = solve_cvrp(dist_mtx, service_time, demand, cvrp.capacity, n_vehicles, ap; verbose=true)
    result3 = solve_cvrp(dist_mtx, service_time, demand, cvrp.capacity, n_vehicles, ap; x_coordinates=x, y_coordinates=y, verbose=true)

    @test result1.cost == result2.cost == result3.cost
end


@testset "dictionary CVRP" begin
    cvrp, _, _ = CVRPLIB.readCVRPLIB("A-n32-k5")
    x = cvrp.coordinates[:, 1]
    y = cvrp.coordinates[:, 2]
    dist_mtx = cvrp.weights
    service_time = zeros(cvrp.dimension)
    demand = cvrp.demand
    capacity = cvrp.capacity
    n_vehicles = 5

    data = Dict()
    data["distance_matrix"] = dist_mtx 
    data["demands"] = demand
    data["vehicle_capacity"] = capacity
    data["num_vehicles"] = n_vehicles

    ap = AlgorithmParameters(timeLimit=1.8)

    result1 = solve_cvrp(data, ap; verbose=false)

    data["service_times"] = service_time 
    result2 = solve_cvrp(data, ap; verbose=false)

    data["x_coordinates"] = x 
    data["y_coordinates"] = y
    result3 = solve_cvrp(data, ap; verbose=false)

    delete!(data, "distance_matrix")
    result4 = solve_cvrp(data, ap; verbose=false)

    result5 = solve_cvrp(data; verbose=false)

    @test result1.cost == result2.cost == result3.cost == result4.cost == result5.cost



    delete!(data, "y_coordinates")
    @test_broken solve_cvrp(data; verbose=false)

    delete!(data, "x_coordinates")
    @test_broken solve_cvrp(data; verbose=false)
end