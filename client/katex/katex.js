// import katex from './katex.min.js'
import katex from 'D:/frtestar/.julia/v0.5/Rotolo/client/katex/katex.min.js'
require("https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.7.1/katex.min.css")

export default {

  props: ['params', 'nid'],

  render: function(createElement) {
    var html = katex.renderToString(this.params.expr,
                                    this.params.options);
    return createElement('span', { domProps: { innerHTML: html } })
  }

}
