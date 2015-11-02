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

class Step0
  def step(session)
  	@s = session
    @s.visit "https://sede.administracionespublicas.gob.es/icpplus/index.html"
    tag_content = "PROVINCIAS DISPONIBLES"
    if @s.has_content?(tag_content)
      puts "Step0 successfull" 
    else
      puts "Step0 failed, exit now!"
      exit(1)
    end
  end
end

class StepsBeforePassportBarcelonaRegresso
  def step (session)
      @s = session
      @s.select("Barcelona")
      @s.click_on("Autorización de Regreso.")
      @s.click_on("Autorización de Regreso.")
      @s.select "AUTORIZACIONES DE REGRESO"#, :from => "t"
      @s.click_on("Aceptar")
      @s.click_on("ENTRAR")
  end
end

class StepsBeforePassportBarcelonaExtranjero
  def step (session)
      @s = session
      @s.select("Barcelona")
      @s.click_on("Expedición de Tarjeta de Identidad de Extranjero.")
      @s.click_on("Expedición de Tarjeta de Identidad de Extranjero.")
      @s.select "TOMA DE HUELLAS (EXPEDICIÓN DE TARJETA) Y RENOVACIÓN DE TARJETA DE LARGA DURACIÓN"#, :from => "t"
      @s.click_on("Aceptar")
      @s.click_on("ENTRAR")
  end
end

class StepsBeforePassportMadridRegresso
  def step (session)
      @s = session
      @s.select("Madrid")
      @s.click_on("Aceptar")
      @s.click_on("Aceptar")
      @s.select "AUTORIZACIONES DE REGRESO"
      @s.click_on("Aceptar")
      @s.click_on("ENTRAR")  
  end
end

class StepsBeforePassportMadridExtranjero
  def step (session)
      @s = session
      @s.select("Madrid")
      @s.click_on("Aceptar")
      @s.click_on("Aceptar")
      @s.select "TOMA DE HUELLAS (EXPEDICIÓN DE TARJETA) Y RENOVACIÓN DE TARJETA DE LARGA DURACIÓN"
      @s.click_on("Aceptar")
      @s.click_on("ENTRAR")  
  end
end

class FillPassportRegresso
  def step (session, captcha_solver)
  	@s = session
  	@s.find(:xpath, '//input[@id="rdbTipoDoc" and @value="PASAPORTE"]').click
    @s.fill_in('txtNieAux', :with => '4508906727')
    @s.fill_in('txtDesCitado', :with => 'IVAN IVANOV')
    @s.fill_in('txtAnnoCitado', :with => '1987')
    @s.fill_in('txtFecha', :with => '01/01/2015')
    @s.fill_in('txtCaptcha', :with => captcha_solver.solve)
    @s.click_on("Aceptar")
  end
end

class FillPassportExtranjero
  attr_reader :appointment
  def initialize(appointment)
    @appointment = appointment
  end
  def step (session, captcha_solver)
    @s = session
    @s.find(:xpath, '//input[@id="rdbTipoDoc" and @value="PASAPORTE"]').click
    @s.fill_in('txtNieAux', :with => appointment.pasport)
    @s.fill_in('txtDesCitado', :with => appointment.name)
    #@s.fill_in('txtAnnoCitado', :with => '1987')
    #@s.fill_in('txtFecha', :with => '01/01/2015')
    @s.select appointment.country
    @s.fill_in('txtCaptcha', :with => captcha_solver.solve)
    @s.click_on("Aceptar")
  end
end

class Step1SolicitarCita
  def step (session)
  	@s = session
    @s.click_on("SOLICITAR CITA")  

  	until @s.has_selector?(:xpath, '//input[@value="Siguiente" and @type="button"]')
      sleep_time = rand 10
      puts "#{Time.now} - Button Siguiente not found. Sleep for #{sleep_time}s and try again!"
      sleep sleep_time
      @s.click_on("Volver")
      @s.click_on("SOLICITAR CITA")  
  	end
  	puts "HOORAY!!! Step 1 successfull"
    @s.click_on("Siguiente")
  end
end

class Step2EnterPhoneAndMail
  attr_reader :appointment
  def initialize(appointment)
    @appointment = appointment
  end
  def step(session)
    @s = session
    @s.fill_in('txtTelefonoCitado', :with => appointment.phone)
    @s.fill_in('emailUNO', :with => appointment.mail)
    @s.fill_in('emailDOS', :with => appointment.mail)
    @s.click_on("Siguiente")
    puts "Step 2 successfull"
  end
end

class Step3ChooseCita
  def step(session)
    puts "Step 3"
    @s = session
    @s.find(:xpath, '//input[@type="radio" and @title="Seleccionar CITA 1"]').click
    @s.click_on("Siguiente")
    puts "Step 3 successfull"
  end
end

class Step4Confirm
  def step(session)
    puts "Step 4"
    @s = session
    @s.check('chkTotal')
    @s.check('enviarCorreo')
    @s.click_on('Confirmar')
    puts "Step 4 successfull"
    puts "Robot is waiting..."
    w = gets
  end
end

  # Итоговая страничка с нашим номером, который нам должен быть отправлен на email
  # Nº de Justificante de cita: AB7AF66H
  # <td class="tituloTabla" style="font-size:18px">
  # Nº de Justificante de cita:
  # <span id="justificanteFinal" class="justificanteBold"> AB7AF66H </span>
  # </td>


class SpanishRobot
  def initialize(captcha_solver, step0, steps_before_passport, fill_passport,
  	step1, step2, step3, step4)
  	@captcha_solver = captcha_solver
  	@step0 = step0
  	@steps_before_passport = steps_before_passport
  	@fill_passport = fill_passport
  	@step1 = step1
    @step2 = step2
    @step3 = step3
    @step4 = step4
    init_capybara
    step_through_site    
  end
  def init_capybara
  	#Capybara.default_max_wait_time = 15
    @s = Capybara::Session.new(:selenium)
  end
  def step_through_site
      @step0.step @s
      @steps_before_passport.step @s
      @fill_passport.step @s, @captcha_solver 
      @step1.step @s
      @step2.step @s
      @step3.step @s
      @step4.step @s
      
      #binding.pry
      # session.save_and_open_page 
  end
end

spajic = Appointment.new("ALEX V", "4508", "RUSIA", "9164363288", "bestspajic@gmail.com")
appl = spajic
cs = CaptchaSolverByHand.new
step0 = Step0.new
#steps_before_passport = StepsBeforePassportBarcelonaExtranjero.new
steps_before_passport = StepsBeforePassportMadridExtranjero.new
fill_passport = FillPassportExtranjero.new(appl)
step1 = Step1SolicitarCita.new
step2 = Step2EnterPhoneAndMail.new(appl)
step3 = Step3ChooseCita.new
step4 = Step4Confirm.new

robot = SpanishRobot.new(cs, step0, steps_before_passport, fill_passport, step1, step2, step3, step4)
