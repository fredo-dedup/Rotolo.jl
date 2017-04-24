define(["./katex.min.js"],
  function(katex) {

    var link = document.createElement("link");
    link.type = "text/css";
    link.rel = "stylesheet";
    link.href = "https://cdnjs.cloudflare.com/ajax/libs/KaTeX/0.7.1/katex.min.css";
    document.getElementsByTagName("head")[0].appendChild(link);

    return {

      props: ['params', 'nid', 'deco'],

      render: function(createElement) {
        var html = katex.renderToString(this.params.expr,
                                        this.params.options);
        console.log('rendering katex');
        return createElement('span', { domProps: { innerHTML: html } })
    }
  }
})
