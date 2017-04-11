############################################################################
#   Compilation function : compile()
############################################################################

function compile(sourcepath::String,
                 destpath::String)
  open(sourcepath, "r") do sio
    open(destpath, "w") do dio
      compile(sio, dio)
    end
  end
end

function compile(sio::IO, dio::IO)
  emod = Module(gensym())

  Rotolo.headless(true)
  println("isHeadless ", Rotolo.isHeadless)

  hit_eof = false
  counter = 0
  outputbuf = UInt8[]
  while true
    line = ""
    ast = nothing
    while true
      try
          line *= readline(sio)
          counter += 1
      catch e
          if isa(e,EOFError)
              hit_eof = true
              break
          else
              rethrow()
          end
      end
      ast = Base.parse_input_line(line)
      (isa(ast,Expr) && ast.head == :incomplete) || break
    end
    if !isempty(line)
      println("line : $line")
      ret = try
              eval(emod, ast)
            catch err
              println("\nerror encountered in line #$counter : $line")
              rethrow()
            end
      if ret != nothing
        println("value : $ret")
        if isa(ret, Session)  # session has just been defined
          println("filename = ", ret.filename)
          sleep(3)
          oio = open(ret.filename)
          @async outputbuf = PhantomJS.renderhtml(oio, format="pdf")
          sleep(10)
        elseif isredirected(typeof(ret))
          println("showing ret ($(typeof(ret)))")
          Rotolo.showmsg(ret)
        end
      end
    end
    (isempty(line) || hit_eof) && break
  end

  write(dio, outputbuf)
  eval(emod, :( Rotolo.headless(false) ))
end
