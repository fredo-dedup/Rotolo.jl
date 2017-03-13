

immutable Session
  channel::Channel{String}
  port::Int
end

sessions = Dict{String, Session}()

import Base.send
import JSON

function send(sid::String, nid::Int, command::String,
              params::Dict{Symbol,Any})
  msg = Dict{Symbol, Any}()
  msg[:nid] = nid
  msg[:command] = command
  msg[:params] = params

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

using HttpServer
using WebSockets

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
          <script src='$scriptpath'></script>
        </head>
        <body></body>
      </html>
      """)
  end

  run(`xdg-open $tmppath`)
  # run(`cmd /c start $tmppath`)
end

##################################################################


@session test3

send("test2", 1, "append",
     params=Dict(:newnid => 100,
                 :compname => "html-node",
                 :html=>"hello from Julia"))

using Base.Markdown

str = md"test **test** test"
typeof(str)
methodswith(Markdown.MD)


strbuf = IOBuffer()
show(strbuf, MIME"text/html"(), str)

send("test", 1, "append",
     params=Dict(:newnid => 101,
                 :compname => "html-node",
                 :html=>strbuf))

####################################################""
import Base.Multimedia.writemime


function rewire{T<:MIME}(func::Function, mt::Type{T}, t::Type)
   if method_exists(writemime, (IO, mt, t))
       meth = methods(writemime, (IO, mt, t))[1].func
       @eval quote
               function writemime(io::IO, mt::$mt, x::$t)


                   t_task()==currentTask && ($func)(x) # send only if interactive task
                   ($meth)(io, mt, x)
               end
            end
   else
       @eval quote
               function writemime(io::IO, mt::$mt, x::$t)
                   current_task()==currentTask && ($func)(x)
               end
            end
   end
   nothing
end

rewire(func::Function, t::Type) = rewire(func,       MIME"text/plain", t)
rewire(t::Type)                 = rewire(addtochunk, MIME"text/plain", t)

macro rewire(args...)
   for a in args
       try
           t = eval(a)
           if isa(t, Type)
               rewire(t)
           else
               warn("$a does not evaluate to a type")
           end
       catch e
           warn("can't evaluate $a, error $e")
       end
   end
   nothing
end


@rewire Base.Markdown.MD Tile Escher.TileList
