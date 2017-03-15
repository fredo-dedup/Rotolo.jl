
module Rotolo

using HttpServer
using WebSockets
using Requires

import JSON

import Base.send

include("atom_integration.jl")

######################################################

type Session
  channel::Channel{String}
  port::Int
  nid_counter::Int
  active_nid::Int
end

Session(channel, port) = Session(channel, port, 1, 1)

function getnid()
  sess = sessions[end]
  sess.nid_counter += 1
  sess.nid_counter
end

sessions = Dict{String, Session}()

function send(sid::String, nid::Int, command::String,
              args::Dict{Symbol,Any}=Dict{Symbol,Any}())
  msg = Dict{Symbol, Any}()
  msg[:nid] = nid
  msg[:command] = command
  msg[:args] = args

  if haskey(sessions, sid)
    put!(sessions[sid].channel, JSON.json(msg))
  else
    error("[send] no session $sid registered")
  end
end

macro session(args...)
  sessionId = length(args)==0 ? randstring() : string(args[1])

  if sessionId in keys(sessions) # already opened, just clear the page
    send(sessionId, 0, "clear")
  else # create page
    xport, sock = listenany(5000) # find an available port
    close(sock)
    port = Int(xport)
    chan = Channel{String}(10)
    sessions[sessionId] = Session(chan, port)
    launchServer(chan, port)
    spinPage(sessionId, port)
  end
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
    rsp.headers["Access-Control-Allow-Origin"] =
      "http://localhost:8080"
    rsp.headers["Access-Control-Allow-Credentials"] =
      "true"
    rsp
  end

  @async run(Server(handler, wsh), port)
end

function spinPage(sname::String, port::Int)
  sid = tempname()
  tmppath = string(sid, ".html")
  # scriptpath = joinpath(dirname(@__FILE__), "../client/build.js")
  # scriptpath = "D:/frtestar/devl/paper-client/dist/build.js"
  scriptpath = "/home/fred/Documents/Dropbox/devls/paper-client/dist/build.js"

  open(tmppath, "w") do io
    println(io,
      """
      <html>
        <head>
          <title>$sname</title>
          <meta charset="UTF-8">
          <script>
            serverPort = '$port'
          </script>
        </head>
        <body>
          <div id="app"></div>
          <script src='$scriptpath'></script>

        </body>
      </html>
      """)
  end

  run(`xdg-open $tmppath`)
  # run(`cmd /c start $tmppath`)
end


end # module
