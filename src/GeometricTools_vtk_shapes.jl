"""
    `generate_vtk_cuboid(filename::String, x1::Real, x2::Real, x3::Real;
                                    O::Array{T1, 1}=zeros(Float64, 3),
                                    Oaxis::Array{T1, 1}=Array{Float64}(I, 3, 3),
                                    optargs...)`

    Returns a cuboid of sides `x1`, `x2`, `x3` with origin `O` and orientation
`Oaxis`. Vertex [0,0,0] is placed at the origin. `Oaxis[i, :]` contains the
unit vector of the i-th axis.
"""
function generate_vtk_cuboid(filename::String, x1::Real, x2::Real, x3::Real;
                                O::Array{T1, 1}=zeros(Float64, 3),
                                Oaxis::Array{T2, 2}=Array{Float64}(I, 3, 3),
                                optargs...) where {T1<:Real, T2<:Real}

    check_coord_sys(Oaxis)
    invOaxis = collect(Oaxis)'

    # Defining points
    p0 = countertransform([0,0,0], invOaxis, O)
    p1 = countertransform([x1,0,0], invOaxis, O)
    p2 = countertransform([x1,x2,0], invOaxis, O)
    p3 = countertransform([0,x2,0], invOaxis, O)
    p4 = countertransform([0,0,x3], invOaxis, O)
    p5 = countertransform([x1,0,x3], invOaxis, O)
    p6 = countertransform([x1,x2,x3], invOaxis, O)
    p7 = countertransform([0,x2,x3], invOaxis, O)
    points = [p0, p1, p2, p3, p4, p5, p6 ,p7]

    # Defining cells
    c0 = [0, 3, 2, 1]
    c1 = [4, 5, 6, 7]
    c2 = [0, 4, 7, 3]
    c3 = [1, 2, 6, 5]
    c4 = [0, 1, 5, 4]
    c5 = [2, 3, 7, 6]

    cells = [c0, c1, c2, c3, c4, c5]

    # Generate vtk file
    generateVTK(filename, points; cells=cells, optargs...)
end


"""
    Returns a cylinder of radius `r` and height `h` with origin `O` at the
center of the lower face, and orientation `Oaxis` with the centerline along
the third axis. `Oaxis[i, :]` contains the unit vector of the i-th axis.
"""
function generate_vtk_cyl(filename::String, r::Real, h::Real;
                                np::Int64=36,
                                O::Array{T1, 1}=zeros(Float64, 3),
                                Oaxis::Array{T2, 2}=Array{Float64}(I, 3, 3),
                                optargs...) where {T1<:Real, T2<:Real}

    check_coord_sys(Oaxis)
    invOaxis = collect(Oaxis')
    cen = countertransform([0, 0, h], invOaxis, zeros(3)) # Centerline to upper face

    # Generate lower face
    points = [countertransform([r*cos(a),r*sin(a),0], invOaxis, O)
                                    for a in range(0, 2*pi, length=np+1)[1:end-1]]
    # Generate upper face and add centerline points
    points = vcat([O], points, [O+cen], [p+cen for p in points])

    # Defining lower face cells
    cells = [[0, i, i%np + 1] for i in 1:np]

    # Defining side face cells
    cells = vcat(cells, [[i, np+1+i, np+1+(i%np+1), i%np+1] for i in 1:np])

    # Defining uper face cells
    cells = vcat(cells, [[np+1, np+1 + i%np + 1, np+1 + i] for i in 1:np])

    # Generate vtk file
    generateVTK(filename, points; cells=cells, optargs...)
end


# function generate_vtk_arrow(filename::String, r::Real, h::Real;
#                                 l=1.00,                  # Arrow length
#                                 ar=0.25,                 # Aspect ratio of arrow
#                                 R1=0.10,                 # Radius of arrow stem
#                                 R2=0.25,                 # Radius of arrow head
#                                 nz=100,                  # Number of axial sections
#                                 ntheta=36,               # Number of angular sections
#                                 O::Array{T1, 1}=zeros(Float64, 3),   # Start of stem
#                                 Oaxis::Array{T2, 2}=Array{Float64}(I, 3, 3),  # Orientation
#                                 optargs...) where {T1<:Real, T2<:Real}
#
#     # Create linear arrows
#     n1s = Int.(round.(nz * (1 ./ (ar .+ 1) )))
#     n2s = nz .- n1s
#     ls1 = l .* (1 ./ (ar .+ 1) )
#     ls2 = l .- ls1
#
#     xs1 = range(0, ls1, length=n1s)
#     xs2 = range(ls1, ls1 + ls2, length=n2s)
#     ys1 = R1*ones(length(xs1))
#     ys2 = R2*range(1, 0, length=length(xs2))
#     xs  = vcat(xs1, xs2)
#     ys  = vcat(ys1, ys2)
#
#     points = hcat(ys, xs)
#
#     loop_dim   = 2            # Loops the parametric grid
#     grid       = gt.surface_revolution(points, theta; loop_dim=loop_dim)
#
#     # Translate the arrow
#     gt.lintransform!(grid, Oaxis, O)
#
#     return grid, gt.save(grid, filename; optargs...)
# end
