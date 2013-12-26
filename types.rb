class Sym

  attr_accessor :token, :op

  def initialize token, op
    @token = token
    @op = op
  end

  def to_s
    @token
  end

end

module Symbols
  attr_accessor :ops

  @ops = {
    '+' => Sym.new('+', lambda do |a| a.map.inject :+ end),
    '-' => Sym.new('-', lambda do |a| a.map.inject :- end),
    '/' => Sym.new('/', lambda do |a| a.map.inject :/ end),
    '*' => Sym.new('*', lambda do |a| a.map.inject :* end),
    'eq?' => Sym.new('eq?', lambda do |a| a.map.inject do |l,r| l == r end end),
    'quote' => Sym.new('eq?', lambda do |a| a.join(' ') end),
  }

  def Symbols.ops 
    return @ops
  end
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
