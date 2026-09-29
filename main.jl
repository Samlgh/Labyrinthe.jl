include("stucture.jl")
include("interface.jl")


l, c = 5, 5        
m = grille(l, c)
m, obstacles, pos_id = pos_element!(m, l, c) 
display(m)
pos_id = deplacement!(pos_id, m, "avancer")
display(m)
