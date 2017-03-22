using BinDeps
using Compat

@BinDeps.setup

libwkhtml = library_dependency("libwkhtml", aliases=["wkhtmltox.dll"])

# provides(AptGet, "libnlopt0", libnlopt)
# provides(Sources,URI("http://ab-initio.mit.edu/nlopt/nlopt-2.4.tar.gz"), libnlopt)

# provides(BuildProcess,Autotools(configure_options =
#     ["--enable-shared", "--without-guile", "--without-python",
#     "--without-octave", "--without-matlab","--with-cxx"],
#     libtarget="libnlopt_cxx.la"),libnlopt, os = :Unix)

# if is_apple()
#     using Homebrew
#     provides( Homebrew.HB, "homebrew/science/nlopt", libnlopt, os = :Darwin )
# end

wktmlhname = "wkhtmltox"

libdir = BinDeps.libdir(libwkhtml)
srcdir = BinDeps.srcdir(libwkhtml)
downloadsdir = BinDeps.downloadsdir(libwkhtml)
extractdir(w) = joinpath(srcdir,"w$w")
destw(w) = joinpath(libdir,"wkhtmltox.dll")

type FileCopyRule <: BinDeps.BuildStep
    src::AbstractString
    dest::AbstractString
end
Base.run(fc::FileCopyRule) = isfile(fc.dest) || cp(fc.src, fc.dest)

provides(BuildProcess,
	(@build_steps begin
		# FileDownloader("https://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_msvc2015-win64.exe",
    #                joinpath(downloadsdir, "$(wktmlhname)-win64.zip"))
		FileDownloader("https://downloads.wkhtmltopdf.org/0.12/0.12.4/wkhtmltox-0.12.4_mingw-w64-cross-win64.exe",
                   joinpath(downloadsdir, "$(wktmlhname)-win64.zip"))
		CreateDirectory(srcdir, true)
		CreateDirectory(joinpath(srcdir,"w64"), true)
		FileUnpacker(joinpath(downloadsdir,"$(wktmlhname)-win64.zip"), extractdir(64), joinpath("bin","wkhtmltox.dll"))
		CreateDirectory(libdir, true)
    FileCopyRule(joinpath(extractdir(64),"bin/wkhtmltox.dll"), destw(64))
	end), libwkhtml, os = :Windows)

if is_windows()
    push!(BinDeps.defaults, BuildProcess)
end

@BinDeps.install Dict(:libwkhtml => :libwkhtml)
