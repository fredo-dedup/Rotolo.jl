
module Rotolo

using HttpServer, WebSockets
using Requires
import HeadlessChromium

import JSON

import Base: send, display

include("redirect.jl")
include("style.jl")
include("container.jl")
include("session.jl")
include("utils.jl")
include("messaging.jl")
# include("compile.jl")

@require Atom include("atom_integration.jl")


### plugins = objects in documents with add-hoc web components and behaviour
include("plugins/katex.jl")




global currentSession = nothing
global sessions = Dict{String, Session}()

global isHeadless = false

function headless(h::Bool)
  global isHeadless = h
end
headless() = isHeadless

export @redirect, @session, @container, @style
export compile, isredirected, headless

end # module
