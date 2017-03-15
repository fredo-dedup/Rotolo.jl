######################################################################
#
#     Atom Integration
#
#     - Inhibits display of VegaLite plots in Atom to avoid having plots
#          sent twice to the browser
#
######################################################################

@require Atom begin  # define only if/when Atom is loaded

  import Media, Atom
  import Media: render

  type RotoloDisplay <: Media.Display end
  const rd = RotoloDisplay()

  Media.@media RotoloThing
  Media.setdisplay(RotoloThing, rd)

  function redirect(t::Type)

    if method_exists(show, (IO, MIME"text/html", t))
      sfunc = function (x)
        buf = IOBuffer()
        show(buf, MIME"text/html"(), x)
        takebuf_string(buf)
      end
    elseif method_exists(show, (IO, MIME"text/plain", t))
      sfunc = function (x)
        buf = IOBuffer()
        show(buf, MIME"text/plain"(), x)
        takebuf_string(buf)
      end
    else
      error("no show function found for $t")
    end

    # @eval Media.render(e::Atom.Editor, ::$t) =
    #   Media.render(e, nothing)

    Media.media(t, RotoloThing)

    # @eval function Media.render(::RotoloDisplay, x::$t)
    #   str = ($sfunc)(x)
    #
    #   send("test", 1, "append",
    #        Dict(:newnid => getnid(),
    #             :compname => "html-node",
    #             :params => Dict(:html=>str)))
    # end

    nothing
  end

end
