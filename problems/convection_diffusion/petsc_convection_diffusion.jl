using MOOSE

# Create the Mesh
mesh = buildSquare(0, 1, 0, 1, 20, 20)

# Create the System to hold the equations
diffusion_system = System{Float64}(mesh)

# Add a variable to solve for
u = addVariable!(diffusion_system, "u")

# Apply the Laplacian operator to the variable
addKernel!(diffusion_system, Diffusion(u))

# Add in a Convection operator with a velocity vector
addKernel!(diffusion_system, Convection(u, Vec{2}((10.,0.))))

# u = 0 on the Left
addBC!(diffusion_system, DirichletBC(u, (Int32)[4], 0.0))

# u = 1 on the Right
addBC!(diffusion_system, DirichletBC(u, (Int32)[2], 1.0))

# Initialize the system of equations
initialize!(diffusion_system)

# Create a solver and solve
solver = PetscDenseImplicitSolver(diffusion_system)
solve!(solver)

# Output
out = VTKOutput()
output(out, solver, "convection_diffusion_out")
