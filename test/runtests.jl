using Hygese
using Test
using CVRPLIB, TSPLIB

@testset "Hygese.jl" begin
    # Write your tests here.

    @testset "CVRP" begin
        include("cvrp_test.jl")
    end

    @testset "TSP" begin
        include("tsp_test.jl")
    end

end
