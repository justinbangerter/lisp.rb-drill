class Sym

  attr_accessor :token, :op

  def initialize token, block
    @token = token
    @op = block
  end

  def to_s
    @token
  end

end

module Symbols
  attr_accessor :ops

  @ops = {
    '+' => Sym.new('+', lambda do |l,r| l + r end),
    '-' => Sym.new('-', lambda do |l,r| l - r end),
    '/' => Sym.new('/', lambda do |l,r| l / r end),
    '*' => Sym.new('*', lambda do |l,r| l * r end),
  }

  def Symbols.ops 
    return @ops
  end
end

class Atom
end

class Number
end

class Function
end

def list *elements
  return elements
end

def cons car, cdr
  return list(car, cdr)
end

def car list
  return list[:cons]
end

def cdr list
  return list[:cdr]
end
