
type Session
  channel::Channel{String}
  port::Int
  nid_counter::Int
  root_container::Container
  active_container::Container
  filename::String
end

function Session(sessionId, opts::Dict)
  # find an available port
  xport, sock = listenany(5000)
  close(sock)
  port = Int(xport)

  chan = Channel{String}(100) # create Channel for message queue

  launchServer(chan, port) # launch communication server
  filename = createPage(sessionId, port)

  # Since container #1 already exists in the Vuejs client, no need to send
  # message to create the web component. Hence the Container constructor function
  # should not be called, only the plain type constructor.
  # root container has nid = 1 and no parent
  ct = Container(1, Nullable{Container}(), Dict{Symbol,Container}())

  ns = Session(chan, port, 1, ct, ct, filename)

  # In case there are opts, send them to the root container
  length(opts) > 1 && send(ns, 1, "clear", Dict(:deco=>opts))

  ns
end

function getnid()
  currentSession.nid_counter += 1
  currentSession.nid_counter
end


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
    send(sessions[sessionId], 1, "clear", Dict(:deco=>opts))
  else # create page, launch server, etc.
    ns = Session(sessionId, opts)
    sessions[sessionId] = ns
    isDisplayed && openBrowser(ns.filename)
  end
  currentSession = sessions[sessionId]
  nothing
end

function launchServer(chan::Channel, port::Int)
  wsh = WebSocketHandler() do req,client
    for m in chan
      println("sending $m")  # msg = read(client)
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

  @async run(Server(handler, wsh), port)
end

function createPage(sname::String, port::Int)
  sid = tempname()
  tmppath = string(sid, ".html")
  scriptpath = joinpath(dirname(@__FILE__), "../client/build.js")
  # scriptpath = "D:/frtestar/devl/paper-client/dist/build.js"
  # scriptpath = "/home/fred/Documents/Dropbox/devls/paper-client/dist/build.js"
  requirepath = joinpath(dirname(@__FILE__), "../client/require.js")

  open(tmppath, "w") do io
    println(io,
      """
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
