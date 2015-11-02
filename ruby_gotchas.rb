# From Toptal: http://www.toptal.com/ruby/interview-questions

# 1. What will val1 and val2 equal after the code below is executed? 
# Explain your answer.
puts "Question 1."
val1 = true and false  # hint: output of this statement in IRB is NOT value of val1!
val2 = true && false
puts "val1 = true and false"
puts "val2 = true && false"
puts
puts "val1 = #{val1}"
puts "val2 = #{val2}"
puts 

=begin Решение.
Дело тут в приоритетах операторов.
В Ruby операторы имеют следующие приоритеты: от высокого к низкому
(из книги The Ruby Way, 1.2.4 Операторы и приоритеты)
::         - Разрешение области видимости
[]         - Взятие индекса
**         - Возведение в степень
+-!~       - Унарные операции: плюс, минус, не
*/%        - Умножение, деление, остаток от деления
+-         - Сложение, вычитание
<<>>       - Логические сдвиги
&          - Поразрядное И
|^         - Порязрядное ИЛИ, Исключающее ИЛИ
> >= < <=  - Сравнение
== === <=> != =~ !~ - Равенство, неравенство, ...
&&         - Логическое И
||         - Логическое ИЛИ
.. ...     - Операторы диапазона
= += -= ...- Присваивание
?:         - Тернарный выбор
not        - Логическое отрицание
and or     - Логическое И, ИЛИ

В общем, оператор and имеет САМЫЙ НИЗКИЙ ПРИОРИТЕ, ниже присваивания =
Оператор && имеет приоритет выше присваивания

Расставим скобки:
(val1 = true) and false => val1 = true
val2 = (true && false) => val2 = false
=end

# 2. Which of the expressions listed below will result in "false"?

# true    ? "true" : "false"
# false   ? "true" : "false"
# nil     ? "true" : "false"
# 1       ? "true" : "false"
# 0       ? "true" : "false"
# "false" ? "true" : "false"
# ""      ? "true" : "false"
# []      ? "true" : "false"

=begin Решение
- Мнемоника тернарного оператора: Условие - Вопрос - true : false
 a > b ? do_true : do_false
- В ruby как ЛОЖЬ вычисляются только nil и false.

=end
puts "Question 2."
puts('true    ? "true" : "false"')
puts 'Expect "true", т.к. true - Истина, выполняется первое выражение'
puts true    ? "true" : "false"

puts 'false   ? "true" : "false"'
puts 'Expect "false", т.к. false - Ложь, выполняется второе выражение'
puts false   ? "true" : "false"

puts 'nil     ? "true" : "false"'
puts 'Expect  "false", т.к. nil - Ложь'
puts nil     ? "true" : "false"

puts '1       ? "true" : "false"'
puts 'Expect "true", т.к. 1 - не false и не nil, а значит Истина'
puts 1       ? "true" : "false"

puts '0       ? "true" : "false"'
puts 'Expect "true", т.к. 0 - не false и не nil, а значит Истина'
puts 0       ? "true" : "false"

puts '"false" ? "true" : "false"'
puts 'Expect "true", т.к. "false" - не false и не nil, а значит Истина'
puts "false" ? "true" : "false"

puts "В остальных случаях аналогично"
puts '""      ? "true" : "false"'
puts ""      ? "true" : "false"
puts '[]      ? "true" : "false"'
puts []      ? "true" : "false"

# 3. Write a function that sorts the keys in a hash by the 
#  length of the key as a string. For instance, the hash:
# { abc: 'hello', 'another_key' => 123, 4567 => 'third' }
# 
# should result in:
# 
# ["abc", "4567", "another_key"]
puts
puts "Question 3."
test = { abc: 'hello', 'another_key' => 123, 4567 => 'third' }

# Первый пришедший мне вариант
def hash_keys_array_sorted_by_length(h)
  h.keys.sort_by {|k| k.to_s.length}
end

p hash_keys_array_sorted_by_length(test)
# Ещё варианты:
# hsh.keys.map(&:to_s).sort_by(&:length)
# hsh.keys.collect(&:to_s).sort_by { |key| key.length }
# hsh.keys.collect(&:to_s).sort { |a, b| a.length <=> b.length }
# An equivalent call of the collect method is done with the usual block syntax of:
#  collect { |x| x.to_s }
