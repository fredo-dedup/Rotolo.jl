
module Rotolo

using HttpServer, WebSockets
using Requires
using PhantomJS

import JSON

import Base: send, display

include("redirect.jl")
include("style.jl")
include("container.jl")
include("session.jl")
include("utils.jl")
include("messaging.jl")
include("compile.jl")

@require Atom include("atom_integration.jl")

include("katex.jl")

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
