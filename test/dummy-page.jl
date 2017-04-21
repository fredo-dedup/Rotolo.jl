using Rotolo

@session test style=>"color:red"
@redirect String
"red"

@container red class=>"redbox" style=>"color:red"
"red"
@container red id=>"test" class=>"bluebox" style=>"color:blue"
"red"

@container blue style=>"color:green"
"green"
@container blue.red style=>"color:yellow"
"yellow"
@container blue.green style=>"color:blue"
"blue"

@container red3 class=>"red2" style=>"color:red"
"red"


theme = "font-size:large;" ;

@container red.large style => theme
"bigger"

@style "bigger" style => "font-size:x-large;font-style:italic"

@style 456.45 style=>"font-size:x-small"

@style "test" style=>"font-style:italic" class=>"test" id=>"youpi"
