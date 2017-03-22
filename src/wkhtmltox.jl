include("../deps/deps.jl")

type GlobalSettings ; end
type ObjectSettings ; end
type Converter; end

function init(usegraphics::Int)
  ccall((:wkhtmltopdf_init, libwkhtml),
        Int, (Int,), usegraphics)
end

function deinit()
  ccall((:wkhtmltopdf_deinit, libwkhtml),
        Int, ())
end

function create_global_settings()
  ccall((:wkhtmltopdf_create_global_settings, libwkhtml),
        Ptr{GlobalSettings}, ())
end

function get_global_setting(gs::Ptr{GlobalSettings}, property::String)
  cval = zeros(UInt8, 100)
  ccall((:wkhtmltopdf_get_global_setting, libwkhtml),
        Int,
        (Ptr{GlobalSettings}, Cstring, Cstring, Int),
        gs, convert(Cstring, pointer(property)),
            convert(Cstring, pointer(cval)), sizeof(cval)-1 )
  unsafe_string(pointer(cval))
end

function set_global_setting(gs::Ptr{GlobalSettings}, property::String, value::String)
  ccall((:wkhtmltopdf_set_global_setting, libwkhtml),
        Int,
        (Ptr{GlobalSettings}, Cstring, Cstring),
        gs,
        convert(Cstring, pointer(property)),
        convert(Cstring, pointer(value)) )
end

# function get_global_setting(gs, property::String)
#   cval = Array(UInt8, 100)
#   ccall((:wkhtmltopdf_get_global_setting, libwkhtml),
#         Int,
#         (Ptr{Any}, Ptr{UInt8}, Ptr{UInt8}, Int),
#         gs, property, cval, sizeof(cval) )
#   cval[end] = 0
#   unsafe_string(pointer(cval))
# end

function create_object_settings()
  ccall((:wkhtmltopdf_create_object_settings, libwkhtml),
  Ptr{ObjectSettings}, ())
end

function set_object_setting(os::Ptr{ObjectSettings}, property::String, value::String)
  ccall( (:wkhtmltopdf_set_object_setting, libwkhtml),
        Int,
        (Ptr{ObjectSettings}, Cstring, Cstring),
        os,
        convert(Cstring, pointer(property)),
        convert(Cstring, pointer(value)) )
end


function get_object_setting(os::Ptr{ObjectSettings}, property::String)
  cval = zeros(UInt8, 100)
  ccall((:wkhtmltopdf_get_object_setting, libwkhtml),
        Int,
        (Ptr{ObjectSettings}, Cstring, Cstring, Int),
        os, convert(Cstring, pointer(property)),
            convert(Cstring, pointer(cval)), sizeof(cval)-1 )
  unsafe_string(pointer(cval))
end


function create_converter(gs::Ptr{GlobalSettings})
  ccall((:wkhtmltopdf_create_converter, libwkhtml),
        Ptr{Converter},
        (Ptr{GlobalSettings},),
        gs )
end

function destroy_converter(conv::Ptr{Converter})
  ccall((:wkhtmltopdf_destroy_converter, libwkhtml),
        Void,
        (Ptr{Converter},),
        conv )
end


function wkconvert(conv::Ptr{Converter})
  ccall((:wkhtmltopdf_convert, libwkhtml),
        Int, (Ptr{Converter},), conv )
end

function add_object(conv::Ptr{Converter}, os::Ptr{ObjectSettings},
                    data::Union{String, Ptr{Void}})
  ccall((:wkhtmltopdf_add_object, libwkhtml),
        Void,
        (Ptr{Converter}, Ptr{ObjectSettings}, Cstring),
        conv, os,
        isa(data, String) ? convert(Cstring, pointer(data)) : data)
end
