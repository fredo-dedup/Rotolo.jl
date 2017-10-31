
using SimpleTraits

import Base: display

type RotoloDisplay <: Display ; end
pushdisplay(RotoloDisplay())

@traitdef ShouldRedirect{X}
@traitimpl ShouldRedirect{X} <- isredirected(X)

@traitfn display{X; ShouldRedirect{X}}(::RotoloDisplay, x::X)  = showmsg(x)
@traitfn display{X; !ShouldRedirect{X}}(::RotoloDisplay, x::X) = display(x)

macro redirect(args...)
  currentSession == nothing &&
    error("A session needs to be created before calling @redirect")

  for a in args
    t = try
          eval(current_module(), a)
        catch e
          error("can't evaluate $a, error $e")
        end
    isa(t, Type) || error("$a does not evaluate to a type")

    push!(currentSession.redirected_types, t)
    loadmsg(t)

    # @eval display(::RotoloDisplay, x::($t)) = showmsg(x)
  end
  nothing
end
