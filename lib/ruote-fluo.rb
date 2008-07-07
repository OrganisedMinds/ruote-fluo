
require 'rubygems'
require 'sinatra'
require 'json'
require 'openwfe/expool/parser'


get "/" do

  prepare

  %{
<html>
<head>
  <title>fluo bench</title>

  <meta http-equiv="content-type" content="text/html; charset=UTF-8">

  <script src="/js/fluo-can.js?nocache=#{Time.now.to_f}"></script>
  <script src="/js/fluo-dial.js?nocache=#{Time.now.to_f}"></script>
  <script src="/js/fluo-tred.js?nocache=#{Time.now.to_f}"></script>

  <link href="/css/fluo-dial.css?nocache=#{Time.now.to_f}" rel="Stylesheet" type="text/css" />
  <link href="/css/fluo-tred.css?nocache=#{Time.now.to_f}" rel="Stylesheet" type="text/css" />

  <style>
    body {
    /*color: #888;*/
    font-family: Courier;
    font-size: 12px;
    }
  </style>
</head>

<body>

<div>
<div style="float:left; width: 49%">

  <div id="tred" style="margin-left: 10px; margin-top: 10px;">
  </div>
  <script>

    Tred.renderFlow(document.getElementById("tred"), #{@prep});

    var tout = document.getElementById("tred__out");

    Tred.onChange = function (jsonTree) {
      FluoCan.renderExpression('fluo', jsonTree);
    }
  </script>
</div>

<div id="leftpane" style="float:left; width: 49%">

  <canvas id="fluo" width="500" height="800"></canvas>
</div>
</div>

<script>
  var c = document.getElementById('fluo').getContext("2d");
  FluoCan.renderExpression(c, #{@prep});
  //Fluo.tagExpressionsWithWorkitems('fluo', [ '#{@wi}' ]);
</script>


</body>
</html>
  }
end

get "/defs" do

  pdefs = Dir.new("public").inject("") do |r, p|

    r << "<li><a href='/?pdef=#{p}'>#{p}</a></li>\n" \
      if p.match(/\.xml$|.rb$/)
    r
  end

  %{
<html>
<head>
  <title>fluo bench</title>
</head>
<body>
  <div id="all_definitions">
    <ul>
#{pdefs}
    </ul>
  </div>
</body>
</html>
  }
end

def prepare

  @pdef = request['pdef'] || 'pdef.rb'

  xml = @pdef.match /\.xml$/

  @pdef = File.open("public/#{@pdef}").readlines.join

  @prep = OpenWFE::DefParser.parse @pdef
  @prep = @prep.to_a.to_json

  @wi = request['wi']

  @pdef = @pdef.gsub("<", "&lt;") if xml
end

