"""
`parseargs(args...)` parses arguments of `@container`, `@session` and
`@style`. Arguments of type Pair are returned in a dictionnary
Dict{String,String}. Other arguments are returned as strings.

##arguments
- `args...` : arguments as provided by the macro

"""
function parseargs(args...)
  objects = []
  opts = Dict{String,String}()
  for a in args
    if isa(a, Expr) && a.head == :(=>) && isa(a.args[1],Symbol)
      opts[string(a.args[1])] = tostring(a.args[2])
    else
      push!(objects,a)
    end
  end
  (objects, opts)
end

function tostring(a)
  isa(a, String) && return a
  # isa(a, Symbol) && return string(a)
  try
    sa = eval(current_module(), a)
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
unfold(ex::Any) = Symbol[]
unfold(ex::Symbol) = Symbol[ex]
unfold(ex::String) = Symbol[Symbol(ex)]
unfold(ex::QuoteNode) = Symbol[ex.value]
function unfold(ex::Expr)
  if ex.head == :.
    lexpr = unfold(ex.args[1])
    rexpr = unfold(ex.args[2])
    length(lexpr)!=0 || length(rexpr)!=0 || return Symbol[]
    vcat(lexpr,rexpr)
  elseif ex.head == :quote
    Symbol[ex.args[1]]
  else
    Symbol[]
  end
end

# ex = :(abcd.qsdf.sd)
# res = unfold(:(abcd.qsdf.sd))
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
