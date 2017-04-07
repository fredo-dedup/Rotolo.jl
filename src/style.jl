
#
# function style(obj, styl::String="")
#   buf = IOBuffer()
#   if method_exists(show, (IO, MIME"text/html", typeof(obj)))
#     show(buf, MIME"text/html"(), obj)
#   elseif method_exists(show, (IO, MIME"text/plain", typeof(obj)))
#     show(buf, MIME"text/plain"(), obj)
#   else
#     error("no show function found for type $(typeof(obj))")
#   end
#
#   args = Dict(:newnid => getnid(),
#               :compname => "html-node",
#               :params => Dict(:html => takebuf_string(buf)),
#               :style => styl)
#
#   send("append", args)
#   nothing
# end

"""
`@style(object, args)` forces the displaying of `object` (even if it is not of a
  redirected type). `args` are pairs `parameter => string` for the styling of the
  display.
"""
macro style(obj, args)

  others, opts = parseargs(args...)

  length(others) == 0 && error("no object to display found")

  try
    obj = eval(others[1])
  catch
    error("cannot evaluate object $(others[1])")
  end

  buf = IOBuffer()
  if method_exists(show, (IO, MIME"text/html", typeof(obj)))
    show(buf, MIME"text/html"(), obj)
  elseif method_exists(show, (IO, MIME"text/plain", typeof(obj)))
    show(buf, MIME"text/plain"(), obj)
  else
    error("no show function found for type $(typeof(obj))")
  end

  args = merge(opts,
               Dict(:newnid => getnid(),
                    :compname => "html-node",
                    :params => Dict(:html => takebuf_string(buf))))

  sendcurrent("append", args)
  nothing
end
