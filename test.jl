importall MOOSE

mesh = buildSquare(0, 1, 0, 1, 2, 2)

diffusion_system = System()

u = addVariable!(diffusion_system, "u")
