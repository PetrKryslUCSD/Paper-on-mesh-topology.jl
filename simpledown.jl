"""
    simpledown

Compute the mesh topology structures that correspond to just the downward
adjacency between the tetrahedra and the vertices.
Memory is used only to store the incidence relation and the locations of the
vertices.
"""
module simpledown
using StaticArrays
using MeshCore: Locations, nvertices, coordinates, nshapes, skeleton, bbyfacets, manifdim, transpose, attribute, locations
using MeshPorter: vtkwrite
using MeshMaker: T4block
using BenchmarkTools
using Test

include("usedbytes.jl")

function test()
    n = 3
    membytes = 0; summembytes = 0
    @info "Initial (3, 0)"
    @time connectivity = T4block(1.0, 2.0, 3.0, n*7, n*9, n*10, :a; intbytes = 4)
    ir30 = connectivity
    @show "($(manifdim(ir30.left)), $(manifdim(ir30.right)))"
    @show (nshapes(ir30.left), nshapes(ir30.right))
    @show membytes = usedbytes(ir30._v)
    summembytes += membytes
    geom = attribute(ir30.right, "geom")
    @show membytes = usedbytes(locations(geom.val)._v)
    summembytes += membytes

    @show summembytes

    # vtkwrite("speedtest1", connectivity)
    true
end
end
using .simpledown
# using BenchmarkTools
# @btime simpledown.test()
simpledown.test()
