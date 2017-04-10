
type Katex
  val::String
  displayMode::Bool
end

Katex(ex::String) = Katex(ex, false)

function showmsg(obj::Katex, opts::Dict=Dict())
  buf = IOBuffer()
  if method_exists(show, (IO, MIME"text/html", typeof(obj)))
    show(buf, MIME"text/html"(), obj)
  elseif method_exists(show, (IO, MIME"text/plain", typeof(obj)))
    show(buf, MIME"text/plain"(), obj)
  else
    error("no show function found for type $(typeof(obj))")
  end

  args = Dict(:newnid   => getnid(),
              :compname => "katex",
              :params   => Dict(:expr => obj.val,
                                :options => Dict(:displayMode => obj.displayMode)),
              :deco     => opts)

  sendcurrent("append", args)
  nothing
end

@redirect Katex
