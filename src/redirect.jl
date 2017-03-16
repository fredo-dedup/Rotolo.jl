
import Base: display #.show

type RotoloDisplay <: Display ; end
pushdisplay(RotoloDisplay())


macro redirect(args...)
  for a in args
      t = try
            Main.eval(a)
          catch e
              error("can't evaluate $a, error $e")
          end
      isa(t, Type) || error("$a does not evaluate to a type")

      sfunc = function (x)
        buf = IOBuffer()
        if method_exists(show, (IO, MIME"text/html", t))
          show(buf, MIME"text/html"(), x)
        elseif method_exists(show, (IO, MIME"text/plain", t))
          show(buf, MIME"text/plain"(), x)
        else
          error("no show function found for $t")
        end
        takebuf_string(buf)
      end

      # @eval function display(::RotoloDisplay, ::MIME"text/html", x::($t))
      #     str = ($sfunc)(x)
      #
      #     send("test", 1, "append",
      #          Dict(:newnid => 101,
      #               :compname => "html-node",
      #               :params => Dict(:html=>str)))
      #   end

      @eval function display(::RotoloDisplay, x::($t))
          str = ($sfunc)(x)

          send("append",
               Dict(:newnid => getnid(),
                    :compname => "html-node",
                    :params => Dict(:html=>str)))
        end

  end
  nothing
end
