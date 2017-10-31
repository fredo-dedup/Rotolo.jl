######################################################################
#
#     Atom Integration
#
#     - Redefines Media.render for type(s) passed to @redirect
#
######################################################################

import Media, Juno
import Media: render

# type RotoloDisplay <: Media.Display end
# const rd = RotoloDisplay()
# Media.@media RotoloThing
# Media.setdisplay(RotoloThing, rd)


@traitfn Media.render{X; ShouldRedirect{X}}(e::Juno.Editor, x::X) = begin
  Media.render(Juno.Inline(), Atom.icon("check"))
  showmsg(x)
end

@traitfn Media.render{X; !ShouldRedirect{X}}(e::Juno.Editor, x::X) = begin
  Media.render(Juno.Inline(), Juno.Copyable(x))
end

# redefinition of 'redirect'
# macro redirect(args...)
#   currentSession == nothing &&
#     error("A session needs to be created before calling @redirect")
#
#   for a in args
#     t = try
#           eval(current_module(), a)
#         catch e
#           error("can't evaluate $a, error $e")
#         end
#     isa(t, Type) || error("$a does not evaluate to a type")
#
#     push!(currentSession.redirected_types, t)
#     loadmsg(t)
#
#     @eval function Media.render(e::Atom.Editor, x::($t))
#         Media.render(e, nothing)
#         showmsg(x)
#       end
#
#   end
# end
