
require 'rubygems'
require 'sinatra'
require 'json' # gem 'json_pure'
require 'openwfe/expool/parser' # gem 'ruote'


get "/" do

  pdef = request['pdef'] || 'pdef.rb'

  i = pdef.rindex('/')
  pdef = pdef[i + 1..-1] if i

  pdef = File.open("public/#{pdef}").readlines.join

  prep = OpenWFE::DefParser.parse(pdef)
  prep = prep.to_a.to_json

  wi = request['wi']

  %{
<html>
<head>
  <title>fluo bench</title>

  <meta http-equiv="content-type" content="text/html; charset=UTF-8">

  <script src="/js/fluo-can.js?nocache=#{Time.now.to_f}"></script>
  <script src="/js/fluo-dial.js?nocache=#{Time.now.to_f}"></script>
  <script src="/js/fluo-tred.js?nocache=#{Time.now.to_f}"></script>
  <script src="/js/fluo-json.js?nocache=#{Time.now.to_f}"></script>

  <link href="/css/fluo-bench.css?nocache=#{Time.now.to_f}" rel="Stylesheet" type="text/css" />
  <link href="/css/fluo-dial.css?nocache=#{Time.now.to_f}" rel="Stylesheet" type="text/css" />
  <link href="/css/fluo-tred.css?nocache=#{Time.now.to_f}" rel="Stylesheet" type="text/css" />

  <script>
    // a debugging function...
    function dlog (text) {
      if ( ! text) text = '';
      document.body.appendChild(document.createElement('br'));
      document.body.appendChild(document.createTextNode(' -  ' + text));
    }
  </script>

</head>

<body>

  <script>
    function undo () {
      FluoTred.undo('tred');
      return false;
    }
    function asXml () {
      document.getElementById('definition_out_type').value = 'xml';
      document.getElementById('definition_input').value = FluoTred.asJson('tred');
      document.getElementById('definition_form').submit();
      return false;
    }
    function asRuby () {
      document.getElementById('definition_out_type').value = 'ruby';
      document.getElementById('definition_input').value = FluoTred.asJson('tred');
      document.getElementById('definition_form').submit();
      return false;
    }
    function toggleMinor () {
      FluoCan.toggleMinor('fluo');
      FluoCan.crop('fluo');
      return false;
    }
    function rotate () {
      FluoCan.toggleVertical('fluo');
      FluoCan.crop('fluo');
      return false;
    }
  </script>

  <div class="menubar">
    <div class="menubar_links" style="float: left;">
      <a class="menubar_link" href="/defs">defs</a>
      <a class="menubar_link" href="#" onclick="return undo();">undo</a>
      <a class="menubar_link" href="#" onclick="return asXml();">as xml</a>
      <a class="menubar_link" href="#" onclick="return asRuby();">as ruby</a>
    </div>
    <div class="menubar_links" style="float: right;">
      <a class="menubar_link" href="#" onclick="return toggleMinor();">show/hide minor</a>
      <a class="menubar_link" href="#" onclick="return rotate();">rotate</a>
    </div>
  </div>

<div>

  <div style="float:left; width: 53%">

    <div id="tred" style="margin-left: 10px; margin-top: 10px;"></div>

    <script>
      FluoTred.renderFlow(document.getElementById("tred"), #{prep});
      //var tout = document.getElementById("tred__out");
      FluoTred.onChange = function (tree) {
        FluoCan.renderFlow('fluo', tree);
        FluoCan.crop('fluo');
      };
      FluoTred.onOver = function (expid) {
        FluoCan.highlight('fluo', expid);
      };
    </script>
  </div>

  <div id="leftpane" style="float:left; width: 45%">

    <canvas id="fluo" width="200" height="200"></canvas>

    <script>
      FluoCan.renderFlow('fluo', #{prep}, [ '#{wi}' ]);
      FluoCan.crop('fluo');
      //FluoCan.highlight('fluo', '0.0.1');
    </script>
  </div>

</div>

<form id="definition_form" action="/def" method="POST">
  <input id="definition_out_type" type="hidden" name="out_type" value="xml"></input>
  <input id="definition_input" type="hidden" name="definition"></input>
</form>


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
  <title>fluo bench / definitions</title>
  <link href="/css/fluo-bench.css?nocache=#{Time.now.to_f}" rel="Stylesheet" type="text/css" />
</head>
<body>

  <div class="menubar">
    <div class="menubar_links">
      <a class="menubar_link" href="/defs">defs</a>
      <a class="menubar_link" href="#" onclick="FluoTred.undo('tred'); return false;">undo</a>
    </div>
  </div>

  <h3>the definitions under public/</h3>
  <div id="all_definitions">
    <ul>
#{pdefs}
    </ul>
  </div>
</body>
</html>
  }
end


post "/def" do

  json = params[:definition]
  tree = JSON.parse json

  header 'Content-Type' => "text/plain"

  case params[:out_type]
    when 'xml'
      s = ""
      REXML::Formatters::Pretty.new.write(
        OpenWFE::ExpressionTree.to_xml(tree), s)
      s
    when 'ruby'
      OpenWFE::ExpressionTree.to_code_s(tree).to_s
    else
      json
  end
end

