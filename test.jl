importall MOOSE

mesh = buildSquare(0, 1, 0, 1, 10, 10)

diffusion_system = System(mesh)

u = addVariable!(diffusion_system, "u")

diffusion_kernel = Diffusion(u)
addKernel!(diffusion_system, diffusion_kernel)

left_boundary = DirichletBC(u, [4], 0.0)
addBC!(diffusion_system, left_boundary)

right_boundary = DirichletBC(u, [2], 1.0)
addBC!(diffusion_system, right_boundary)

initialize!(diffusion_system)

solver = JuliaDenseImplicitSolver(diffusion_system)

initialize!(solver)

MOOSE.reinit!(diffusion_system, mesh.elements[1], solver.solution)

MOOSE.assembleResidualAndJacobian(solver)

solve!(solver)

println(solver.solution)

out = VTKOutput()

output(out, solver, "test_out")
