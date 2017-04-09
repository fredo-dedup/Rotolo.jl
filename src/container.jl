
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

# walk the container tree, creating containers along the way
# if they do not exist
function findorcreate(ct::Container, path::Vector{Symbol},
                      index::Int, opts::Dict)
  nn = path[index]
  if length(path) == index # we are at the leaf container
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
    return findorcreate(ct.subcontainers[nn], path, index+1, opts)
  end
end

macro container(args...)
  objects, opts = parseargs(args...)

  name = [Symbol(randstring())]
  if length(objects) > 0
    nt = unfold(objects[1]) # try to interpret as container name path
    length(nt) > 0 && (name = nt)
  end

  # create or clear container identified by its path in `name`
  nct = findorcreate(currentSession.root_container, name, 1, opts)
  currentSession.active_container = nct
end
