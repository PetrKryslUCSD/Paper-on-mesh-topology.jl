"""
    simpledownup

Compute the mesh topology structures that correspond to the downward and upward
adjacency between the tetrahedra and the vertices. Memory is used only to store
the incidence relation (3, 0), (0, 3) and the locations of the vertices.
"""
module simpledownup
using StaticArrays
using MeshCore: nvertices, nshapes, manifdim, attribute
using MeshCore: ir_skeleton, ir_bbyfacets, ir_transpose
using MeshSteward: vtkwrite, T4block
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
    @show membytes = usedbytes(geom.v)
    summembytes += membytes

    @info "Transpose. (0, 3)"
    @time tr03 = ir_transpose(ir30)
    @show "($(manifdim(tr03.left)), $(manifdim(tr03.right)))"
    @show (nshapes(tr03.left), nshapes(tr03.right))
    @show membytes = usedbytes(tr03._v)
    summembytes += membytes
    @show summembytes/2^20

    # vtkwrite("speedtest1", connectivity)
    true
end
end
using .simpledownup
# using BenchmarkTools
# @btime simpledownup.test()
simpledownup.test()
