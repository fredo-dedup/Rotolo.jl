using Rotolo
using Base.Markdown

global_theme = """
	{text-align: center;padding: 5px;}
	 @media print { .slide {break-before: always;} }
	.markdown {font-size: x-large;}
	.katex {font-size: xx-large;}
	h1 {font-size: 20mm;
	    text-align: center;
			border: black;
      border-style: solid;
			background-color: lightblue;}
	"""

Rotolo.endsession()

@session Slides
# @redirect Markdown.MD HTML Katex
@redirect Markdown.MD HTML
sleep(2)

HTML("<style>$global_theme</style>")

@container slide0 class=>"slide"
md"## Himmelblau's function"
@style md"*From Wikipedia, the free encyclopedia*" style=>"font-size:x-small"

@container slide1 class=>"slide"
md"# Introduction"

md"""
	In mathematical optimization, Himmelblau's function is a multi-modal function,
	used to test the performance of optimization algorithms. The function is defined by:
	"""

@container slide2 class=>"slide"
md"# Definition"

# Katex("f(x,y)=(x^2+y-11)^2+(x+y^2-7)^2", true)
