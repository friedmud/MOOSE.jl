# MOOSE.jl

Multiphysics Object Oriented Simulation Environment In Julia

This is essentially a "mini" version of the true [MOOSE multiphysics framework](http://mooseframework.org) reimagined in Julia.

MOOSE is intended to simplify the creation of of multiphysics applications.  It achieves this by breaking multiphysics problems down into small, pluggable, objects.  These small objects range from physics to boundary conditions, materials, initial conditions, etc.  By choosing a set of these small objects you can perfectly describe the simulation you want to compute.

One key facet of MOOSE is that although it allows for massively parallel simulations, it should never expose parallelism to the users.  Application developers should be able to focus on the equations they would like to solve while MOOSE takes care of the details of how to solve them.

To get started you'll want to go through the [Installation](installation.md) instructions.

## Code Systems

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

Each of these systems can be found under their respective directories in the `/src` directory of the package.  In addition, some documentation can be found under the `Systems` menu item above.