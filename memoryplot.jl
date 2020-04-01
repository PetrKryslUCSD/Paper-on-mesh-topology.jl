using PGFPlotsX
@pgf a = Axis(
    {
        ybar,
        enlargelimits = 0.05,
        legend_style =
        {
            at = Coordinate(0.5, -0.15),
            anchor = "north",
            legend_columns = -1
        },
        ylabel = "Storage in megabyte",
        symbolic_x_coords=["MeshCore D", "MeshCore D/U", "MeshCore 32", "MeshCore 64", "MDS-RED", "MOAB", "MDS", "GRUMMP", "STK"],
        xtick = "data",
        xticklabel_style={
        rotate=45,
        anchor="east"
        },
        nodes_near_coords,
        nodes_near_coords_align={vertical},
    },
    Plot(Coordinates([("MeshCore D", 2.09), ("MeshCore D/U", 3.7), ("MeshCore 32", 13.2), ("MeshCore 64",  26.0), ("MDS-RED", 6.4), ("MOAB", 10), ("MDS", 23.4), ("GRUMMP", 39.8), ("STK", 67.6)]))
)

display(a)

# The MDS system of
# Figure 9 of~\cite{Ibanez2016}: MOAB 10 MB per 100K tets
# We need 3*8*100000/6/1024/1024+4*8*100000/1024/1024=3.5 MB (non--modifiable MOAB
# 10 MB, implementations support adaptive meshes PUMI 23 MB, GRUMMP 40 MB,  STK 67
# MB).