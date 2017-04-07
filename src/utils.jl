"""
`parseargs(args...)` parses arguments of `@container`, `@session` and
`@style`. Arguments of type Pair are returned in a dictionnary
Dict{String,String}. Other arguments are returned as is.

##arguments
- `args...` : arguments as provided by the macro

"""
function parseargs(args...)
  others = String[]
  opts = Dict{String,String}()
  for a in args
    if isa(a, Expr) && a.head == :(=>) && isa(a.args[1],Symbol)
      opts[string(a.args[1])] = tostring(a.args[2])
    else
      push!(others,string(a))
    end
  end
  (others, opts)
end

function tostring(a)
  isa(a, String) && return a
  # isa(a, Symbol) && return string(a)
  try
    sa = eval(a)
    isa(sa, String) && return sa
    throw()
  catch
    error("cannot parse argument '$a' to a String")
  end
end


"""
`unfold(e)` transforms expressions `:(sym1.sym2.sym3)` into a tuple of symbols
`[:sym1, :sym2, :sym3]`.
"""
unfold(ex::Any) = NTuple()
unfold(ex::Symbol) = [ex]
function unfold(ex::Expr)
  ex.head != :. && return Symbol[]
  lexpr = unfold(ex.args[1])
  length(lexpr) == 0 && return Symbol[]
  push!(lexpr, ex.args[2].args[1])
  lexpr
end

# ex = :(abcd.qsdf.sd)
# res = unfold(:(abcd.qsdf.sd))
# tuple(res...)
# res[1:end-1]
# unfold(:( aze-45 ))
# unfold(:( aze=45 ))
# unfold(:( aze => abcd.sdf ))
# unfold(:(abcd.yo))


function sendcurrent(command::String, args::Dict=Dict())
  isdefined(Rotolo, :currentSession) || error("[send] no active session")

  send(currentSession,
       currentSession.active_container.nid,
       command, args)
end

function send(session::Session, nid::Int,
              command::String, args::Dict=Dict())
  msg = Dict{Symbol, Any}(:nid     => nid,
                          :command => command,
                          :args    => args)

  put!(session.channel, JSON.json(msg))
end
