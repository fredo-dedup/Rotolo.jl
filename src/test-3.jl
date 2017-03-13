
sessions = Dict{String, Channel{String}}()

import Base.send
import JSON

function send(sid::String, nid::Int, command::String; args...)
  msg = Dict{Symbol, Any}()
  msg[:nid] = nid
  msg[:command] = command
  for (k,v) in args
    msg[k] = v
  end
  println(JSON.json(msg))
  if haskey(sessions, sid)
    put!(sessions[sid], JSON.json(msg))
  else
    error("[send] no session $sid registered")
  end
end

msgc = Channel{String}(5)

sessions["abcd"] = msgc

send("abcd", 1, "append", newnid=3, params=Dict(:html => "coucou"))


@async (m = take!(msgc) ; println(m))

@async (for m in msgc ; println(m) ; end ; println("out of loop"))
put!(msgc, "helloooo")
close(msgc)

#find open port
port, sock = listenany(5000) # find an available port
close(sock)
serverid = @async serve(static, comm, port)
Int(port)

put!(msgc, JSON.json(msg))
macro session(args...)
  sessionId = length(args)==0 ? randstring() : string(args[1])

  if sessionId in keys(sessions) # already opened, just clear the page
    send(sessionId, 0, "clear")
  else # create page



end

string(45.6)

sid = tempname()
tmppath = string(sid, ".rotolo.html")
scriptpath = joinpath(dirname(@__FILE__), "../client/build.js")
scriptpath = "D:/frtestar/devl/paper-client/dist/build.js"

open(tmppath, "w") do io
  title = basename(sid)
  println(io,
    """
    <html>
      <head>
        <title>$title</title>
        <meta charset="UTF-8">
        <script>
          sessionId = '$sid'
          serverPort = '$(Int(port))'
        </script>
        <script src='$scriptpath'></script>
      </head>
      <body></body>
    </html>
    """)
end

run(`xdg-open $tmppath`)
run(`cmd /c start $tmppath`)
