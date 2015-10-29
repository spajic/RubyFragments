require 'rubygems'
require 'mechanize'

agent = Mechanize.new
agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
page = agent.get('https://sede.administracionespublicas.gob.es/icpplustieb/citar')

page.links.each do |link|
	puts link.text
end

puts "PRETTY PRINT PAGE"
pp page