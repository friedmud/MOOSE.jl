# PETSc

While Julia has quite a lot of linear algebra capability built-in, it is still missing a few things.  In particular, Julia does not contain built-in iterative linear solvers (like Krylov solvers).  Even though there are some third-party Krylov solvers (such [KrylovMethods.jl](https://github.com/lruthotto/KrylovMethods.jl) ) they lack preconditioning and parallelism.

For this reason, it is useful to utilize the [PETSc library](https://www.mcs.anl.gov/petsc/) from Argonne National Laboratory.  PETSc is a mature code-base providing parallel Krylov solvers and preconditioners that are a perfect match for FEM.  To use them, I have developed a Julia wrapper: [MiniPETSc.jl](https://github.com/friedmud/MiniPETSc.jl) which MOOSE.jl takes advantage of.

## PETSc Setup

Before using PETSc it's critical that you've been through the [setup steps on the Installation page](../installation.md).  PETSc needs to be compiled against your MPI installation, installed and the `PETSC_DIR` environment variable needs to be set to point to that installation.

## Using PETSc

To use PETSc within your MOOSE.jl script... all that is necessary is to switch the type of solver you are using to one of the `Petsc*` solvers.  For instance, here is a modified form of the script from Example #2:

```julia
using MOOSE

# Create the Mesh
mesh = buildSquare(0, 1, 0, 1, 10, 10)

# Create the System to hold the equations
diffusion_system = System{Dual{4,Float64}}(mesh)

# Add a variable to solve for
u = addVariable!(diffusion_system, "u")

# Apply the Laplacian operator to the variable
addKernel!(diffusion_system, Diffusion(u))

# u = 0 on the Left
addBC!(diffusion_system, DirichletBC(u, [4], 0.0))

# u = 1 on the Right
addBC!(diffusion_system, DirichletBC(u, [2], 1.0))

# Initialize the system of equations
initialize!(diffusion_system)

# Create a solver and solve
solver = PetscImplicitSolver(diffusion_system)
solve!(solver)

# Output
out = VTKOutput()
output(out, solver, "simple_diffusion_out")
```

The `PetscImplicitSolver` will utilize PETSc vectors, matrices and solvers to solve the system.

## PETSc Options

By default PETSc will use a GMRES solver with ILU-0 preconditioning.  For small, simple problems this will work fine.  But: for anything more complicated you will want to specify options to PETSc to change the solver/preconditioner.  This can be achieved using the normal PETSc command-line syntax.

For instance, to use the algebraic multigrid [Hypre/Boomeramg](http://computation.llnl.gov/projects/hypre-scalable-linear-solvers-multigrid-methods) package for preconditioning you would run your script like so:

```bash
julia myscript.jl -pc_type hypre -pc_hypre_type boomeramg
```

To see a lot of the command-line options you can use try running your script using the `-help` option:

```bash
julia myscript.jl -help
```

Here are some of the most useful/common PETSc options:

Name | Description
:- | :-
`-ksp_monitor` | View convergence information
`-snes_ksp_ew` | Variable linear solve tolerance, useful for transient solves
`-help` | Show PETSc options during the solve


Name | Value | Description
:-                    | :-                    | :-
`-pc-type`            | `ilu`                 | Default for serial
                      | `bjacobi`             | Default for parallel with `-sub_pc_type ilu`
                      | `asm`                 | Additive Schwartz with `-sub_pc_type ilu`
                      | `lu`                  | Full LU, serial only
                      | `gamg`                | Generalized Geometric-Algebric MultiGrid
                      | `hypre`               | Hypre, usually used with `boomeramg`
`-sub_pc_type`        | `ilu, lu, hypre`      | Can be used with `bjacobi` or `asm`
`-pc_hypre_type`      | `boomeramg`           | Algebraic Multigrid
`-ksp_gmres_restart`  | # (default = 30)      | Number of Krylov vectors to store



For even more, refer to the [PETSc documentation](http://www.mcs.anl.gov/petsc/documentation/)
