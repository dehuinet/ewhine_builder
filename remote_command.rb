
command=ARGV.first
param=ARGV.last
if command.nil? then
	puts "need provide command"
	return
end

home_path=File.expand_path('../', __FILE__)

system "#{command} -o \"StrictHostKeyChecking no\" -i #{home_path}/build_server_rsa  song@build.dehuinet.com #{param}"


