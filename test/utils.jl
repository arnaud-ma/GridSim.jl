using GridSim

@testset "Stats" begin
    @test count_values([1, 2, 3, 2]) == Dict(1 => 1, 2 => 2, 3 => 1)
    @test most_commons([1, 2, 3, 2, 1]) == [2, 1]
    @test most_common([1, 2, 3, 2]) == 2
    @test most_common([1, 2, 3, 2, 1]) == 1
end

@testset "enlarge" begin
    @test enlarge([1 2; 3 4], 2) == [1 1 2 2; 1 1 2 2; 3 3 4 4; 3 3 4 4]
end
