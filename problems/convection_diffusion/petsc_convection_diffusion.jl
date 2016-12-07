using MOOSE

# Create the Mesh
mesh = buildSquare(0, 1, 0, 1, 10, 10)

# Create the System to hold the equations
diffusion_system = System{Float64}(mesh)

# Add a variable to solve for
u = addVariable!(diffusion_system, "u")

# Apply the Laplacian operator to the variable
addKernel!(diffusion_system, Diffusion(u))

# Add in a Convection operator with a velocity vector
addKernel!(diffusion_system, Convection(u, ContMechTensors.Vec{2}((10.,0.))))

# u = 0 on the Left
addBC!(diffusion_system, DirichletBC(u, [4], 0.0))

# u = 1 on the Right
addBC!(diffusion_system, DirichletBC(u, [2], 1.0))

# Initialize the system of equations
initialize!(diffusion_system)

# Create a solver and solve
solver = PetscImplicitSolver(diffusion_system)

# Initialize the solver so that we can call it multiple times
initialize!(solver)

function doIt()
    solve!(solver)
end

doIt()
clear!(MOOSE.main_perf_log)
doIt()

# Output
out = VTKOutput()
output(out, solver, "convection_diffusion_out")
