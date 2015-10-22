# Переопределить метод Array.each, не используя each

a = [1, 3, 5, 7]

=begin
# Проверка того, что если переопределить метод так, то 
# действительно будет выведена строка
class Array
	def each 
 		puts 'This is my implemetation'
	end
end
=end

class Array
	def each 
 		0.upto self.length - 1 do |x|
 			yield self[x]
 		end
	end
end

a.each do |el|
	puts el.to_s
end
