require 'rubygems' 
require 'bundler/setup'  # require your gems as usual require 'nokogiri'
require 'lagunitas'
require 'erb'
require 'ostruct'
require 'SecureRandom'
if ARGV.any? then
config_file=	ARGV.first
ipa_file=ARGV.last
end

home_path=File.expand_path('../', __FILE__)
config_file_content = IO.read(config_file)
if(/BASE_URL(\s+)@"(.+)"/=~config_file_content)
	base_url=$2
	base_url.strip!
end
ipa = Lagunitas::IPA.new(ipa_file)
app = ipa.app 
version_code=app.version
version_name=app.short_version
package_name=app.identifier
display_name=app.display_name
ipa.cleanup

#ios生产plist文件
hashed_url=Digest::MD5.hexdigest(base_url)
plist_file = File.open("#{home_path}/plists/#{package_name}_#{hashed_url}.plist", "w+")
plist_tmp= File.read("#{home_path}/templates/plist.erb")
data = Hash.new
data[:version_code]=version_code
data[:version_name]=version_name
data[:name]=display_name
data[:url]="#{base_url}/apps_file/iOS.ipa"
data[:icon_url]="#{base_url}/apple-touch-icon-144.png"
plist_file << ERB.new(plist_tmp).result(OpenStruct.new(data).instance_eval { binding })
plist_file.close
# puts ipa.inspect
system "scp  -o \"StrictHostKeyChecking no\" -i ~/.ssh/id_dsa #{plist_file.path}  publisher@minxing365.com:~/plists"

#create beta

plist_file_beta = File.open("#{home_path}/plists/#{package_name}_#{hashed_url}_beta.plist", "w+")
plist_tmp= File.read("#{home_path}/templates/plist.erb")
data[:url]="#{base_url}/apps_file/iOS_beta.ipa"
plist_file_beta << ERB.new(plist_tmp).result(OpenStruct.new(data).instance_eval { binding })
plist_file_beta.close
# puts ipa.inspect
system "scp  -o \"StrictHostKeyChecking no\" -i ~/.ssh/id_dsa #{plist_file_beta.path}  publisher@minxing365.com:~/plists"





