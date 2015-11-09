# Enumerable.collect
# Возвращает новый массив, применяя блок к каждому элементу
puts [1, 2, 3].collect{|x| x**3} # 1, 8, 27
puts [1, 2, 3, 4].map{|x| x**2} # 1, 4, 9

# select
p [1, 2, 3, 4, 5, 6, 7].select{|x| (x % 2) == 0} # 2, 4, 6

# inject
# Combines all elements of enum by applying a binary operation, 
# specified by a block or a symbol that names a method or operator.

# If you specify a block, then for each element in enum 
# the block is passed an accumulator value (memo) and the element. 
# If you specify a symbol instead, then each element in the collection 
# will be passed to the named method of memo. 
# In either case, the result becomes the new value for memo. 
# At the end of the iteration, the final value of memo is the return value for the method.

# If you do not explicitly specify an initial value for memo, 
# then the first element of collection is used as the initial value of memo.

a = [1, 2, 3, 4, 5, 6, 7, 8, 9]
puts a.inject(&:+) # 45
puts a.inject{|sum, x| sum += x} # 45
puts a.inject(100, :+) #145 - задаём начальное значение аккумулятора
puts a.reduce(:-) # -43
puts a.reduce{|mul, x| mul *= x} # 362880
puts a.reduce(:*)