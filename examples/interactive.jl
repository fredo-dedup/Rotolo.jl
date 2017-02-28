using Paper

init()

@chunk header
title(1, "Interactive function")


@chunk latex
using Reactive

texᵗ = Input("f(x) = \\int_{-\\infty}^\\infty
           \\hat f(\\xi)\\,e^{2 \\pi i \\xi x}
           \\,d\\xi")
modeᵗ = Input(false)

using Escher

ab = lift(texᵗ, modeᵗ) do t, mode
	println(t, "-", mode)
    vbox(h1("LaTeX"),
         hbox("LaTeX support is via ", hskip(1Paper.em), tex("\\KaTeX")),
         textinput() >>> texᵗ,
         hbox("Show as a block", hskip(1Paper.em), checkbox(mode) >>> modeᵗ),
         vskip(1Paper.em),
         tex(t, block=mode)) |> pad(1Paper.em) |> maxwidth(30Paper.em)
end

@chunk suite

cktˢ = Input(false)
ab = lift(cktˢ) do ckt
	println("! ", ckt)
    hbox("ckbox", hskip(1Paper.em), checkbox(ckt) >>> cktˢ)
end

lift(ab) do ntile
	println(typeof(ntile))
	println(ntile)
end

isa(cktˢ, Signal)
isa([cktˢ, texᵗ], Signal)

function stationary(f::Function, signals::Signal...)
	st = lift(f, signals...)
	Paper.addtochunk(empty)
	pos1 = Paper.current
	pos2 = length(Paper.plan[Paper.current]) 
	lift(st) do nt
		Paper.plan[pos1][pos2] = nt
		notify(Paper.updated)
	end
end


stationary(texᵗ, modeᵗ) do t, mode
	println(t, "-", mode)
    hbox("Show as a block", hskip(1Paper.em), checkbox(mode) >>> modeᵗ)
end

cktˢ = Input(false)
stationary(cktˢ) do ckt
	println("! ", ckt)
    hbox("ckbox", hskip(1Paper.em), checkbox(ckt) >>> cktˢ)
end

############################################################################

tex2ᵗ = Input("f(x) = \\int_{-\\infty}^\\infty
           \\hat f(\\xi)\\,e^{2 \\pi i \\xi x}
           \\,d\\xi")
mode2ᵗ = Input(false)

stationary(tex2ᵗ, mode2ᵗ) do t, mode
	println(t, "-", mode)
    vbox(h1("LaTeX"),
         textinput() >>> tex2ᵗ,
         hbox("Bloooock ?", hskip(1Paper.em), checkbox(mode) >>> mode2ᵗ),
         vskip(1Paper.em),
         tex(t, block=mode)) |> pad(1Paper.em) |> maxwidth(30Paper.em)
end

vskip(2em)


stationary(texᵗ, modeᵗ) do t, mode
	println(t, "-", mode)
    vbox(h1("LaTeX"),
         textinput() >>> texᵗ,
         hbox("Block ?", hskip(1Paper.em), checkbox(mode) >>> modeᵗ),
         vskip(1Paper.em),
         tex(t, block=mode)) |> pad(1Paper.em) |> maxwidth(30Paper.em)
end

vskip(2em)


tex("abcd \\oe 3")

17.54/2.54

ab = lift(texᵗ) do t
	println(t)
end

ab = lift(v -> println("hello"), texᵗ)

typeof(ab)

println("coucou")

############################################################################
@chunk fonction

using Gadfly

Paper.rewire(Gadfly.Plot) do p
    Paper.addtochunk(convert(Paper.Tile, p))
end

α = [0.42, 0.094]
itx(gp, dur) = 1 - ( 1 - α[gp]) * exp(-24.5 / max(0.001,dur))

plot([dur -> itx(1, dur), dur -> itx(2, dur)],
     0, 1000, 
     Scale.y_continuous(minvalue=0,maxvalue=1))

gpˢ  = Input(1)

αˢ = Input(0.5)
βˢ = Input(-10)

stationary(αˢ, βˢ) do α, β
    vbox(h1("Interactive plotting"),
         hbox("Set α"   , slider( 0:0.01:1, value=α)  >>> αˢ),
         hbox("Set β"   , slider(-100:1:-1, value=β) >>> βˢ),
         plot(dur -> 1 - (1 - α) * exp(β / max(0.001,dur)), 
              0., 1000,
              Scale.y_continuous(minvalue=0,maxvalue=1))) |> pad(2em)
end

αˢ = nothing
βˢ = nothing
