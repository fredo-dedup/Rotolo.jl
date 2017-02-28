############ user commands ##################

macro chunk(args...)
  cn = "_chunk$(length(currentChunk.children)+1)" # default chunk name
  length(args) == 0 && return chunk(cn)

  i0 = 1
  if isa(args[1], Symbol)  # we will presume it is the session name
      cn = string(args[1])
      i0 += 1
  end

  i0 > length(args) && return chunk(cn)

  style(x) = try
               foldl(|>, x, map(eval, args[i0:end]))
             catch e
               error("can't evaluate formatting functions, error $e")
             end

  chunk(cn, style)
end

function chunk(name, style=nothing)
    global currentChunk

    currentSession==nothing && session("session") # open new session

    # if name in currentSession.chunknames # replace existing chunk
    #     index = indexin([name], currentSession.chunknames)[1]
    #     currentSession.chunks[index] = []
    #     currentSession.chunkstyles[index] = style
    #     currentChunk = currentSession.chunks[index]
    # else
        nc = style==nothing ? Chunk(name) : Chunk(name, style)
        push!(currentChunk.children, nc)
        nc.parent = currentChunk
        currentChunk = nc
    # end

    notify(currentSession.updated)
    nothing
end


function addtochunk(t)
    println("addtochunk $t ($(typeof(t)))")
    Base.show_backtrace(STDOUT, backtrace())
    println()

    currentSession==nothing &&
      error("No active session yet")

    push!(currentChunk.children, t)
    notify(currentSession.updated)
    nothing
end

function stationary(f::Function, signals::Signal...)
    st = lift(f, signals...)
    addtochunk(empty)
    ch   = currentChunk
    slot = length(currentChunk)
    lift(st) do nt
        ch[slot] = nt
        notify(updated)
    end
end
