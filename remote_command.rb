
command=ARGV.first
param=ARGV.last
if command.nil? then
	puts "need provide command"
	return
end

system "#{command} -o \"StrictHostKeyChecking no\" -i build_server_rsa  song@build.dehuinet.com #{param}"


