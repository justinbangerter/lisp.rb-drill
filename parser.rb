require_relative './types'

class Parser

  def tokenize str
    x = str.gsub(/[\(\)]/,' \0 ').split(' ')
    if x.length > 1 and !x.include? '(' then
      ['(', *x, ')'] 
    else
      x
    end
  end

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

  def atom token
    begin
      Integer(token)
    rescue ArgumentError
      begin
        Float(token)
      rescue ArgumentError
        Boolean(token)
      end
    end
  rescue
    if Symbols.ops.has_key? token then
      Symbols.ops[token]
    else
      token
    end
  end

  def read tokens

    if tokens.size == 0 then
      raise SyntaxError, 'Unexpected end of file'
    end

    token = tokens.shift

    if '(' == token then
      l = []
      while tokens[0] != ')' do
        l.push read tokens
      end
      tokens.shift
      return l
    elsif ')' == token then
      raise SyntaxError, 'Unexpected closing parenthesis'
    else
      return atom token 
    end

  end

  def parse src
    read tokenize src
  end

end
