############################################################################
#   Compilation function : compile()
############################################################################

compile(filepath::AbstractString) = open(compile, filepath, "r")

function compile(sio::IO)
  emod = Module(gensym())

  hit_eof = false
  counter = 0
  while true
      line = ""
      ast = nothing
      interrupted = false
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
                  println("\nerror encountered at line $counter : ")
                  rethrow()
                end
          # println(ret)
          ret != nothing &&
            emod.isdefined(:Paper) &&
            emod.isrewired(typeof(ret)) &&
            emod.Paper.Redisplay.render(emod.Paper.Redisplay.md, ret)
      end
      ((!interrupted && isempty(line)) || hit_eof) && break
  end
end
