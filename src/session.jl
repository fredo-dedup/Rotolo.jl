global currentSession
global isDisplayed = true
global sessions = Dict{String, Session}()

type Session
  channel::Channel{String}
  port::Int
  nid_counter::Int
  root_container::Container
  active_container::Container
  filename::String
end

function Session(sessionId)
  # find an available port
  xport, sock = listenany(5000)
  close(sock)
  port = Int(xport)
  # create Channel for message queue
  chan = Channel{String}(10)

  launchServer(chan, port)
  filename = createPage(sessionId, port)

  sessions[sessionId] = Session(chan, port, pagePath, opts)
  isDisplayed && openBrowser(pagePath)

  ct = Container(1, :root, opts) # root container has nid = 1 and name "root"
  Session(channel, port, 1, ct, ct, filename)
end

function getnid()
  currentSession.nid_counter += 1
  currentSession.nid_counter
end




macro session(args...)
  global currentSession

  others, opts = parseargs(args...)

  sessionId = randstring()
  if length(others) > 0
    if isa(others[1], String)
      sessionId = others[1]
    elseif isa(others[1], Symbol)
      sessionId = string(others[1])
    end
  end

  if sessionId in keys(sessions) # already opened, just clear the page
    send(sessions[sessionId], 1, "clear", opts)

  else # create page
    xport, sock = listenany(5000) # find an available port
    close(sock)
    port = Int(xport)
    chan = Channel{String}(10)
    launchServer(chan, port)
    pagePath = createPage(sessionId, port)
    sessions[sessionId] = Session(chan, port, pagePath, opts)
    isDisplayed && openBrowser(pagePath)
  end
  currentSession = sessions[sessionId]
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
