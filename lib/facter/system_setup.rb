# This script takes the "parameters" output from cobbler and converts it into facts
require 'net/http'
require 'yaml'

this_host = Facter.value(:fqdn)

server = Net::HTTP.new('red-man.unl.edu',80)
response = server.request(Net::HTTP::Get.new("/cblr/svc/op/puppet/hostname/#{this_host}"))
data_hash = YAML::load(response.body)

# create the "puppet_classes" fact
Facter.add('puppet_classes') do
	setcode do
		data_hash['classes']
	end
end

# setup the parameters
data_hash['parameters'].each do |key,value|
	Facter.add(key.lstrip()) do
		setcode do
			value
		end		
	end
end
