@testset "durations" begin
    cvrp, _, _ = CVRPLIB.readCVRPLIB("CMT6")
    ap = AlgorithmParameters(timeLimit=3)
    result = solve_cvrp(cvrp, ap, verbose=true, use_dist_mtx=false, round=false)
    @show result.cost
    @test result.cost ≈ 555.43 atol=1e-2

    cvrp, _, _ = CVRPLIB.readCVRPLIB("CMT7")
    service_time = cvrp.service_time .* ones(cvrp.dimension)
    service_time[1] = 0.0
    ap = AlgorithmParameters(timeLimit=3)

    result = solve_cvrp(
        cvrp.coordinates[:, 1],
        cvrp.coordinates[:, 2],
        service_time,
        cvrp.demand,
        cvrp.capacity,
        typemax(Cint),
        ap,
        verbose=true,
        duration_limit = cvrp.distance,
        round=false
    )
    @show result.cost    
    @test result.cost ≈ 909.68 atol=1e-2

end


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

@testset "A-n32-k5.vrp" begin
    cvrp = CVRPLIB.readCVRP("A-n32-k5.vrp")
    ap = AlgorithmParameters(timeLimit=2.3)
    result = solve_cvrp(cvrp, ap; verbose=true)
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

