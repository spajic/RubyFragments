require 'capybara'
require 'capybara/poltergeist'
#require 'pry'

def mytime
  (Time.now + 11*3600).strftime("%H:%M:%S")
end

class CaptchaSolverByHand  
  attr_reader :result
  
  def initialize
    @result = ""
  end

  def solve
    # todo: 
    # сохранить капчу в файл и открыть
    print "Enter CAPTHCA value, please: "
    @result = gets.chomp!
    puts "You entered #{@result}, thank you"
    @result
  end
end

class Appointment
  attr_reader :name, :pasport, :country, :phone, :mail
  def initialize(name, pasport, country, phone, mail)
    @name = name
    @pasport = pasport
    @country = country
    @phone = phone
    @mail = mail
  end
end

class Scenario
  attr_reader :name, :session, :engine, :appointment, :captcha_solver, :steps
  def initialize(name, session, engine, appointment, captcha_solver, steps)
    @name = name
    @session = session
    @engine = engine
    @appointment = appointment
    @captcha_solver = captcha_solver
    @steps = steps
  end
  def step
    puts "STARTING SCENARIO #{name}"
    @steps.each do |step|
      step.scenario = self
      step.on_start
      step.step 
      step.on_finish
    end
    puts "FINISHED SCENARIO #{name}"
  end
end

class Step
  attr_reader :name, :session
  attr_writer :scenario
    
  def initialize(name)
    @FolderToSave = "CapybaraStash-#{mytime}"
    @name = name
  end

  def s()
    @scenario.session
  end
  def appointment()
    @scenario.appointment
  end
  def captcha_solver()
    @scenario.captcha_solver
  end
  def engine()
    @scenario.engine
  end

  def save_page()
    path = "#{@FolderToSave}/#{mytime}-#{name}.html"
    s.save_page(path)
    puts "Saved html to #{path}"
  end

  def save_and_open_page()
    path = "#{@FolderToSave}/#{mytime}-#{name}.html"
    s.save_and_open_page(path)
    puts "Saved html to #{path}"
  end
  def save_screenshot()
    s.save_screenshot
    puts "Saved png to root folder"
  end
  def save_and_open_screenshot()
    s.save_and_open_screenshot
    puts "Saved png to root folder and open it"
  end

  def step()
    puts "Define step method"
  end

  def on_start()
    puts "START STEP #{name}"
  end

  def on_finish()
    puts "SUCCESS STEP #{name}"
  end

  def fail_and_exit(message)
    puts "Step #{name} failed with message - #{message}"
    puts "exit now"
    exit(1)
  end

end

class Step0 < Step
  def step
  	s.visit "https://sede.administracionespublicas.gob.es/icpplus/index.html"
    tag_content = "PROVINCIAS DISPONIBLES"
    fail_and_exit("Unable to find tag_content #{tag_content}") unless s.has_content?(tag_content)
  end
end

class StepsBeforePassportBarcelonaRegresso < Step
  def step
      s.select("Barcelona")
      s.click_on("Autorización de Regreso.")
      s.click_on("Autorización de Regreso.") if engine == "selenium"
      s.select "AUTORIZACIONES DE REGRESO"#, :from => "t"
      s.click_on("Aceptar")
      s.click_on("ENTRAR")
  end
end

class StepsBeforePassportBarcelonaExtranjero < Step
  def step
      s.select("Barcelona")
      s.click_on("Expedición de Tarjeta de Identidad de Extranjero.")
      s.click_on("Expedición de Tarjeta de Identidad de Extranjero.") if engine == "selenium"
      s.select "TOMA DE HUELLAS (EXPEDICIÓN DE TARJETA) Y RENOVACIÓN DE TARJETA DE LARGA DURACIÓN"#, :from => "t"
      s.click_on("Aceptar")
      s.click_on("ENTRAR")
  end
end

class StepsBeforePassportMadridRegresso < Step
  def step
      s.select("Madrid")
      s.click_on("Aceptar")
      s.click_on("Aceptar")
      s.select "AUTORIZACIONES DE REGRESO"
      s.click_on("Aceptar")
      s.click_on("ENTRAR")  
  end
end

class StepsBeforePassportMadridExtranjero < Step
  def step
      s.select("Madrid")
      s.click_on("Aceptar")
      s.click_on("Aceptar")
      s.select "TOMA DE HUELLAS (EXPEDICIÓN DE TARJETA) Y RENOVACIÓN DE TARJETA DE LARGA DURACIÓN"
      save_page
      s.click_on("Aceptar")
      s.click_on("ENTRAR")  
  end
end

=begin
class FillPassportRegresso < Step
  def step (session, captcha_solver)
  	s.find(:xpath, '//input[@id="rdbTipoDoc" and @value="PASAPORTE"]').click
    s.fill_in('txtNieAux', :with => '4508906727')
    s.fill_in('txtDesCitado', :with => 'IVAN IVANOV')
    s.fill_in('txtAnnoCitado', :with => '1987')
    s.fill_in('txtFecha', :with => '01/01/2015')
    s.fill_in('txtCaptcha', :with => captcha_solver.solve)
    s.click_on("Aceptar")
  end
end
=end

class FillPassportExtranjero < Step
  def step
    s.find(:xpath, '//input[@id="rdbTipoDoc" and @value="PASAPORTE"]').click
    s.fill_in('txtNieAux', :with => appointment.pasport)
    s.fill_in('txtDesCitado', :with => appointment.name)
    s.select appointment.country
    save_and_open_screenshot
    s.fill_in('txtCaptcha', :with => captcha_solver.solve)
    s.click_on("Aceptar")
  end
end

class Step1SolicitarCita < Step
  def step
    s.click_on("SOLICITAR CITA")  
    tries = 1
    save_screenshot
    save_page
    
    sorry_message = 'En este momento no hay citas disponibles.'
  	#while s.has_selector?(:xpath, '//input[@value="Siguiente" and @type="button"]', visible: true)
    while Capybara.using_wait_time(3) {s.has_content?(sorry_message)}
      sleep_time = rand 10
      puts "#{mytime}, try #{tries} - #{sorry_message} Sleep for #{sleep_time}s and try again!"
      tries += 1
      sleep sleep_time
      s.click_on("Volver")
      s.click_on("SOLICITAR CITA")  
  	end
  	puts "HOORAY!!! Step 1 successfull"
    save_and_open_screenshot
    save_page
    s.click_on("Siguiente")
  end
end

class Step2EnterPhoneAndMail < Step
  def step
    s.fill_in('txtTelefonoCitado', :with => appointment.phone)
    s.fill_in('emailUNO', :with => appointment.mail)
    s.fill_in('emailDOS', :with => appointment.mail)
    s.click_on("Siguiente")
  end
end

class Step3ChooseCita < Step
  def step
    s.find(:xpath, '//input[@type="radio" and @title="Seleccionar CITA 1"]').click
    save_and_open_screenshot
    s.click_on("Siguiente")
  end
end

class Step4Confirm < Step
  def step
    s.check('chkTotal')
    s.check('enviarCorreo')
    save_and_open_screenshot
    s.click_on('Confirmar')
  end
end

class Step4WaitUserToConfirm < Step
  def step
    s.check('chkTotal')
    s.check('enviarCorreo')
    save_and_open_screenshot
    save_page
    puts "Robot is waiting. Press enter to confirm, SEND EMAIL THAT NEEDS TO BE ANNULATED, and continue."
    w = gets
  end
end

class Step5Final < Step
  def step
    save_and_open_screenshot
    save_and_page
    puts "Robot is waiting"
    w = gets
  end
end


  # Итоговая страничка с нашим номером, который нам должен быть отправлен на email
  # Nº de Justificante de cita: AB7AF66H
  # <td class="tituloTabla" style="font-size:18px">
  # Nº de Justificante de cita:
  # <span id="justificanteFinal" class="justificanteBold"> AB7AF66H </span>
  # </td>
  #binding.pry
  # session.save_and_open_page 
  
require 'optparse'
args = {scenario: 'BarcelonaExtranjero', engine: 'capybara'}

OptionParser.new do |opts|
  opts.banner = "Порядок вызова капибары: spanish_capybara.rb [options]"

  opts.on("-s", "-scenario", "Название сценария для исполнения") do |scenario|
    args[:scenario] = scenario
  end

  opts.on("-e", "-engine", "selenium или poltergeist") do |engine|
    args[:engine] = engine
  end

  opts.on_tail("-h", "-help", "Показать эту справку") do
    puts opts
    exit
  end
end.parse!


spajic = Appointment.new("ALEX V", "4508", "RUSIA", "9164363288", "bestspajic@gmail.com")
#first_client = Appointment.new("VICTORIA MAILYAN", "718965188", "RUSIA", "633441119", "katia@spain-immigration.es")
first_client = Appointment.new("VICTORIA MAILYAN", "718965188", "RUSIA", "633441119", "bestspajic@gmail.com")

#Capybara.configure do |config|
  #config.match = :one
  #config.exact_options = true
  #config.ignore_hidden_elements = true
  #config.visible_text_only = true
#end

Capybara.default_max_wait_time = 20
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, 
    {debug: false, js_errors: false, timeout: 20000, 
      phantomjs_options: ['--debug=no', '--load-images=yes', '--ignore-ssl-errors=yes', '--ssl-protocol=TLSv1']})
end

drivers = {"selenium" => :selenium, "poltergeist" => :poltergeist}
unless (drivers.keys.include? args[:engine])
  puts "Specified engine not supported. Exit now"
  exit(1)
end

session = Capybara::Session.new(drivers[args[:engine]])
appointment = first_client
captcha_solver = CaptchaSolverByHand.new

steps_barcelona_extranjero = [
  Step0.new("0 - visit site"),
  StepsBeforePassportBarcelonaExtranjero.new("Before passport Barcelona Extranjero"),
  FillPassportExtranjero.new("Fill Passport Extranjero"),
  Step1SolicitarCita.new("Multiple Tries to Solicitar Cita"), 
  Step2EnterPhoneAndMail.new("Enter phone and email"),
  Step3ChooseCita.new("Choose Cita"),
  Step4Confirm.new("Confirm and Send Notification to email"),
  Step5Final.new("Wait on Final Page")]

steps_madrid_extranjero = [
  Step0.new("0 - visit site"),
  StepsBeforePassportMadridExtranjero.new("Before passport Madrid Extranjero"),
  FillPassportExtranjero.new("Fill Passport Extranjero"),
  Step1SolicitarCita.new("Multiple Tries to Solicitar Cita"), 
  Step2EnterPhoneAndMail.new("Enter phone and email"),
  Step3ChooseCita.new("Choose Cita"),
  Step4WaitUserToConfirm.new("Wait User to Confirm"),
  Step5Final.new("Wait on Final Page")]

steps_scenarios = {
  "BarcelonaExtranjero" => steps_barcelona_extranjero, 
  "MadridExtranjero" => steps_madrid_extranjero }
  
if !steps_scenarios[args[:scenario]]
  puts "Scenario #{args[:scenario]} not found! Exit now."
  exit(1)
end

SpanishCapybara = Scenario.new(
  "SpanishCapybara", session, args[:engine], appointment, captcha_solver, steps_scenarios[args[:scenario]])
SpanishCapybara.step