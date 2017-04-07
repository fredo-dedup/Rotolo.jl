
type Container
  nid::Int
  parent::Nullable{Container}
  subcontainers::Dict{Symbol,Container}
end

# Simplified constructor for usual cases (i.e. not the root container)
function Container(parent::Container, opts::Dict=Dict())
  nid = getnid()
  nct = Container(nid, Nullable(parent), Dict{Symbol,Container}())

  args = merge(opts,
               Dict(:newnid => nid,
                    :compname => "html-node",
                    :params => Dict(:html=>"")))

  send(currentSession, parent.nid, "append", args)

  nct
end

#
# function newcontainer(name::Symbol, parent::Container,
#                       opts::Dict=Dict())
#   nid = getnid()
#   nct = Container(nid, name, Nullable(parent))
#
#   args = merge(opts,
#                Dict(:newnid => nid,
#                     :compname => "html-node",
#                     :params => Dict(:html=>"")))
#
#   _send(currentSession, parent.nid, "append", args)
#
#   push!(parent.subcontainers, nct)
#   nct
# end

# walk the container tree, creating containers along the way
# if they do not exist
function findorcreate(ct::Container, path::Vector{Symbol},
                      opts::Dict)
  nn = shift!(path)
  if length(path) == 0 # we are at the leaf node
    if haskey(ct.subcontainers, nn) # container exists => clear
      nct = ct.subcontainers[nn]
      send(currentSession, nct.nid, "clear", opts)
    else  # no container with this name => create
      nct = Container(ct, opts) # apply opts only on leaf
      ct.subcontainers[nn] = nct
    end
    return nct
  else
    if ! haskey(ct.subcontainers, nn)  # no container with this name => create
      ct.subcontainers[nn] = Container(ct) # no opts, opts apply only to leaf
    end
    return findorcreate(ct.subcontainers[nn], path, opts)
  end
end


# walk the container tree, creating containers along the way
# if they do not exist
# function findorcreate(ct::Container, path::Vector{Symbol},
#                       opts::Dict)
#   nn = shift!(path)
#   ict = findfirst(e -> e.name == nn, ct.subcontainers)
#   if length(path) == 0 # we are at the leaf node
#     if ict == 0  # no container with this name => create
#       nct = newcontainer(nn, ct, opts) # apply opts only on leaf
#     else # container exists => clear
#       nct = ct.subcontainers[ict]
#       _send(currentSession, nct.nid, "clear", opts)
#     end
#     nct
#   else
#     nct = ict == 0 ? newcontainer(nn, ct) : ct.subcontainers[ict]
#     findorcreate(nct, path, opts)
#   end
# end

macro container(args...)
  others, opts = parseargs(args...)

  name = [Symbol(randstring())]
  if length(others) > 0
    nt = unfold(others[1]) # try to interpret as container name path
    length(nt) > 0 && (name = nt)
  end

  # create or clear container identified by its path in `name`
  nct = findorcreate(currentSession.root_container, name, opts)
  currentSession.active_container = nct
end
