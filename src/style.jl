

function style(obj, styl::String="")
  buf = IOBuffer()
  if method_exists(show, (IO, MIME"text/html", typeof(obj)))
    show(buf, MIME"text/html"(), obj)
  elseif method_exists(show, (IO, MIME"text/plain", typeof(obj)))
    show(buf, MIME"text/plain"(), obj)
  else
    error("no show function found for type $(typeof(obj))")
  end

  args = Dict(:newnid => getnid(),
              :compname => "html-node",
              :params => Dict(:html => takebuf_string(buf)),
              :style => styl)

  send("append", args)
  nothing
end
