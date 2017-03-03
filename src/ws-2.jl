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


begin

  put!(msgc, "et ta soeur")
  put!(msgc, "Noemie va dans la douche")
  put!(msgc, "<div style=\"color:red;margin: 10px 10px\"> azzzzzzzzzz </div>")

  put!(msgc,
       String(Node(:div, "#tst",
              Dict(:style=>"color:red"),
              "ABCD")))

  ob = Node(:div, "#tst",
            Dict(:style=>"color:red"),
            "ABCD")

  ob.attrs
  methodswith(typeof(ob))
  fieldnames(ob)

  Node(:div, "#tst", Dict(:style=>"color:green"),
            "ABCD")
end

using Hiccup
import JSON

msg = Dict(:nid      => 1,
           :command => "append",
           :payload => Dict(:nid => 23,
                            :html => "old",
                            :style => "color:green"))

put!(msgc, JSON.json(msg))

msg2 = Dict(:nid     => 2,
            :command => "append",
            :payload => Dict(:nid => 21,
                             :html => "newnew",
                             :style => "color:purple"))

put!(msgc, JSON.json(msg2))


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
