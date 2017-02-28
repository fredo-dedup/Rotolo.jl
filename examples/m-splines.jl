using Paper
using Markdown

using Gadfly

Paper.rewire(Gadfly.Plot) do p
	Paper.addtochunk(convert(Paper.Tile, p))
end

Paper.launch()

###############################

Paper.chunk(:start)
Paper.title(3, "M-Splines")
Paper.chunk(:next)
Paper.title(3, "M-Splines")


"abcd" |> borderwidth(1px) |> bordercolor("#444") |> borderstyle(dashed)

Paper.chunk(:bottom)
"text"



function mspline(i, k, ts, x)
	if k == 1
		idx = searchsortedlast(ts, x)
		(idx == 0 | idx == length(ts)) && return 0.
		(idx != i) && return 0.
		return 1. / ( ts[ idx+1 ] - ts[ idx ] )
	else
		ti, tik  = ts[ max(i, 1) ], ts[ min(i+k, length(ts)) ]
		(ti == tik) && return 0
		num = (x-ti) * mspline(i, k-1, ts, x) + (tik-x) * mspline(i+1, k-1, ts, x)
		return k * num / ( (k-1) * (tik-ti) )
	end
end

tex("M_k(x) = \\frac{(x-t_i).M_{k-1}^{i}(x)+(t_ik-x).M_{k-1}^{i+1}(x)}{(k-1)(t_ik-t_i)}") |> pad(1em)


md"""
- exemple

```
	function mspline(i, k, ts, x)
		if k == 1
			idx = searchsortedlast(ts, x)
			(idx == 0 | idx == length(ts)) && return 0.
			(idx != i) && return 0.
			return 1. / ( ts[ idx+1 ] - ts[ idx ] )
		else
			ti, tik  = ts[ max(i, 1) ], ts[ min(i+k, length(ts)) ]
			(ti == tik) && return 0
			num = (x-ti) * mspline(i, k-1, ts, x) + (tik-x) * mspline(i+1, k-1, ts, x)
			return k * num / ( (k-1) * (tik-ti) )
		end
	end
```

- finalizer(x, function)
"""

vskip(1em)

Paper.chunk(:body)
title(1, "avec 4 courbes")

ts = [0., 0.3, 0.7, 1.]
pl = plot([ x -> mspline(i, 3, ts, x) for i in -1:3] , 0, 1) ;
vbox(pl, caption(md"This is a Graph of **M-Splines**")) |> 
	packacross(center) |> 
	borderstyle(solid)

Paper.chunk(:body2)
title(1, "avec plus de courbes")

ts = [0:0.1:1.]
pl = plot([ x -> mspline(i, 3, ts, x) for i in -1:length(ts)-1] , 0, 1) ;
vbox(pl, 
	 caption(md"This is a Graph of **M-Splines** \\n 11 points")) |> 
	packacross(center) |> 
	borderstyle(solid)

5+6

"aze"
"xyz"

include("examples/mini.jl")


