using Rotolo

@session fromJuno

@redirect Float64

456.4

import Media
import Atom
import Media: render

@media MauritsThing
setdisplay(MauritsThing, Rotolo.RotoloDisplay())

media(Float64, Rotolo.RotoloDisplay)

function Media.render(::Rotolo.RotoloDisplay, x::Float64)
  Rotolo.send("append",
       Dict(:newnid => Rotolo.getnid(),
            :compname => "html-node",
            :params => Dict(:html=> string(x) )))
end


show(4654.5)
456.5

Media.render(::)

function rewire(func::Function, t::Type)
  media(t, MauritsThing)
  @eval function render(::MauritsDisplay, x::$t)
        ($func)(x)
        string(x)
      end

  @eval render(::Atom.Editor, x::$t) = render(md, x)

end
rewire(t::Type)  = rewire(addtochunk, t)



reload("Rotolo")

import Rotolo
import Rotolo: @session, send

@session test

using Base.Markdown

Rotolo.redirect(Base.Markdown.MD)

@session

Rotolo.sessions

send("test", 1, "append",
     Dict(:newnid => 101,
          :compname => "html-node",
          :params => Dict(:html=>"hello from Julia")))





using Base.Markdown

str = md"test **test** test"
typeof(str)
methodswith(Markdown.MD)

type Abcd
  x::String
end

Abcd("test")

show(io::IO, ::MIME"text/plain",x::Abcd) = show(io, "Abcd : $(x.x)")

function show(io::IO, x::Abcd)
  show(io, "Abcd : $(x.x)")
end

show(Abcd("testtest"))

methods(show, (IO, Abcd))


strbuf = IOBuffer()
show(strbuf, MIME"text/html"(), str)
str2 = takebuf_string(strbuf)

send("test", 1, "append",
     Dict(:newnid   => 103,
          :compname => "html-node",
          :params => Dict(:html     => str2)))

####################################################""
import Base.show

meth
invoke(meth, (), )
meth = methods(show, (IO, MIME"text/html", Markdown.MD)).ms[1]
fieldnames(meth)


redirect(Abcd)

Abcd("yo")
methods(show, (IO, MIME"text/plain", Abcd))

show(Abcd("yoyo"))

t = Abcd
@eval quote
        function show(io::IO, mt::MIME"text/html", x::$t)

          send("test", 1, "append",
               Dict(:newnid => 101,
                    :compname => "html-node",
                    :params => Dict(:html=>"show")))

          ($meth)(io, mt, x)
        end
      end


function redirect(t::Type)
  # t = Base.Markdown.MD
  # abcd = sfunc(md"**abcd**")

  if method_exists(show, (IO, MIME"text/html", t))
    sfunc = function (x)
      buf = IOBuffer()
      show(buf, MIME"text/html"(), x)
      takebuf_string(buf)
    end
  elseif method_exists(show, (IO, MIME"text/plain", t))
    sfunc = function (x)
      buf = IOBuffer()
      show(buf, MIME"text/plain"(), x)
      takebuf_string(buf)
    end
  else
    error("no show function found for $t")
  end

  @eval quote
          function show(io::IO, mt::MIME"text/plain", x::$t)
            str = ($sfunc)(x)

            send("test", 1, "append",
                 Dict(:newnid => 101,
                      :compname => "html-node",
                      :params => Dict(:html=>str)))
          end
        end

  nothing
end




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
