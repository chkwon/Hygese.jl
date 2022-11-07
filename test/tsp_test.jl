@testset "Symmetric TSP: pr76, by coordinates" begin
    tsp = TSPLIB.readTSPLIB(:pr76)
    ap = AlgorithmParameters(timeLimit=1)
    result = solve_tsp(tsp, ap)
    @show result.cost
    @show result.routes
    @test result.cost <= 108159 * 1.02
end

@testset "Asymmetric TSP: br17, by dist_mtx" begin
    tsp = TSPLIB.readTSP("br17.atsp")
    ap = AlgorithmParameters(timeLimit=1)
    result = solve_tsp(tsp, ap; use_dist_mtx=true)
    @show result.cost
    @show result.routes
    @test result.cost <= 39 * 1.02
end

@testset "Asymmetric TSP: ftv64, by dist_mtx" begin
    tsp = TSPLIB.readTSP("ftv64.atsp")
    ap = AlgorithmParameters(timeLimit=1)
    result = solve_tsp(tsp, ap; use_dist_mtx=true)
    @show result.cost
    @show result.routes
    @test result.cost <= 1839 * 1.02
end

@testset "x, y, dist_mtx TSP" begin
    tsp = TSPLIB.readTSPLIB(:pr76)
    dist_mtx = tsp.weights
    x = tsp.nodes[:, 1]
    y = tsp.nodes[:, 2]

    ap = AlgorithmParameters(timeLimit=1)
    result1 = solve_tsp(x, y, ap)
    result2 = solve_tsp(dist_mtx, ap)
    result3 = solve_tsp(dist_mtx, ap; x_coordinates=x, y_coordinates=y)

    @test result1.cost == result2.cost == result3.cost
end

