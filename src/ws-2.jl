using HttpServer
using WebSockets

msgc = Channel{String}(5)

wsh2 = WebSocketHandler() do req,client
  try
    for m in msgc

      println("sending $m")  # msg = read(client)
      write(client, m)
    end
  catch e
    println("exiting send loop")
  end
end

handler = HttpHandler() do req, res
  rsp = Response(100)
  rsp.headers["Access-Control-Allow-Origin"] =
    "http://localhost:8080"
  rsp.headers["Access-Control-Allow-Credentials"] =
    "true"
  rsp
end

tsk = @async run(Server(handler, wsh2),
                 8081)

# close(msgc)

##############################################################

id = 200
newid() = (global id ; id += 1 ; id)

##############################################################

import JSON

msg = Dict(:nid      => 1,
           :command => "append",
           :payload => Dict(:nid => newid(),
                            :params => Dict(:html => "html text"),
                            :compname => "html-node",
                            :style  => "color:red"))

put!(msgc, JSON.json(msg))

msg2 = Dict(:nid     => 212,
            :command => "append",
            :payload => Dict(:nid => newid(),
                             :params => Dict(:html => "inner html text"),
                             :compname => "html-node" ) )

put!(msgc, JSON.json(msg2))

msg3 = Dict(:nid     => 1,
            :command => "append",
            :payload => Dict(:nid => newid(),
                             :params => Dict(:msg => "test message"),
                             :compname => "testcomp" ) )

put!(msgc, JSON.json(msg3))



id = 200
newid() = (global id ; id += 1 ; id)

newid()

msg = Dict(:nid      => 1,
           :command => "append",
           :payload => Dict(:nid => newid(),
                            :html => "<button type='button'>Click Me!</button>"))
put!(msgc, JSON.json(msg))


msg3 = Dict(:nid     => 1,
            :command => "append",
            :payload => Dict(:nid => 3,
                             :html => "container",
                             :style => "display:flex"))

put!(msgc, JSON.json(msg3))

msg3 = Dict(:nid     => 3,
            :command => "append",
            :payload => Dict(:nid => 31,
                             :html => "-element2-"))

put!(msgc, JSON.json(msg3))


gensym("comp")
