
require 'rubygems'
require 'sinatra'
require 'json'
require 'openwfe/expool/parser'


get "/" do

    prepare

    pdefs = Dir.new("public").inject("") do |r, p|

        r << "<li><a href='?pdef=#{p}'>#{p}</a></li>\n" \
            if p.match(/\.xml$|.rb$/)
        r
    end

    %{
<html>
<head>
    <title>fluo bench</title>

    <meta http-equiv="content-type" content="text/html; charset=UTF-8">

    <script src="/js/prototype.js?nocache=#{Time.now.to_f}"></script>
    <script src="/js/fluo-canvas.js?nocache=#{Time.now.to_f}"></script>
    <script src="/js/fluo.js?nocache=#{Time.now.to_f}"></script>

    <link href="/css/fluo.css?nocache=#{Time.now.to_f}" rel="Stylesheet" type="text/css" />
</head>
<body onresize="Fluo.tagExpressionsWithWorkitems('fluo', [ '#{@wi}' ]);">
<div>
<div style="float:left; width: 49%">
    <pre style="font-size: 10px;">
#{@pdef}
    </pre>

    <div>
        <ul>
#{pdefs}
        </ul>
    </div>
</div>

<div style="float:left; width: 49%">

    <div id="fluo" style="width: 100%">
    </div>
    <script>
        Fluo.renderExpression('fluo', null, #{@prep});
        Fluo.tagExpressionsWithWorkitems('fluo', [ '#{@wi}' ]);
    </script>

    <br/>
    <br/>
    <div class="fluo_text">
        <a href="#" onclick="Fluo.toggleMinorExpressions('fluo'); return false;">show / hide minor expressions</a> |
        <a href="fluo?pdef=#{request['pdef']}">graph only</a>
    </div>
</div>
</div>


</body>
</html>
    }
end

get "/fluo" do

    prepare

    %{
<html>
<head>
    <title>fluo bench</title>

    <meta http-equiv="content-type" content="text/html; charset=UTF-8">

    <script src="/js/prototype.js?nocache=#{Time.now.to_f}"></script>
    <script src="/js/fluo-canvas.js?nocache=#{Time.now.to_f}"></script>
    <script src="/js/fluo.js?nocache=#{Time.now.to_f}"></script>

    <link href="/css/fluo.css?nocache=#{Time.now.to_f}" rel="Stylesheet" type="text/css" />
</head>
<body onresize="Fluo.tagExpressionsWithWorkitems('fluo', [ '#{@wi}' ]);">
<div id="fluo" style="width: 50%">
</div>
<script>
    Fluo.renderExpression('fluo', null, #{@prep});
    Fluo.tagExpressionsWithWorkitems('fluo', [ '#{@wi}' ]);
</script>

<br/>
<br/>
<div class="fluo_text">
    <a href="#" onclick="Fluo.toggleMinorExpressions('fluo'); return false;">show / hide minor expressions</a>
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
