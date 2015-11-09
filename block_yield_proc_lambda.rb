# http://www.sitepoint.com/functional-programming-techniques-with-ruby-part-ii/
# Block is syntaxic sugar to create procs
# =============== Block ========================
def repeat(reps)
  if block_given?
  	reps.times {yield}
  end
end

repeat(3) {print "X"}  # XXX
puts

def repeat_expl(reps, &b)
  reps.times {yield}
end

repeat_expl(4) {print "Y"}  # YYYY
puts

def repeat_expl_call(reps, &b)
  reps.times {b.call}
end

repeat_expl_call(2) {print "Z"} # ZZ
puts

# Блоки - те же proc'ы, но для передачи в функцию proc надо пометить амперсандом
repeat(5, &proc{print "proc"}) # procprocprocprocproc
puts


# =================== Methods ======================
puts
def hi
  print "hi"
end
p method(:hi) #<Method: Object#hi>
method_hi = method(:hi)
puts method_hi.class # Method
repeat(3, &method_hi) # hihihi



# =============== Proc ================
puts
# Proc - встроенный класс, позволяет обернуть блок в объект. 
# Является замыканием, как и блок, т.е. запоминает контекст, в котором создан
# метод proc эквивалентен Proc.new
# метод p.call(params) - вызывает p, его синоним - квадратные скобки p[params]

# http://ruby-doc.org/core-2.2.3/Proc.htm
# Proc objects are blocks of code that have been bound to a set of local variables. 
# Once bound, the code may be called in different contexts and still access those variables.

# Пример - создать блок, принимающий два параметра - число, и степень, в которую его надо возвести.
# На осоновании этого блока сделать замыкания, Квадрат, Куб, Корень
power = proc {|val, power| val**power}

puts power.call(4, 2) # 16
puts power[2, 10] # 1024


square = proc {|val| power[val, 2]}
puts square[5] # 25

root = proc {|val| power[val, 0.5]}
puts root[64] # 8

def gen_power(p)
  proc {|val| val**p}
end

third = gen_power(3)
puts third.call(2) # 8

foursquare = (proc {|power, val| val**power}).curry[4]
puts foursquare[5] # 625


# ======================= Lambdas ====================
# Lambdas just like procs, но с двумя важными отличиями!
# 1. return из proc приводит к выходу из того scope, из которого он вызывался
#    return иp lambda приводик к выходу только из lambda
# 2. lambda Требует, чтобы кол-во аргументов совпадало с объявлением (в отличие от proc)

def greet(&block)
  block.call
  puts "Good morning!"
end

pr = Proc.new { return "This is proc!" }
# greet(p) # LocalJumpError

l = lambda { return "This is lambda!" }
greet(&l) # Good morning!

ll = lambda {|who| puts "I'll stab #{who}"}
ll['First one'] # I'll stab First one
p ll.class # Proc

stabby_l = ->(who) {puts "I'll stab #{who}"}
stabby_l['you']
# stabby_l['Cesar', 'error'] # wrong number of arguments

stabby_p = proc{|who| puts "I'll stab #{who}"}
stabby_p['you', 'no_error', 'nil'] # I'll stab you

adder = -> (a,b) {a + b}
puts adder[5, 7] # 12

l42 = lambda {puts 42}
l42.call

#========================= Symbols as blocks ==============================
# При передече в функцию, ожидающую блок, параметра, ruby пытается применить к нему to_proc
# для класа Symbol сделана такая реализация этого метода:
# class Symbol 
#   def to_proc
#      Proc.new {|obj| obj.send(self)}
#   end
#  end
#

p [100, 101, 102].map(&:chr) # ["d", "e", "f"]

#So, a quick overview of what we’ve looked at so far:
#
#    All functions in Ruby act, or can be made to act, like some variant of a Proc.
#    Blocks are really just syntactic sugar for Procs.
#    Lambdas are like Procs, but with stricter argument passing and localised returns.
#    Defined methods can be fetched as Method objects by using the Kernel#method method.
#    Use the & unary operator to signify when you are passing Procs/Lambdas/Methods as a block, 
#      and leave the operator off when you are passing them as a normal argument.


# ============ Partial application and currying ===================
# Partial function aplication is 
#   calling a function with some number of arguments, in order to 
#   get a function back that will take that many less arguments.

# Currying is 
#   taking a function that takes n arguments, and 
#   splitting it into n functions that take one argument.

proc { |x, y, z| x + y + z } 

# partial application of two first arguments
proc { |x, y| proc { |z| x + y + z} }

# currying
proc { |x| proc { |y| proc { |z| x + y + z} } } 

# Возникшая задачка: пусть есть proc, возводящий число в степень
pow = proc{|v, p| v**p}
# Надо к нему прибайндить второй аргумент - p, а первый чтобы остался свободным

puts pow[2, 5] # 32
pow_4 = proc{|v| pow[v,4]}
puts pow_4.call(5) # 625
pc = pow.curry
puts pc.call[5][3] # 125
