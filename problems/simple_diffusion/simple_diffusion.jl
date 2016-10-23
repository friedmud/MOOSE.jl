importall MOOSE

# Create the Mesh
mesh = buildSquare(0, 1, 0, 1, 10, 10)

# Create the System to hold the equations
diffusion_system = System(mesh)

# Add a variable to solve for
u = addVariable!(diffusion_system, "u")

# Apply the Laplacian operator to the variable
diffusion_kernel = Diffusion(u)
addKernel!(diffusion_system, diffusion_kernel)

# u = 0 on the Left
left_boundary = DirichletBC(u, [4], 0.0)
addBC!(diffusion_system, left_boundary)

# u = 1 on the Right
right_boundary = DirichletBC(u, [2], 1.0)
addBC!(diffusion_system, right_boundary)

# Initialize the system of equations
initialize!(diffusion_system)

# Create a solver and solve
solver = JuliaDenseImplicitSolver(diffusion_system)
solve!(solver)

# Output
out = VTKOutput()
output(out, solver, "simple_diffusion_out")
