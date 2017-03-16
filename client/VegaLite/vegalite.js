// import katex from './katex.min.js'
// require("https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.7.1/katex.min.css")

export default {

  props: ['params', 'nid'],

  render: function(createElement) {
    return createElement('span', { domProps: { innerHTML: "abcd" } })
  }

}
