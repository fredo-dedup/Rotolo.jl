using Rotolo

using Base.Markdown

@redirect Base.Markdown.MD

@session d1

md"test *Markdown* string"

@container bloc1 style => "font-size: small;"

md"bloc1 *Markdown* string"

@container bloc2 style => "background-color: antiquewhite;"

md"bloc2 *Markdown* string"

sleep(3)

@container bloc3 style => "background-color: lightpink;"

md"""
## title2
"""
