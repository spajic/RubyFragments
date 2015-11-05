require 'pony'

Pony.options = { :via => :smtp,
  :via_options => {
    :address              => 'smtp.gmail.com',
    :port                 => '587',#'25',#'587'
    :enable_starttls_auto => true,
    :user_name            => ENV['PONY_MAIL'], # моя почта
    :password             => ENV['PONY_PASSWORD'], # пароль приложения, сгенерированный в gmail
    :authentication       => :plain, # :plain, :login, :cram_md5, no auth by default
    :domain               =>'HELO' # the HELO domain provided by the client to the server
  }
}

Pony.mail(:to => 'bestspajic@gmail.com', :from => 'bestspajic@gmail.com', 
	:subject => 'Pony test', :body => 'Pony test.')

puts "Mail have been sent! Exit now."