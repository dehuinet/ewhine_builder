require 'rest_client'
require 'json'
host=ARGV[0]
password=ARGV[1]
client_id=ARGV[2]
mandatory_upgrade=ARGV[3]
description=ARGV[4]
file_path=ARGV[5]

if host.nil? then
	puts "need provide host"
	return
end




response = RestClient.post("#{host}/oauth2/token", :grant_type => "password", :login_name => "admin", :password => password, :app_id => 2, :app_secret => "67bc64352a9c041e75d9635ccafee3b0")
body = response.body
json = JSON.parse body

access_token =  json["access_token"]


response = RestClient.post("#{host}/admin/apps/#{client_id}/oauth2_client_versions",{"oauth2_client_version[mandatory_upgrade]"=>mandatory_upgrade,"oauth2_client_version[client_id]"=>client_id,"oauth2_client_version[description]"=>description, :client_version_file  => File.new(file_path, 'rb')
},:AUTHORIZATION=>"bearer #{access_token}")




