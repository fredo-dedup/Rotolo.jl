
module Rotolo

using HttpServer, WebSockets
using Requires

import JSON

import Base: send, display

include("redirect.jl")
include("style.jl")
include("container.jl")
include("session.jl")
include("utils.jl")

@require Atom include("atom_integration.jl")

global currentSession
global isDisplayed = true
global sessions = Dict{String, Session}()

export display, @redirect
export @session, @container, @style

end # module
