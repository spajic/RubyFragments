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

class StepsBeforePassportBarcelona
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

class StepsBeforePassportMadrid
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

class FillPassport
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

class Step1SolicitarCita
  def step (session)
  	@s = session
    @s.click_on("SOLICITAR CITA")  

  	until @s.has_selector?(:xpath, '//input[@value="Siguiente" and @type="button"]')
      sleep_time = rand 10
      puts "Button Siguiente not found. Sleep for #{sleep_time}s and try again!"
      sleep sleep_time
      @s.click_on("Volver")
      @s.click_on("SOLICITAR CITA")  
  	end
  	puts "HOORAY!!!"
    @s.click_on("Siguiente")
    print "robot is waiting..."
    w = gets
  end
end

class SpanishRobot
  def initialize(captcha_solver, step0, steps_before_passport, fill_passport,
  	step1)
  	@captcha_solver = captcha_solver
  	@step0 = step0
  	@steps_before_passport = steps_before_passport
  	@fill_passport = fill_passport
  	@step1 = step1
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
      
      

      # Заполняем телефон и email два раза
      # Siguiente
      # Выбираем radio button "Seleccionar CITA 1"
      # Siguente
      # Устанавливаем два чекбокса 
      #   chkTotal
      #   enviarCorreo
      # нажимаем кнопку confirmar
      # Итоговая страничка с нашим номером, который нам должен быть отправлен на email
      # Nº de Justificante de cita: AB7AF66H
      # <td class="tituloTabla" style="font-size:18px">
      # Nº de Justificante de cita:
      # <span id="justificanteFinal" class="justificanteBold"> AB7AF66H </span>
      # </td>



      #binding.pry
      # session.save_and_open_page 
  end
end

cs = CaptchaSolverByHand.new
step0 = Step0.new
steps_before_passport = StepsBeforePassportBarcelona.new
#steps_before_passport = StepsBeforePassportMadrid.new
fill_passport = FillPassport.new
step1 = Step1SolicitarCita.new
robot = SpanishRobot.new(cs, step0, steps_before_passport, fill_passport, step1)
