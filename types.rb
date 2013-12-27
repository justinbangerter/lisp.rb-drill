def Boolean s
  if s.is_a? String
    return true if s.downcase === 'true'
    return false if s.downcase === 'false' 
    raise ArgumentError "Given string '#{s}' cannot be a Boolean"
  elsif s.is_a? Number
    s.abs != 0
  else
    return true if s.is_a? TrueClass
    return false if s.is_a? FalseClass
    raise ArgumentError "Could not parse variable '#{s}'"
  end
end

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

module Vars
  @vars = {}

  def Vars.vars
    @vars
  end

  def Vars.set(key, val)
    @vars[key] = val
  end

  def Vars.var? x
    @vars.has_key? x
  end

  def Vars.var x
    @vars[x]
  end

  def Vars.clear
    @vars = {}
  end
end

module Symbols

  def Symbols.atom? x
    return true if x.is_a? Fixnum or x.is_a? Sym
    return false if x.is_a? Array or x.start_with? "'"
    return true
  end

  @ops = {
    'eq?' => Sym.new('eq?', lambda do |a|
      a.map.inject do |l,r| l == r end
    end),
    'quote' => Sym.new('quote', lambda do |a|
      a.map do |x|
        return "'#{x}" if x.is_a? String and !x.start_with? "'"
        return x
      end.join(' ')
    end),
    'cons' => Sym.new('cons', lambda do |a|
      [a[0],*a[1..-1]]
    end),
    'car' => Sym.new('car', lambda do |a|
      raise SyntaxError, 'car only accepts an array' if !a[0].is_a? Array
      Parser.new.read [a[0][0]]
    end),
    'cdr' => Sym.new('cdr', lambda do |a|
      raise SyntaxError, 'cdr only accepts an array' if !a[0].is_a? Array
      p = Parser.new
      a[0][1..-1].map do |x| p.atom x end
    end),
    'atom?' => Sym.new('atom?', lambda do |a|
      a.map do |x|
        Symbols.atom? x
      end.inject do |l, r|
        l and r
      end
    end),
    'define' => Sym.new('define', lambda do |a|
      if !a.size == 2 then
        raise SyntaxError, 'Only one value can be assigned to an argument'
      end
      Vars.set(a[0], a[1])
      ''
    end),
    'cond' => Sym.new('cond', lambda do |a|
      a.each do |x|
        if x[0] or x[0] == 'else'
          return x[1]
        end
      end
      raise SyntaxError, 'No condition satisfied'
    end),
  }

  def Symbols.add_op o
    @ops[o] = Sym.new(o, lambda do |a| a.inject o end)
  end

  Symbols.add_op '+'
  Symbols.add_op '-'
  Symbols.add_op '/'
  Symbols.add_op '*'

  def Symbols.ops 
    return @ops
  end
end
