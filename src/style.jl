

"""
`@style(object, args)` forces the displaying of `object` (even if it is not of a
  redirected type). `args` are pairs `parameter => string` for the styling of the
  display.
"""
macro style(obj, args...)
  _, opts = parseargs(args...)

  try
    obj = eval(current_module(), obj)
  catch
    error("cannot evaluate object $(obj)")
  end

  showmsg(obj, opts)
end
