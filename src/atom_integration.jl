######################################################################
#
#     Atom Integration
#
#     - Redefines Media.render for type(s) passed to @redirect
#
######################################################################

import Media, Atom
import Media: render

# type RotoloDisplay <: Media.Display end
# const rd = RotoloDisplay()
# Media.@media RotoloThing
# Media.setdisplay(RotoloThing, rd)

# redefinition of 'redirect'
macro redirect(args...)
  isdefined(Rotolo, :currentSession) ||
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
    
    @eval function Media.render(e::Atom.Editor, x::($t))
        Media.render(e, nothing)
        showmsg(x)
      end

  end
end
