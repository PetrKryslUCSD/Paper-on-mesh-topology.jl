"""
    simpledownup

Compute the mesh topology structures that correspond to the full one-level
downward and upward adjacency graph. Memory is used to store the downward incidence
relations (3, 2), (2, 1), (1, 0), and the upward incidence relations (0, 1), (1,
2), and (2, 3) and the locations of the vertices.
"""
module fullonelevel
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
    geom = attribute(ir30.right, "geom")
    @show membytes = allocmem(locations(geom.val)._v)
    summembytes += membytes

    @info "Skeleton: facets. (2, 0)"
    @time ir20 = skeleton(ir30)
    @show "($(manifdim(ir20.left)), $(manifdim(ir20.right)))"
    @show (nshapes(ir20.left), nshapes(ir20.right))
    @show membytes = allocmem(ir20._v)
    summembytes += membytes

    @info "Bounded-by facets. (3, 2)"
    @time ir32 = bbyfacets(ir30, ir20)
    @show "($(manifdim(ir32.left)), $(manifdim(ir32.right)))"
    @show (nshapes(ir32.left), nshapes(ir32.right))
    @show membytes = allocmem(ir32._v)
    summembytes += membytes

    @info "Skeleton: ridges. (1, 0)"
    @time ir10 = skeleton(ir20)
    @show "($(manifdim(ir10.left)), $(manifdim(ir10.right)))"
    @show (nshapes(ir10.left), nshapes(ir10.right))
    @show membytes = allocmem(ir10._v)
    summembytes += membytes

    @info "Bounded-by facets. (2, 1)"
    @time ir21 = bbyfacets(ir20, ir10)
    @show "($(manifdim(ir21.left)), $(manifdim(ir21.right)))"
    @show (nshapes(ir21.left), nshapes(ir21.right))
    @show membytes = allocmem(ir21._v)
    summembytes += membytes
    
    @info "Transpose. (0, 1)"
    @time tr01 = transpose(ir10)
    @show "($(manifdim(tr01.left)), $(manifdim(tr01.right)))"
    @show (nshapes(tr01.left), nshapes(tr01.right))
    @show membytes = allocmem(tr01._v)
    summembytes += membytes
    
    @info "Transpose. (1, 2)"
    @time tr12 = transpose(ir21)
    @show "($(manifdim(tr12.left)), $(manifdim(tr12.right)))"
    @show (nshapes(tr12.left), nshapes(tr12.right))
    @show membytes = allocmem(tr12._v)
    summembytes += membytes
    
    @info "Transpose. (2, 3)"
    @time tr23 = transpose(ir32)
    @show "($(manifdim(tr23.left)), $(manifdim(tr23.right)))"
    @show (nshapes(tr23.left), nshapes(tr23.right))
    @show membytes = allocmem(tr23._v)
    summembytes += membytes
    @show summembytes


    # vtkwrite("speedtest1", connectivity)
    true
end
end
using .fullonelevel
# using BenchmarkTools
# @btime fullonelevel.test()
fullonelevel.test()
