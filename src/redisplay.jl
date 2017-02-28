
module Redisplay # to separate the render of Escher from the one of Media ?

    using Media,  Atom
    import Media: render
    import ..addtochunk
    export rewire, @rewire

    type MauritsDisplay <: Display end
    const md = MauritsDisplay()

    @media MauritsThing
    setdisplay(MauritsThing, md)

    function rewire(func::Function, t::Type)
      media(t, MauritsThing)
      @eval function render(::MauritsDisplay, x::$t)
            ($func)(x)
            string(x)
          end

      @eval render(::Atom.Editor, x::$t) = render(md, x)

    end
    rewire(t::Type)  = rewire(addtochunk, t)

end

rewire = Redisplay.rewire
macro rewire(args...)
    for a in args
        t = try
              Main.eval(a)
            catch e
                error("can't evaluate $a, error $e")
            end
        isa(t, Type) || error("$a does not evaluate to a type")
        rewire(t)
    end
end

# by default Tiles and Markdown will be forwarded
@rewire Escher.Tile Base.Markdown.MD
