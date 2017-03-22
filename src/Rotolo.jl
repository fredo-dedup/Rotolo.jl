
module Rotolo

using HttpServer, WebSockets
using Requires

import JSON

import Base: send, display

include("redirect.jl")
include("container.jl")
include("session.jl")

@require Atom include("atom_integration.jl")

export display, @redirect
export @session, @container

end # module
