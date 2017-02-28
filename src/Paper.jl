# ideas :
# alt : catch writemime calls, as if in debugging mode ? and use Signals...
# alt : lookup watch_io in stdio.jl
# alt : Traits pour capter appels à writemime ?

# new func :
# add : force browser focus on bottom of current
# add : command to switch to another session
# add : tree struct for chunks, referenced like a file struct

# issues :
# issue : check if server already running, if yes reset
# issue : multiple evaluation returning only last value
# issue : pyplot showing multiple times, sometimes impossible to remove but with a F5
# issue : widget signal not caught
# issue : all text output caught and not shown

# DONE :
# add : Matplotlib Tiles - OK
# add : commands to load Escher assets - OK

__precompile__(false)

module Paper

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

end
