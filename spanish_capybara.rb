require 'capybara'
require 'pry'

#Capybara.configure do |config|
  #config.match = :one
  #config.exact_options = true
  #config.ignore_hidden_elements = true
  #config.visible_text_only = true
#end

session = Capybara::Session.new(:selenium)
session.visit "https://sede.administracionespublicas.gob.es/icpplustieb/citar"

if session.has_content?("AUTORIZACIONES DE REGRESO")
  puts "AUTORIZACIONES DE REGRESO found, captain!"
  session.select("AUTORIZACIONES DE REGRESO")
  session.click_on("Aceptar")
  session.click_on("ENTRAR")
  session.find(:xpath, '//input[@id="rdbTipoDoc" and @value="PASAPORTE"]').click
  session.fill_in('txtNieAux', :with => '659050091')
  session.fill_in('txtDesCitado', :with => 'IVAN IVANOV')
  session.fill_in('txtAnnoCitado', :with => '1987')
  session.fill_in('txtFecha', :with => '01/01/2015')
  binding.pry
  # session.save_and_open_page 
else
  puts ":( no tagline fonud, possibly something's broken"
  exit(-1)
end