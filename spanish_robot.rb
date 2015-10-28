require 'rubygems'
require 'mechanize'

agent = Mechanize.new
page = agent.get('https://sede.administracionespublicas.gob.es/icpplustieb/citar')

page.links.each do |link|
	puts link.text
end