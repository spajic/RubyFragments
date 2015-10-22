# Говорят, типовая супер-простая задачка для интервью
# Для i от 1 до 100 
#  если i кратно 3, то вывести foo,
#  если i кратно 5, то вывести bar
#  если i кратно и 3 и 5, то вывести foobar
#  если не кратно ни 3, ни 5, вывести просто i
for i in 1..100
	si = i.to_s
	if (i % 15) == 0
		puts si + " foobar"
	elsif (i % 3) == 0
		puts si + " foo"
	elsif (i % 5) == 0
		puts si + " bar"
	else
		puts si
	end
end