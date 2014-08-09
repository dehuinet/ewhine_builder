# -*- coding: utf-8 -*-
require 'yaml'
require 'fileutils'
require 'erb'
require 'ostruct'

root=ARGV.first
flavor_name=ARGV[1]
platform=ARGV.last
if root.nil? then
	puts "need root path"
	return
end
flavors="#{root}/flavors/#{flavor_name}"
unless File.exist?(flavors) then
	puts "flavors :#{flavor_name}: not exist"
	return
end
 FileUtils.cp_r("#{flavors}/app", "#{root}")

grunt_file="#{root}/Gruntfile.js"

grunt_file_content=IO.read(grunt_file).force_encoding("ISO-8859-1").encode("UTF-8", replace: nil)

grunt_file_content.gsub!(/(#{platform}.*):.*\n/){"#{Regexp.last_match[1]}: true,\n"}


File.open(grunt_file, 'w') { |file| file.write(grunt_file_content) }




config = YAML::load(File.read("#{flavors}/build/config.yaml"))
if "mac"==platform then
    config["app_id"]="4"
    config["app_secret"]="df5042da190e040beaffee92b7a22c7e"
end
config_file = File.open("#{root}/app/scripts/config.js","w+")
config_tmp = File.read("#{root}/config.js.erb")

config_file << ERB.new(config_tmp).result(OpenStruct.new(config).instance_eval { binding })
config_file.close


