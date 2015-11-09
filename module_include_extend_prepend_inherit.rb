# http://habrahabr.ru/post/143990/ - Вникаем в метаклассы ruby
# http://habrahabr.ru/post/143483/ - Вникаем в include и extend

# include — добавляет методы модуля объекту.
# extend — вызывает include для синглтон-класса объекта
module M
  def m
  	puts "instance-method m from module M"
  end
end

module M2
  def m2
  	puts "instance-method m2 from module M2"
  end
end

module E
  def e
  	puts "instance-method e from module E"
  end
end

module E2
end

class P
  @@ConstP = "ConstP"
  def self.pr
  	puts "class method pr of class p"
  	puts "Print #{@@ConstP} from class P" 
  end
end

module M3
end

module M4
end

class A < P
  include M
  include M2
  prepend M3
  prepend M4
  extend E
  extend E2
  def self.pr
  	puts "override class method of P in A < P"
  end
  def self.who_am_i
  	puts self
  end
  def speak_up(x)
  	puts x.upcase
  end
end

A.who_am_i
a = A.new
a.speak_up('hello')

def a.not_so_loud(x)
  puts x.downcase
end

a.not_so_loud("LOUD")

print "A.ancestors: "; p A.ancestors # A, M, Object, Kernel, BasicObject

a.m #
A.e #

print "'A.ancestors: "; p A.singleton_class.ancestors

A.pr

puts