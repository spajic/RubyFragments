# Constants lookup
#  Module.nesting
#  Module.nesting.first.ancestors
#  Object.ancestors if Module.nesting.first is nil or a module

module A
  A1 = 'A1'.freeze
  module B
    B1 = 'B1'.freeze
  end
end

module A
  module B
    p Module.nesting # [A::B, A]
    puts A1
    puts B1
  end
end

module A::B
  p Module.nesting # [A::B]
  # puts A1 # uninitialized constant A::B::A1
  puts B1 # Ok
end
