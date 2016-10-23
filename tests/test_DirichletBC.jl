@testset "DirichletBC" begin
    var = Variable(1, "u")

    dbc = DirichletBC(var, [2,3], 3.7)

    # Test the BoundaryCondition interface
    @test boundaryIDs(dbc) == [2,3]

    @test dbc.u.id == 1

    @test dbc.value == 3.7

    # Reinit the variable at a "Node"
    MOOSE.reinit!(var, 2, 2.2)

    # Test out the residual and Jacobian calculations
    res = MOOSE.computeResidual(dbc)

    @test abs(res - (2.2 - 3.7)) < 1e-9

    jac = MOOSE.computeJacobian(dbc, dbc.u)

    @test jac == 1.
end
