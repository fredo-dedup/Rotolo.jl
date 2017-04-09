#############################################################################
# Display functions
#############################################################################

"""
The `showmsg` function converts the argument into an appropriate web component
creation message to the web client.
Default is to find the `MIME"text/html"` or `MIME"text/plain"` representation
and use it as the html parameter of an `html-node` web component.
Specialize this function by the argument type to create specific web components.
(see Katex type)
"""
function showmsg(obj::Any, opts::Dict=Dict())
  buf = IOBuffer()
  if method_exists(show, (IO, MIME"text/html", typeof(obj)))
    show(buf, MIME"text/html"(), obj)
  elseif method_exists(show, (IO, MIME"text/plain", typeof(obj)))
    show(buf, MIME"text/plain"(), obj)
  else
    error("no show function found for type $(typeof(obj))")
  end

  args = Dict(:newnid   => getnid(),
              :compname => "html-node",
              :params   => Dict(:html => takebuf_string(buf)),
              :deco     => opts)

  sendcurrent("append", args)
  nothing
end
