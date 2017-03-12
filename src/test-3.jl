
sid = tempname()
tmppath = string(sid, ".rotolo.html")
scriptpath = joinpath(dirname(@__FILE__), "../client/build.js")

open(tmppath, "w") do io
  title = split(sid, "/")[3]
  println(io,
    """
    <html>
      <head>
        <title>$title</title>
        <meta charset="UTF-8">
        <script src='$scriptpath'></script>
        <script> sessionId = $sid ; </script>
      </head>
      <body></body>
    </html>
    """)
end

run(`xdg-open $tmppath`)
