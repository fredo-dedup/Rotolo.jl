#############################################################################
# Web client messaging functions
#############################################################################

"""
The `showmsg` function converts the argument into an appropriate web component
creation message to the web client.
Default method tries to find the `MIME"text/html"` or `MIME"text/plain"` representation
and use it as the html parameter of an `html-node` web component.
Specialize this function by the `obj` argument type to create specific web components.
(see Katex type for an example)
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



"""
The `loadmsg` function instructs the web client to load the necessary javascript
code defining a new component in the current session.
This function is called for each specified type given as argument to the
`@redirect` macro call.
Default method does nothing since the default web component `html-node` is
present by default in the Vuejs client.
Specialize this function by the argument type to load new web components in the
current session (see Katex type).
"""
function loadmsg(::Type)
end
