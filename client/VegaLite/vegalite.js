
requirejs.config({
    paths: {
      d3: "https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.16/d3.min.js?noext",
      vg: "https://cdnjs.cloudflare.com/ajax/libs/vega/2.5.1/vega.min.js?noext",
      vl: "https://vega.github.io/vega-lite/vega-lite.js?noext",
      vg_embed: "https://vega.github.io/vega-editor/vendor/vega-embed.js?noext"
    },
    shim: {
      vg_embed: {deps: ["vg.global", "vl.global"]},
      vl: {deps: ["vg"]},
      vg: {deps: ["d3"]}
    }
});

define('vg.global', ['vg'], function(vgGlobal) {
    window.vg = vgGlobal;
});

define('vl.global', ['vl'], function(vlGlobal) {
    window.vl = vlGlobal;
});


define(['vg_embed'], function(vg_embed) {
  name: 'vegalite',
  template: '"<div>hello vegalite</div>',
  props: ['params', 'nid']

  render: function(createElement) {
    var embedSpec = {
      mode: "vega-lite",
      renderer: "$(SVG ? "svg" : "canvas")",
      actions: $SAVE_BUTTONS,
      spec: vlSpec
    };

    vg_embed("#$divid", embedSpec, function(error, result) {});
    return createElement('div', )
  }

} )
