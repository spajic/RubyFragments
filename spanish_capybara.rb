require 'capybara'
#require 'pry'

#Capybara.configure do |config|
  #config.match = :one
  #config.exact_options = true
  #config.ignore_hidden_elements = true
  #config.visible_text_only = true
#end

class CaptchaSolverByHand  
  attr_reader :result
  
  def initialize
    @result = ""
  end

  def solve
    print "Enter CAPTHCA value, please: "
    @result = gets
    puts "You entered #{@result.chomp}, thank you"
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
  attr_reader :name, :session, :appointment, :captcha_solver, :steps
  def initialize(name, session, appointment, captcha_solver, steps)
    @name = name
    @session = session
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
      s.click_on("Autorización de Regreso.")
      s.select "AUTORIZACIONES DE REGRESO"#, :from => "t"
      s.click_on("Aceptar")
      s.click_on("ENTRAR")
  end
end

class StepsBeforePassportBarcelonaExtranjero < Step
  def step
      s.select("Barcelona")
      s.click_on("Expedición de Tarjeta de Identidad de Extranjero.")
      s.click_on("Expedición de Tarjeta de Identidad de Extranjero.")
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
    s.fill_in('txtCaptcha', :with => captcha_solver.solve)
    s.click_on("Aceptar")
  end
end

class Step1SolicitarCita < Step
  def step
    s.click_on("SOLICITAR CITA")  
    tries = 1
  	until s.has_selector?(:xpath, '//input[@value="Siguiente" and @type="button"]')
      sleep_time = rand 1
      puts "#{Time.now}, try #{tries} - Button Siguiente not found. Sleep for #{sleep_time}s and try again!"
      tries += 1
      sleep sleep_time
      s.click_on("Volver")
      s.click_on("SOLICITAR CITA")  
  	end
  	puts "HOORAY!!! Step 1 successfull"
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
    s.click_on("Siguiente")
  end
end

class Step4Confirm < Step
  def step
    s.check('chkTotal')
    s.check('enviarCorreo')
    s.click_on('Confirmar')
  end
end

class Step5Final < Step
  def step
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
  
spajic = Appointment.new("ALEX V", "4508", "RUSIA", "9164363288", "bestspajic@gmail.com")
#first_client = Appointment.new("VICTORIA MAILYAN", "718965188", "RUSIA", "633441119", "katia@spain-immigration.es")
first_client = Appointment.new("VICTORIA MAILYAN", "718965188", "RUSIA", "633441119", "bestspajic@gmail.com")


Capybara.default_max_wait_time = 15
session = Capybara::Session.new(:selenium)
appointment = first_client
captcha_solver = CaptchaSolverByHand.new
steps = [
  Step0.new("0 - visit site"),
  StepsBeforePassportBarcelonaExtranjero.new("Before passport Madrid Extranjero"),
  #StepsBeforePassportMadridExtranjero.new("Before passport Madrid Extranjero"),
  FillPassportExtranjero.new("Fill Passport Extranjero"),
  Step1SolicitarCita.new("Multiple Tries to Solicitar Cita"), 
  Step2EnterPhoneAndMail.new("Enter phone and email"),
  Step3ChooseCita.new("Choose Cita"),
  Step4Confirm.new("Confirm and Send Notification to email"),
  Step5Final.new("Wait on Final Page")]

SpanishCapybara = Scenario.new("SpanishCapybara", session, appointment, captcha_solver, steps)
SpanishCapybara.step