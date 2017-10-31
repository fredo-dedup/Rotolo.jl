
type Katex
  val::String
  displayMode::Bool
end

Katex(ex::String) = Katex(ex, false)

function showmsg(obj::Katex, opts::Dict=Dict())
  args = Dict(:newnid   => getnid(),
              :compname => "katex",
              :params   => Dict(:expr => obj.val,
                                :options => Dict(:displayMode => obj.displayMode)),
              :deco     => opts)

  sendcurrent("append", args)
  nothing
end

function loadmsg(::Type{Katex})
  comppath = normpath(joinpath(@__DIR__, "../../client/katex/katex.js"))
  send(currentSession, 0,
       "load",
       Dict{Symbol,Any}(:assetname => "katex",
   		                  :assetpath => comppath))
  sleep(3) # give time to load
end

export Katex
