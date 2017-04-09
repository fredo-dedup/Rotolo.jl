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

  eval(emod, :( using Rotolo ))
  eval(emod.Rotolo, :( isDisplayed = false ))

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
          ret = try
                  eval(emod, ast)
                catch err
                  println("\nerror encountered at line $counter in $ast")
                  rethrow()
                end
          # println(ret)
          if ret != nothing && emod.isdefined(:Rotolo)
            println(ret)
            if isa(ret, emod.Rotolo.Session)  # session has just been defined
              oio = open(ret.filename)
              @async outputbuf = renderhtml(oio, format="pdf")
            else
              
              emod.display(ret)
            end
          end
      end
      hit_eof && break
  end

  write(dio, outputbuf)
  eval(emod.Rotolo, :(isDisplayed = true))
end
