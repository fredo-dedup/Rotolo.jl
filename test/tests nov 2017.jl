######### sensis EUR du 11 oct 2017
using CSV, DataFrames
using FileIO
using Optim
using VegaLite
using Rotolo
using Base.Markdown

global_theme = """
	text-align: justify;
	border-style:solid;
	padding: 5px
  """


methods(Media.render, (Rotolo.Juno, Any))

methods(Media.render, (Atom.Inline, Void))

methods(Media.render, (Atom.Editor, Any))




methods(Media.render, (Atom.Inline, Any))


@session MontantsEquiv6 global_theme
# @endsession

@redirect Markdown.MD
sleep(3)

@redirect Katex

Rotolo.currentSession.redirected_types

@container header style=>"text-align: center;"

@redirect Base.Markdown.MD

md"# Montants équivalents"

typeof(md"# Montants équivalents")


methods(Juno.render, (Juno.Editor, Base.Markdown.MD))
methods(Atom.render, (Atom.Editor, Base.Markdown.MD))

@style md"*From Wikipedia, the free encyclopedia*" style=>"font-size:x-small"

Katex("f(x,y)=(x^2+y-11)^2+(x+y^2-7)^2")

5+6

@redirect Int

5+65

# delete!(Rotolo.currentSession.redirected_types, Int)

"abcd"

@redirect String

"abcd"

Rotolo.loadmsg(Katex)
Katex("f(x,y)=(x^2+y-11)^2+(x+y^2-7)^2")

#####################################################################

fvar(s) = s' * covmat * s
dfvar(s) = covmat * s + (s' * covmat)'

function minfunc(initial::Vector{Float64}, vidx::Int64, h::Float64)
  nv = copy(initial)
  nv[vidx] += h
  fvar(nv)
end

function stephedge1(minfunc::Function, initial::Vector, mask::BitArray)
  ovar = round(Int64, minfunc(initial, 1, 0.))

  minzer = zeros(length(initial))
  minmum = [ 1e20 for i in 1:length(initial) ]
  for i in collect(1:length(initial))[mask]
    res = optimize(x -> minfunc(initial, i, x), -1e6, 1e6 )
    minzer[i] = Optim.minimizer(res)
    minmum[i] = Optim.minimum(res)
  end
  vidx = indmin(minmum)
  amnt = round(Int64, minzer[vidx])
  nvar = round(Int64, minmum[vidx])
  println("old var = $ovar, mat $(sensimat[vidx]) ($vidx), amount = $amnt, new var. = $nvar")

  newvec = copy(initial)
  newvec[vidx] += minzer[vidx]
  newmask = copy(mask)
  newmask[vidx] = false
  vidx, newvec, newmask
end

#####################################################################

sensis = CSV.read(IOBuffer("""
  Mats	EUR.EIB.6M	USD.LIB.3M
  3M	-1202	4589
  6M	-8415	4684
  1Y	-1626	-13340
  18M	-15253	17372
  2Y	-9917	15681
  3Y	5901	-11285
  4Y	3657	-15135
  5Y	65133	24432
  6Y	-30523	-16872
  7Y	-41440	-12484
  8Y	49300	-1001
  9Y	-5135	-1847
  10Y	-21788	6180
  11Y	11166	-9559
  12Y	17216	-4027
  13Y	-2389	1057
  14Y	-11172	2661
  15Y	2677	1759
  16Y	-6815	2324
  17Y	-14232	5430
  18Y	4067	5638
  19Y	23327	645
  20Y	-18821	-118
  21Y	-21295	0
  22Y	-6	0
  23Y	-16188	0
  24Y	-2756	0
  25Y	50119	0
  26Y	4388	0
  27Y	-364	0
  28Y	-19	0
  """), delim='\t')
sensimat = Vector(String.(sensis[:,1]))

###########  EUR  #########################################

dat = load("c:/temp/histovarEUR.jld")
matdelta = dat["matvar"]
matmatu  = dat["maturities"]

midx = indexin(sensimat, String.(matmatu))
sum(midx .== 0)  # =0, ok on a toutes les mat qu'il faut

covmat = cov(matdelta[:,midx])
extrema(covmat) # 1.86e-9 , 3.61e-7

sensivec = Vector{Float64}(sensis[Symbol("EUR.EIB.6M")])
initial, mask = copy(sensivec), trues(length(sensivec))
_, initial, mask = stephedge1(minfunc, initial, mask)
# old var = 50, mat 5Y (8), amount = -31042, new var. = 12
# old var = 12, mat 18M (4), amount = 20089, new var. = 6
# old var = 6, mat 6M (2), amount = 7675, new var. = 5
# old var = 5, mat 4Y (7), amount = -5172, new var. = 4
# old var = 4, mat 2Y (5), amount = 3887, new var. = 4
# old var = 4, mat 28Y (31), amount = -3262, new var. = 4
# old var = 4, mat 7Y (10), amount = 1876, new var. = 4
# old var = 4, mat 3Y (6), amount = -2555, new var. = 3
# old var = 3, mat 17Y (20), amount = 1735, new var. = 3
# old var = 3, mat 27Y (30), amount = -1825, new var. = 3
# old var = 3, mat 16Y (19), amount = 1494, new var. = 3
# old var = 3, mat 25Y (28), amount = -1546, new var. = 3
# old var = 3, mat 8Y (11), amount = 1103, new var. = 3

std₀ = sqrt(50) * 10000 # 71k€
sqrt(12) * 10000        # 35k€
sqrt(6) * 10000         # 25k€

-31042 * 10000 / 5 / 0.98 # 5Y  prêt de 63 M€
20089 * 10000 / 1.5       # 18M emprunt de 134 M€
7675 * 10000 / 0.5       # 6M emprunt de 154 M€


using VegaLite

pd = DataFrame(mats = sensimat, std= sqrt.(diag(covmat)) * 10000)
pd |> markbar() |>
  encoding(xordinal(field=:mats, vlscale(domain=sensimat)),
  yquantitative(field=:std))

###########  USD  #########################################

dat = load("c:/temp/histovarUSD.jld")
matdelta = dat["matvar"]
matmatu  = dat["maturities"]

cidx = isnull.(sensis[3]) .== false
sensimat = Vector{String}(sensis[cidx,1])

midx = indexin(sensimat, String.(matmatu))
sum(midx .== 0)  # =0, ok on a toutes les mat qu'il faut

covmat = cov(matdelta[:,midx])
extrema(covmat) # 1.86e-9 , 3.61e-7

pd = DataFrame(mats = sensimat, std= sqrt.(diag(covmat)) * 10000)
pd |> markbar() |>
  encoding(xordinal(field=:mats, vlscale(domain=sensimat)),
  yquantitative(field=:std))


sensivec = Vector{Float64}(sensis[cidx, Symbol("USD.LIB.3M")])
initial, mask = copy(sensivec), trues(length(sensivec))
_, initial, mask = stephedge1(minfunc, initial, mask)

# old var = 32, mat 18M (4), amount = -13699, new var. = 25
# old var = 25, mat 7Y (10), amount = 11879, new var. = 16
# old var = 16, mat 2Y (5), amount = -6602, new var. = 14
# old var = 14, mat 1Y (3), amount = 6651, new var. = 12
# old var = 12, mat 3M (1), amount = -5328, new var. = 9
# old var = 9, mat 3Y (6), amount = 4410, new var. = 8
# old var = 8, mat 6M (2), amount = -3390, new var. = 7
# old var = 7, mat 20Y (23), amount = -3719, new var. = 6
# old var = 6, mat 8Y (11), amount = 3072, new var. = 5
# old var = 5, mat 21Y (24), amount = -2938, new var. = 5
# old var = 5, mat 4Y (7), amount = 2501, new var. = 5

std₀ = sqrt(32) * 10000 # 57k€
sqrt(25) * 10000        # 50k€
sqrt(16) * 10000         # 40k€
sqrt(14) * 10000         # 37k€

-13699 * 10000 / 1.5  # 18M  prêt de 91M€
11879 * 10000 / 7     # 7Y   emprunt de 17 M€
-6602 * 10000 / 2     # 2Y   prêt de 33 M€


#############  find simplified equivalment pose   ############################

# subset of sensis to minimize
sensimat = Vector{String}(sensis[1])
sensimat2 = String["3M", "6M", "1Y", "3Y", "7Y", "12Y"]
mmask = indexin(sensimat2, sensimat)
sensi₀ = Vector{Float64}(sensis[3])

dat = load("c:/temp/histovarUSD.jld")
matdelta = dat["matvar"]
matmatu  = dat["maturities"]
midx = indexin(sensimat, String.(matmatu))
sum(midx .== 0)  # =0, ok on a toutes les mat qu'il faut

covmat = cov(matdelta[:,midx])
extrema(covmat)

sensi₁ = copy(sensi₀)
function minfunc(x::Vector{Float64})
  sensi₁[mmask] = x
  sensi₁' * covmat * sensi₁
end

result = optimize(minfunc, zeros(length(mmask)), BFGS())
Optim.minimizer(result)
Optim.minimum(result)

sensi₁ - sensi₀

sqrt(sensi₀' * covmat * sensi₀) * 10000 # 56 k€
sqrt(sensi₁' * covmat * sensi₁) * 10000 # 37 k€


pdtfr = vcat(DataFrame(mat=sensimat,  sensi=sensi₀, src = "orig"),
             DataFrame(mat=sensimat2, sensi=(sensi₀-sensi₁)[mmask], src="simplified"))


pdtfr |>
  markbar() |>
  encoding(columnordinal(field=:mat),
           xordinal(field=:src),
           colornominal(field=:src),
           yquantitative(field=:sensi))
