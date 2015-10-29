require 'capybara'
require 'pry'

#Capybara.configure do |config|
  #config.match = :one
  #config.exact_options = true
  #config.ignore_hidden_elements = true
  #config.visible_text_only = true
#end

puts Capybara.default_max_wait_time
Capybara.default_max_wait_time = 5

s = Capybara::Session.new(:selenium)
s.visit "https://sede.administracionespublicas.gob.es/icpplus/index.html"

tag_content = "PROVINCIAS DISPONIBLES"
if s.has_content?(tag_content)
  puts "#{tag_content} found, captain!"
  s.select("Barcelona")
  s.click_on("Aceptar")
  s.click_on("Autorización de Regreso.")
  s.select "AUTORIZACIONES DE REGRESO", from: 't'
  s.click_on("Aceptar")
  s.click_on("ENTRAR")
  s.find(:xpath, '//input[@id="rdbTipoDoc" and @value="PASAPORTE"]').click
  s.fill_in('txtNieAux', :with => '659050091')
  s.fill_in('txtDesCitado', :with => 'IVAN IVANOV')
  s.fill_in('txtAnnoCitado', :with => '1987')
  s.fill_in('txtFecha', :with => '01/01/2015')
  binding.pry
  # session.save_and_open_page 
else
  puts ":( no tagline fonud, possibly something's broken"
  exit(-1)
end