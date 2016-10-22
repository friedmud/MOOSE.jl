importall MOOSE

mesh = buildSquare(0, 1, 0, 1, 2, 2)

diffusion_system = System(mesh)

u = addVariable!(diffusion_system, "u")

diffusion_kernel = Diffusion(u)

addKernel!(diffusion_system, diffusion_kernel)

initialize!(diffusion_system)

solver = JuliaDenseImplicitSolver(diffusion_system)

initialize!(solver)

MOOSE.reinit!(diffusion_system, mesh.elements[1], solver.solution)

MOOSE.assembleResidualAndJacobian(solver)

println(solver.mat)

#solve!(solver)
