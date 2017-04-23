using Rotolo
using Base.Markdown

global_theme = """
	text-align: center;
	border-style:solid;
	padding: 5px;

	@media print {
    .slide {page-break-before: always;}
  }

  """


@session Slides style=>global_theme

@redirect Markdown.MD Katex
sleep(3)

@container slide1 class=>"slide"

md"# Himmelblau's function"
@style md"*From Wikipedia, the free encyclopedia*" style=>"font-size:x-small"

@container slide2 class=>"slide"

md"# Function definition"
Katex("f(x,y)=(x^2+y-11)^2+(x+y^2-7)^2", true)

@container slide3 class=>"slide"
