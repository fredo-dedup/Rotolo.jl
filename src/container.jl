
type Container
  nid::Int
  name::Symbol
  parent::Nullable{Container}
  subcontainers::Vector{Container}
end

Container(nid::Int, name::Symbol,
          parent::Nullable{Container}=Nullable{Container}()) =
  Container(nid, name, parent, Container[])

function newcontainer(name::Symbol, parent::Container,
                      opts::Dict=Dict())
  nid = getnid()
  nct = Container(nid, name, Nullable(parent))

  args = merge(opts,
               Dict(:newnid => nid,
                    :compname => "html-node",
                    :params => Dict(:html=>"")))

  _send(currentSession, parent.nid, "append", args)

  push!(parent.subcontainers, nct)
  nct
end

# walk the container tree, creating containers along the way
# if they do not exist
function findorcreate(ct::Container, path::Vector{Symbol},
                      opts::Dict)
  nn = shift!(path)
  ict = findfirst(e -> e.name == nn, ct.subcontainers)
  if length(path) == 0 # we are at the leaf node
    if ict == 0  # no container with this name => create
      nct = newcontainer(nn, ct, opts) # apply opts only on leaf
    else # container exists => clear
      nct = ct.subcontainers[ict]
      _send(currentSession, nct.nid, "clear")
    end
    nct
  else
    nct = ict == 0 ? newcontainer(nn, ct) : ct.subcontainers[ict]
    findorcreate(nct, path, opts)
  end
end

macro container(args...)
  name = [Symbol(randstring())]
  opts = Dict()
  for a in args
    nt = unfold(a) # try to interpret as container name path
    if length(nt) != 0
      name = nt
    elseif typeof(a) == Expr && a.head == :(=>)
      opts[a.args[1]] = a.args[2]
    else
      error("cannot parse argument '$a'")
    end
  end

  # create or clear container identified by its path in `name`
  nct = findorcreate(currentSession.root_container, name, opts)
  currentSession.active_container = nct
end


unfold(ex::Any) = NTuple()
unfold(ex::Symbol) = [ex]
function unfold(ex::Expr)
  ex.head != :. && return Symbol[]
  lexpr = unfold(ex.args[1])
  length(lexpr) == 0 && return Symbol[]
  push!(lexpr, ex.args[2].args[1])
  lexpr
end


# ex = :(abcd.qsdf.sd)
# res = unfold(:(abcd.qsdf.sd))
# tuple(res...)
# res[1:end-1]
# unfold(:( aze-45 ))
# unfold(:( aze=45 ))
# unfold(:( aze => abcd.sdf ))
# unfold(:(abcd.yo))
