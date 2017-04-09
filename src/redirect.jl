
import Base: display

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

    @eval display(::RotoloDisplay, x::($t)) = showmsg(x)
  end
  nothing
end
