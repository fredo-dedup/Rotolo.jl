import katex from './katex.min.js'

require("style-loader!raw-loader!./kateex.min.css")

//
// var fileref = document.createElement("link")
// fileref.setAttribute("rel", "stylesheet")
// fileref.setAttribute("type", "text/css")
// fileref.setAttribute("href", "./katex.min.css")
// //
// import katexcss from './katex.min.css'

// add the katex style file to head
// var css = 'h1 { background: red; }'
// var reader = new FileReader();
// var cssFile = new File(['aaaa'], 'D:/frtestar/.julia/v0.5/Rotolo/client/kateex.min.css', {type: 'text/plain'});
//
// reader.onload = function(evt) {
//   var head = document.head || document.getElementsByTagName('head')[0]
//   var style = document.createElement('style');
//
//   console.log('css file read')
//   console.log(evt.target)
//
//   style.type = 'text/css';
//   if (style.styleSheet){
//     style.styleSheet.cssText = evt.target.result;
//   } else {
//     style.appendChild(document.createTextNode(evt.target.result));
//   }
//   head.appendChild(style);
// }
//
// reader.onerror = function(evt) {
//   console.log('error reading css file')
// }
//
// reader.readAsText(cssFile)


// var css = reader.readAsText(File("./katex.min.css"))
//
// var head = document.head || document.getElementsByTagName('head')[0],
//     style = document.createElement('style');
//
// style.type = 'text/css';
// if (style.styleSheet){
//   style.styleSheet.cssText = css;
// } else {
//   style.appendChild(document.createTextNode(css));
// }
// head.appendChild(style);


export default {

  props: ['params', 'nid'],

  render: function(createElement) {
    var html = katex.renderToString(this.params.expr,
                                    this.params.options);
    return createElement('span', { domProps: { innerHTML: html } })
  }

}
