include Math

def f(x)
	0.5 * cos(x)
end

x = 0.7
for i in 1..100
	puts x
	x = f(x)
end