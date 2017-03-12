module Rotolo.jl

using Compat
using Reexport

using Requires
using Mux
using JSON

using Patchwork
@reexport using Reactive
@reexport using Escher

import Compose

serverid       = nothing      # server Task

type Chunk
  name::AbstractString
  children::Vector
  parent::Nullable{Chunk}
  styling::Function
end
Chunk() = Chunk(string(gensym("chunk")))
Chunk(style::Function) = Chunk(string(gensym("chunk")), style)
Chunk(name::AbstractString) = Chunk(name, vbox) # vertical layout default
Chunk(n::AbstractString, st::Function) =
  Chunk(n, Any[], Nullable{Chunk}(), st)

currentChunk   = nothing      # active chunk


type Session
  rootchunk::Chunk
  window::Window
  updated::Condition

  function Session(st::Function=vbox) # vertical layout default
    s = new()
    s.rootchunk = Chunk("", st)
    s.updated = Condition()
    s
  end
end

sessions = Dict{UTF8String, Session}()
currentSession = nothing      # active session

include("server.jl")
include("commands.jl")
# include("rewire.jl")
include("redisplay.jl")

export @chunk, @session, @rewire, @loadasset, rewire
export stationary
# export writemime

# package code goes here

end # module
