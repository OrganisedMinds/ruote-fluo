
require 'rubygems'

require 'rake'
require 'rake/clean'
#require 'rake/packagetask'
#require 'rake/gempackagetask'
#require 'rake/rdoctask'
require 'rake/testtask'

#require 'lib/rufus/verbs/version' # Rufus::Verbs::VERSION


#
# tasks

#CLEAN.include("logs/*")

#task :default => [ :clean, :test ]
#task :default => [ :test ]


#
# MINIFYING

require 'rubygems'
require 'jsmin' # sudo gem install jsmin

JSs = [ "fluo-canvas.js", "fluo.js" ]
PJSs = JSs.collect { |e| "public/js/#{e}" }

RUOTE_WEB = "../ruote-web"


#
# task minify
#
task :minify do

    target = File.open "fluo-min.js", "w"

    PJSs.each do |f|
        File.open f, "r" do |sourcefile|
            target.puts(JSMin.minify(sourcefile))
        end
    end
end

#
# task deploy
#
task :deploy => [ :minify ] do

    sh <<-EOS
mv fluo-min.js #{RUOTE_WEB}/public/javascripts/
cp public/css/fluo.css #{RUOTE_WEB}/public/stylesheets/
    EOS
end
