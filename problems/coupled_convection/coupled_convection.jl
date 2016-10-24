using MOOSE

include("CoupledConvection.jl")

# Create the Mesh
mesh = buildSquare(0, 1, 0, 1, 20, 20)

# Create the System to hold the equations
diffusion_system = System{Float64}(mesh)

# Add some variables
u = addVariable!(diffusion_system, "u")
v = addVariable!(diffusion_system, "v")

# Apply the Laplacian operator to the "u" variable
addKernel!(diffusion_system, Diffusion(u))

# Apply the Coupled Convection operator
addKernel!(diffusion_system, CoupledConvection(u, v))

# Apply the Laplacian operator to the "v" variable
addKernel!(diffusion_system, Diffusion(v))


# u = 0 on the Left
addBC!(diffusion_system, DirichletBC(u, [4], 0.0))

# u = 1 on the Right
addBC!(diffusion_system, DirichletBC(u, [2], 1.0))


# v = 0 on the Left
addBC!(diffusion_system, DirichletBC(v, [4], 0.0))

# v = 1 on the Right
addBC!(diffusion_system, DirichletBC(v, [2], 1.0))


# Initialize the system of equations
initialize!(diffusion_system)

# Create a solver and solve
solver = JuliaDenseNonlinearImplicitSolver(diffusion_system)
solve!(solver, nl_max_its=5)

# Output
out = VTKOutput()
output(out, solver, "coupled_convection_out")
