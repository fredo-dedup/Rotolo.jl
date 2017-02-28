texᵗ = Input("f(x) = \\int_{-\\infty}^\\infty
           \\hat f(\\xi)\\,e^{3 \\pi i \\xi x}
           \\,d\\xi")
modeᵗ = Input(false)

function main(window)
    push!(window.assets, "tex")
    push!(window.assets, "widgets")

    lift(texᵗ, modeᵗ) do t, mode
        vbox(h1("LaTeX"),
             hbox("LaTeX support is via ", hskip(1em), tex("\\KaTeX")),
             textinput() >>> texᵗ,
             hbox("Show as a block", hskip(1em), checkbox(mode) >>> modeᵗ),
             vskip(1em),
             tex(t, block=mode)) |> pad(1em) |> maxwidth(30em)
    end
end
