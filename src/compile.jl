############################################################################
#   Compilation function : compile()
############################################################################

function compile(sourcepath::String,
                 destpath::String)
  open(sourcepath, "r") do sio
    # open(destpath, "w") do dio
    # compile(sio, dio)
    compile(sio, destpath)
    # end
  end
end

# function compile(sio::IO, dio::IO)
function compile(sio::IO, destpath::String)
  emod = Module(gensym())

  Rotolo.headless(true)
  println("isHeadless ", Rotolo.isHeadless)

  hit_eof = false
  counter = 0
  outputbuf = UInt8[]
  htmlfile = ""
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
      sl = chomp("$line")
      sl = length(sl)>200 ? sl[1:200]*"..." : sl
      println("line #$counter : $sl")
      ret = try
              eval(emod, ast)
            catch err
              println("\nerror encountered in line #$counter : $line")
              rethrow()
            end
      if ret != nothing
        println("value : $ret")
        if isa(ret, Session)  # session has just been defined
          println("filename = ", ret.filename)
          headlessclient(ret.filename, destpath, format="pdf")
        elseif isredirected(typeof(ret))
          println("showing ret ($(typeof(ret)))")
          Rotolo.showmsg(ret)
        end
      end
    end
    (isempty(line) || hit_eof) && break
  end

  # send completion message so that PhantomJS renders and exits
  send(Rotolo.currentSession, 0, "completed")

  # open(htmlfile, "r") do oio
  #   outputbuf = PhantomJS.renderhtml(oio, format="pdf")
  #   write(dio, outputbuf)
  # end

  Rotolo.headless(false)
end


function headlessclient(srcpath::String,
                        destpath::String;
                        format::String="png",
                        width::Int=1024,
                        height::Int=800,
                        clipToSelector::String="",
                        quality::Int=75,
                        paperSize::String="A4",
                        orientation::String="portrait",
                        margin::Union{String, Int}=0,
                        background::String="white")

  bgjs = background == "transparent" ? "" :
           """page.evaluate(function() {
                document.body.bgColor = '$background';
              });
           """

  clipjs = clipToSelector == "" ? "" :
             """
              var clipRect = page.evaluate(function(){
                  return document.querySelector('$clipToSelector').getBoundingClientRect();
                });

              page.clipRect = {
                top:    clipRect.top,
                left:   clipRect.left,
                width:  clipRect.width,
                height: clipRect.height
              };
             """

  jsscript = """
    "use strict";
    var page = require('webpage').create(),
        system = require('system'),
        address, output, size, pageWidth, pageHeight;

    address = '$(htmlpath(srcpath))';
    output = '$destpath';

    page.onConsoleMessage = function(msg, lineNum, sourceId) {
      console.log('CONSOLE: ' + msg);
      if(msg === 'event-0 : command completed') {
        window.setTimeout(function () {
            $bgjs
            $clipjs
            page.render(output,
                        {format: '$format',
                         quality: '$quality'});
            phantom.exit();
        }, 10000);
      }
    };

    page.onError = function(msg, trace) {
      console.log('ERROR : ' + msg);
    };

    page.viewportSize = { width: $width, height: $height };

    page.paperSize = { format: '$paperSize',
                       orientation: '$orientation',
                       margin: '$margin' };

    page.open(address, function (status) {
        if (status !== 'success') {
            console.log('Unable to load the address : ' + address);
            phantom.exit(1);
        } else {

        }
    });
  """
  println(jsscript)
  @async PhantomJS.execjs(jsscript)

  nothing
end
