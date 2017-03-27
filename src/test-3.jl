reload("Rotolo")

module Try
end

module Try
using Rotolo

using Base.Markdown

@redirect Float32 Base.Markdown.MD

Rotolo.sessions

@session d1

cs = Rotolo.currentSession
function xplore(ct, level=0)
  println(" "^level, ct.name, " ($(ct.nid))")
  for c in ct.subcontainers
    xplore(c, level+2)
  end
end

xplore(cs.root_container)

@container abcd
xplore(cs.root_container)

@container cyz
xplore(cs.root_container)

@container
xplore(cs.root_container)

Rotolo.@container abcd.yo
xplore(cs.root_container)

md"test"
Float32(123)

Rotolo.@container abcd.yourk style=>"font-color:red"
xplore(cs.root_container)

md"test"


using DataFrames
@redirect DataFrame
DataFrames.head(Main.comp)



Rotolo.unfold(:(abcd.yo))

macro test(arg)
  dump(arg)
  println(Rotolo.unfold(arg))
end

@test abcd
@test abcd.youi.yo456

#################################################################################

Rotolo._send(Rotolo.currentSession, 0,
             "load",
             Dict{Symbol,Any}(:assetname => "katex",
                              # :assetpath => "D:/frtestar/.julia/v0.5/Rotolo/client/katex/katex.js",
                              :assetpath => "/home/fred/.julia/v0.5/Rotolo/client/katex/katex.js")
            )

Rotolo.send("append",
     Dict(:newnid => Rotolo.getnid(),
          :compname => "katex",
          :params => Dict(:expr => "x^2+y_x=a")))

###############################

Rotolo._send(Rotolo.currentSession, 0,
             "load",
             Dict{Symbol,Any}(:assetname => "vegalite",
            #  :assetpath => "D:/frtestar/.julia/v0.5/Rotolo/client/vegalite/vegalite.js")
             :assetpath => "/home/fred/.julia/v0.5/Rotolo/client/VegaLite/vegalite.js")
            )

Rotolo.send("append",
     Dict(:newnid => Rotolo.getnid(),
          :compname => "vegalite",
          :params => Dict(:test => "abcd")))

####################


Rotolo._send(Rotolo.currentSession, 0,
             "load",
             Dict{Symbol,Any}(:assetname => "katex",
                              # :assetpath => "D:/frtestar/.julia/v0.5/Rotolo/client/katex/katex.js",
                              :assetpath => "/home/fred/.julia/v0.5/Rotolo/client/katex/katex.js")
            )

Rotolo.send("append",
     Dict(:newnid => Rotolo.getnid(),
          :compname => "katex",
          :params => Dict(:expr => "x^2+y_x=a")))










Rotolo._send(Rotolo.currentSession, 0,
             "load", Dict{Symbol,Any}(:assetname => "vegalite",
                          :assetpath => "../vegalite.js"))

D:/frtestar/.julia/v0.5/Rotolo/client/katex/ka
D:\frtestar\devl\paper-client\dist


Rotolo.send("append",
     Dict(:newnid => Rotolo.getnid(),
          :compname => "vegalite",
          :params => Dict(:expr => "x^2+y_x=a")))



456.4
Float32(456.54)

# import Media, Atom
# methods(Media.render, (Atom.Editor, Any))

md"""
  markdown Text
  # titleqsdqsd

  qsdfdf
  - qsdfgqdg
  - dfgqdrg

  ```
  code_llvm
  ```

  text *text*  qsdf  **qdfgqf**
  """



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


############################################################

Pkg.build("Rotolo")

p = ccall((:nlopt_create,libnlopt), _Opt, (Cenum, Cuint),
          algorithm, n)

lpath = "D:/frtestar/.julia/v0.5/Rotolo/deps/usr/lib/wkhtmltox.dll"
libwk = Libdl.dlopen(lpath, Libdl.RTLD_LAZY)

lpath = "C:/HOMEWARE/julia/Julia-0.5.0/bin/libgmp.dll"
libwk = Libdl.dlopen(lpath, Libdl.RTLD_LAZY)

import Rotolo
typeof(Rotolo.libwkhtml)


##############################################################

include("wkhtmltox.jl")

vers = ccall((:wkhtmltopdf_version, libwkhtml), Cstring, ())
unsafe_string(vers)

init(0)

gs = create_global_settings()

set_global_setting(gs, "out", "c:\\temp\\example.pdf")
get_global_setting(gs, "out")

set_global_setting(gs, "out", "c:\\temp\\example.png")
get_global_setting(gs, "out")



get_global_setting(gs, "resolution")
get_global_setting(gs, "orientation")
get_global_setting(gs, "margin.top")

get_global_setting(gs, "smartWidth")



os = create_object_settings()
set_object_setting(os, "page", "c:\\temp\\example.html")
get_object_setting(os, "page")

conv = create_converter(gs)

add_object(conv, os, C_NULL);

wkconvert(conv)

# wkhtmltopdf_set_progress_changed_callback(c, progress_changed);
# wkhtmltopdf_set_phase_changed_callback(c, phase_changed);
# wkhtmltopdf_set_error_callback(c, error);
# wkhtmltopdf_set_warning_callback(c, warning);

destroy_converter(conv);

deinit();
