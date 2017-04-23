
type Session
  channel::Channel{String}
  port::Int
  name::String
  server::Server
  nid_counter::Int
  root_container::Container
  active_container::Container
  filename::String
  redirected_types::Set{DataType}
end

function Session(sessionId, opts::Dict)
  # find an available port
  xport, sock = listenany(5000)
  close(sock)
  port = Int(xport)

  chan = Channel{String}(1000) # Channel for message queue

  server = launchServer(chan, port) # launch communication server
  filename = createPage(sessionId, port)

  # Since container #1 already exists in the Vuejs client, no need to send
  # message to create the web component. Hence the Container constructor function
  # should not be called, only the plain type constructor.
  # Root container has nid = 1 and no parent
  ct = Container(1, Nullable{Container}(), Dict{Symbol,Container}())

  ns = Session(chan, port, sessionId, server, 1, ct, ct, filename, Set{DataType}())

  # In case there are opts, send them to the root container
  length(opts) > 1 && send(ns, 1, "clear", Dict(:deco=>opts))

  ns
end

function endsession()
  global currentSession
  currentSession == nothing && return

  close(currentSession.server)
  close(currentSession.channel)
  isfile(currentSession.filename) && rm(currentSession.filename)
  ## TODO remove redirected types
  delete!(sessions, currentSession.name)
  currentSession = nothing
end


function getnid()
  currentSession.nid_counter += 1
  currentSession.nid_counter
end

isredirected(t::Type) = currentSession != nothing &&
  t in currentSession.redirected_types

macro session(args...)
  global currentSession

  objects, opts = parseargs(args...)

  sessionId = randstring()
  if length(objects) > 0
    if isa(objects[1], String)
      sessionId = objects[1]
    elseif isa(objects[1], Symbol)
      sessionId = string(objects[1])
    end
  end
  println(sessionId)

  if sessionId in keys(sessions) # already opened, just clear the page
    s = sessions[sessionId]
    send(s, 1, "clear", Dict(:deco=>opts))
    s.root_container.subcontainers = Dict{Symbol,Container}()
  else # create page, launch server, etc.
    ns = Session(sessionId, opts)
    sessions[sessionId] = ns
    isHeadless || openBrowser(ns.filename)
  end
  currentSession = sessions[sessionId]
end

function launchServer(chan::Channel, port::Int)
  wsh = WebSocketHandler() do req,client
    for m in chan
      limited_println("sending $m")
      write(client, m)
    end
    println("exiting send loop for port $port")
  end

  handler = HttpHandler() do req, res
    rsp = Response(100)
    rsp.headers["Access-Control-Allow-Origin"] = "http://localhost:8080"
    rsp.headers["Access-Control-Allow-Credentials"] = "true"
    rsp
  end

  server = Server(handler, wsh)
  @async run(server, port)
  server
end

function createPage(sname::String, port::Int)
  sid = tempname()
  tmppath = string(sid, ".html")
  scriptpath = htmlpath(joinpath(dirname(@__FILE__), "../client/build.js"))
  requirepath = htmlpath(joinpath(dirname(@__FILE__), "../client/require.js"))

  open(tmppath, "w") do io
    println(io,
      """
      <!doctype html>
      <html>
        <head>
          <title>$sname</title>
          <meta charset="UTF-8">
          <script src='$requirepath'></script>
          <script> serverPort = '$port' </script>
        </head>
        <body>
          <div id="app"></div>
          <script src='$scriptpath'></script>
        </body>
      </html>
      """)
  end

  tmppath
end


function openBrowser(pagePath::String)
  @static if VERSION < v"0.5.0-"
    @osx_only run(`open $pagePath`)
    @windows_only run(`cmd /c start $pagePath`)
    @linux_only   run(`xdg-open $pagePath`)
  else
    if is_apple()
      run(`open $pagePath`)
    elseif is_windows()
      run(`cmd /c start $pagePath`)
    elseif is_linux()
      run(`xdg-open $pagePath`)
    end
  end
end
