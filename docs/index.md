# MOOSE.jl

Multiphysics Object Oriented Simulation Environment In Julia

This is essentially a "mini" version of the true [MOOSE multiphysics framework](http://mooseframework.org) reimagined in Julia.

MOOSE is intended to simplify the creation of of multiphysics applications.  It achieves this by breaking multiphysics problems down into small, pluggable, objects.  These small objects range from physics to boundary conditions, materials, initial conditions, etc.  By choosing a set of these small objects you can perfectly describe the simulation you want to compute.

One key facet of MOOSE is that although it allows for massively parallel simulations, it should never expose parallelism to the users.  Application developers should be able to focus on the equations they would like to solve while MOOSE takes care of the details of how to solve them.

To get started you'll want to go through the [Installation]() instructions.