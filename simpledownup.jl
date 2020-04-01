"""
    simpledownup

Compute the mesh topology structures that correspond to the downward and upward
adjacency between the tetrahedra and the vertices. Memory is used only to store
the incidence relation (3, 0), (0, 3) and the locations of the vertices.
"""
module simpledownup
using StaticArrays
using MeshCore: Locations, nvertices, coordinates, nshapes, skeleton, bbyfacets, manifdim, transpose, attribute, locations
using MeshPorter: vtkwrite
using MeshMaker: T4block
using BenchmarkTools
using Test

function allocmem(v) 
    n = 0
    for i in 1:length(v)
        n += sizeof(v[i])
    end
    return n
end
function test()
    n = 3
    membytes = 0; summembytes = 0
    @info "Initial (3, 0)"
    @time connectivity = T4block(1.0, 2.0, 3.0, n*7, n*9, n*10, :a; intbytes = 4)
    ir30 = connectivity
    @show "($(manifdim(ir30.left)), $(manifdim(ir30.right)))"
    @show (nshapes(ir30.left), nshapes(ir30.right))
    @show membytes = allocmem(ir30._v)
    summembytes += membytes
    geom = attribute(ir30.right, "geom")
    @show membytes = allocmem(locations(geom.val)._v)
    summembytes += membytes

    @info "Transpose. (0, 3)"
    @time tr03 = transpose(ir30)
    @show "($(manifdim(tr03.left)), $(manifdim(tr03.right)))"
    @show (nshapes(tr03.left), nshapes(tr03.right))
    @show membytes = allocmem(tr03._v)
    summembytes += membytes
    @show summembytes

    # vtkwrite("speedtest1", connectivity)
    true
end
end
using .simpledownup
# using BenchmarkTools
# @btime simpledownup.test()
simpledownup.test()
