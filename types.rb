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
    'eq?' => Sym.new('eq?', lambda do |a| a.map.inject do |l,r| l == r end end),
    'quote' => Sym.new('quote', lambda do |a|
      a.map do |x|
        return "'#{x}" if !x.start_with? "'"
        return x
      end.join(' ')
    end),
    'cons' => Sym.new('cons', lambda do |a| "'( #{[a[0],*a[1..-1]].join(' ')} )" end),
    'car' => Sym.new('cons', lambda do |a| a[0] end),
    'cdr' => Sym.new('cons', lambda do |a| "'( #{a[1..-1].join(' ')} )" end),
  }

  def Symbols.add_op o
    @ops[o] = Sym.new(o, lambda do |a| a.map.inject o end)
  end

  Symbols.add_op '+'
  Symbols.add_op '-'
  Symbols.add_op '/'
  Symbols.add_op '*'

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
