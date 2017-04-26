using Rotolo
using Base.Markdown

global_theme = """
	text-align: center;
	padding: 5px;
	.slide {page-break-before: always;}
	.markdown {font-size: x-large;}
	h1 {font-size: 20mm;text-align: center;background-color: lightblue;}
	"""


@session Slides
@redirect Markdown.MD HTML Katex

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

md"# Himmelblau's function"

Katex("f(x,y)=(x^2+y-11)^2+(x+y^2-7)^2", true)
