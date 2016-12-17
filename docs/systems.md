# Code Systems

The idea behind MOOSE (both the real one and MOOSE.jl) is to simplify solving nonlinear, multiphysics, finite-element problems.  To do this, the problem is broken down into into small "objects" that are then pieced together to form the final simulation.

To build your simulation you inherit from an abstract type and override a few functions for your new type to specialize computations for it.

The main types of objects are:

  - `Mesh`: Holds the geometry
  - `System`: Holds all of the pieces of the problem to be solved
  - `Variable`: The variables (solution fields) you want to solve for
  - `Kernel`: Pieces (operators) of the PDEs you want to solve
  - `BoundaryCondition`: Conditions placed on your PDEs on the boundary
  - `Solver`: Linear and nonlinear solvers that solve a `System`
  - `Output`: Create output (normally files)

Each of these systems can be found under their respective directories in the `/src` directory of the package.