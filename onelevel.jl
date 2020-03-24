module onelevel1
using StaticArrays
using MeshCore: Locations, nvertices, coordinates, nshapes, skeleton, bbyfacets, manifdim, transpose, attribute, locations
using MeshPorter: vtkwrite
using MeshMaker: T4block
using BenchmarkTools
using Test
function test()
    n = 3
    membytes = 0; summembytes = 0
    @info "Initial"
    @time connectivity = T4block(1.0, 2.0, 3.0, n*7, n*9, n*10, :a; intbytes = 4)
    @show "$(manifdim(connectivity.left)) -> $(manifdim(connectivity.right))"
    @show (nshapes(connectivity.right), nshapes(connectivity.left))
    @show membytes = sizeof(connectivity._v)
    geom = attribute(connectivity.right, "geom")
    @show membytes = sizeof(locations(geom.val)._v)
    summembytes += membytes

    @info "Skeleton: facets"
    @time skel2 = skeleton(connectivity)
    @show "$(manifdim(skel2.left)) -> $(manifdim(skel2.right))"
    @show (nshapes(skel2.right), nshapes(skel2.left))
    @show membytes = sizeof(skel2._v)
    summembytes += membytes

    @info "Bounded-by facets"
    @time bb2 = bbyfacets(connectivity, skel2)
    @show "$(manifdim(bb2.left)) -> $(manifdim(bb2.right))"
    @show (nshapes(bb2.right), nshapes(bb2.left))
    @show membytes = sizeof(bb2._v)
    summembytes += membytes

    @info "Skeleton: edgets"
    @time skel1 = skeleton(skel2)
    @show "$(manifdim(skel1.left)) -> $(manifdim(skel1.right))"
    @show (nshapes(skel1.right), nshapes(skel1.left))
    @show membytes = sizeof(skel1._v)
    summembytes += membytes

    @info "Bounded-by edgets"
    @time bb1 = bbyfacets(skel2, skel1)
    @show "$(manifdim(bb1.left)) -> $(manifdim(bb1.right))"
    @show (nshapes(bb1.right), nshapes(bb1.left))
    @show membytes = sizeof(bb1._v)
    summembytes += membytes
    @show summembytes


    # vtkwrite("speedtest1", connectivity)
    true
end
end
using .onelevel1
# using BenchmarkTools
# @btime onelevel1.test()
onelevel1.test()
