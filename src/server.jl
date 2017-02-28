########################################################################################
#  Server setup
#   - mostly a copy of Escher's "src/cli/serve.jl"
########################################################################################

include(Pkg.dir("Escher", "src", "cli", "serve.jl"))

### specific socket definition for Paper's purpose
function uisocket(req)
    sn = req[:params][:session] # session name
    println("session : $sn ($(typeof(sn)))  => $(symbol(sn))")
    session = sessions[string(sn)]

    d = query_dict(req[:query])

    w = @compat parse(Int, d["w"])
    h = @compat parse(Int, d["h"])

    sock = req[:socket]
    tilestream = Input{Signal}(Input{Tile}(empty))

    # TODO: Initialize window with session,
    # window dimensions and what not

    window = Window(dimension=(w*px, h*px))
    session.window = window

    # import by default
    # write(sock, JSON.json(import_cmd("tex")))
    # write(sock, JSON.json(import_cmd("widgets")))

    lift(asset -> write(sock, JSON.json(import_cmd(asset))),
         window.assets)

    newstream = build(session)
    swap!(tilestream, newstream)

    start_updates(flatten(tilestream, typ=Any), window, sock, "root")

    # client commands processing ?
    @async while isopen(sock)
        try
            data = read(sock)
            msg = JSON.parse(bytestring(data))
            if !haskey(commands, msg["command"])
                warn("Unknown command received ", msg["command"])
            else
                commands[msg["command"]](window, msg)
            end
        catch
            error("\nError while reading from websocket, closing session $sn")
        end
    end

    while isopen(sock)
        wait(session.updated)
        newstream = build(session)
        try
            swap!(tilestream, newstream)
        catch err
            error("\nError while updating, closing session $sn")
        end
    end
end

### builds the Escher page structure
function build(chunk::Chunk, parentname::AbstractString)
    # session = p.sessions[:abcd]
    dashedborder(t)  = t |> borderwidth(1px) |> bordercolor("#aaa") |>
                        borderstyle(dashed)
    italicmessage(t) = t |> fontcolor("#aaa") |> fontstyle(italic)

    currentname = parentname * "/" * chunk.name
    try
        nbel = length(chunk.children)
        # println("build, nbel = $nbel")
        if nbel==0
          ret = title(1, currentname) |> italicmessage
        else
          ret = map(c -> build(c, currentname), chunk.children)
        end

        ret = ret |> chunk.styling
        if chunk==currentChunk
           ret = ret |> dashedborder
        end

        return ret
    catch err
        bt = catch_backtrace()
        str = sprint() do io
            showerror(io, err)
            Base.show_backtrace(io, bt)
        end
        return Elem(:pre, str)
    end
end

build(session::Session)    = build(session.rootchunk, "")
build(t, ::AbstractString) = t

### initializes the server
function init(port_hint=5555)
    global serverid, port

    println("init")

    # App
    @app static = (
        Mux.defaults,
        route("pkg/:pkg", packagefiles("assets"), Mux.notfound()),
        route("assets", Mux.files(Pkg.dir("Escher", "assets")), Mux.notfound()),
        route("/:session", req -> setup_socket(req[:params][:session]) ),
        # route("/", req -> setup_socket("Paper")),
        Mux.notfound(),
    )

    @app comm = (
        Mux.wdefaults,
        route("/socket/:session", uisocket),
        Mux.wclose,
        Mux.notfound(),
    )

    #find open port
    port, sock = listenany(port_hint) # find an available port
    close(sock)
    serverid = @async serve(static, comm, port)
end

# TODO
# macro restart_server()
# end

function session(name::AbstractString, style=nothing)
    global currentSession, currentChunk

    haskey(sessions, name) && error("There is already a session '$name'")

    newsession     = style==nothing ? Session() : Session(style)
    sessions[name] = newsession
    currentSession = newsession
    currentChunk   = newsession.rootchunk

    serverid == nothing && init() # launch server if needed

    fulladdr = "http://127.0.0.1:$port/$name"
    @linux_only   run(`xdg-open $fulladdr`)
    @osx_only     run(`open $fulladdr`)
    @windows_only run(`cmd /c start $fulladdr`)
end

macro session(args...)
    sn = "_session$(length(sessions)+1)" # default session name
    length(args) == 0 && return session(sn)

    i0 = 1
    if isa(args[1], Symbol)  # we will presume it is the session name
        sn = string(args[1])
        i0 += 1
    end

    i0 > length(args) && return session(sn)

    style(x) = try
                 foldl(|>, x, map(eval, args[i0:end]))
               catch e
                 error("can't evaluate formatting functions, error $e")
               end

    session(sn, style)
end

macro loadasset(args...)
    currentSession == nothing && error("No session active yet, run @session")
    currentSession.window == nothing &&
        error("No window for this session yet")

    for a in args
        if isa(a, AbstractString)
            push!(currentSession.window.assets, a)
        else
            warn("$a is not a string")
        end
    end
end

# TODO : close_session, switch session
