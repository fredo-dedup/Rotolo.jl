// import katex from './katex.min.js'
// import katex from 'D:/frtestar/.julia/v0.5/Rotolo/client/katex/katex.min.js'
// require("https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.7.1/katex.min.css")
// import katex from './katex.min.js'
// require('css-loader!./katex.min.css')
//
// export default {
//
//   props: ['params', 'nid'],
//
//   render: function(createElement) {
//     var html = katex.renderToString(this.params.expr,
//                                     this.params.options);
//     return createElement('span', { domProps: { innerHTML: html } })
//   }
//
// }

require.config({
    paths: {
        "katex": "D:/frtestar/.julia/v0.5/Rotolo/client/katex/katex.min"
    }
});

define(["katex"], function(katex) {

  return {

    template: '<div>katex temaplte</div>'

    props: ['params', 'nid'],

    // render: function(createElement) {
    //   var html = katex.renderToString(this.params.expr,
    //                                   this.params.options);
    //   console.log('rendering katex');
    //   return createElement('span', { domProps: { innerHTML: html } })
    // }
  }
})


// define( {
//     props: ['params', 'nid'],
//
//     render: function(createElement) {
//       var html = katex.renderToString(this.params.expr,
//                                       this.params.options);
//       return createElement('span', { domProps: { innerHTML: html } })
//     }
//   })
