require_relative './types'

class Parser

  def tokenize str
    raise SyntaxError, 'Empty file' if str.empty?
    raise SyntaxError, 'No open lists' if str.include? ' ' and !str.include? '('
    "( #{str} )".gsub(')',' ) ').gsub(/(?<!\')\(/,' \0 ').gsub("'("," '( ").split(' ')
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

    if 0 == tokens.size then
      raise SyntaxError, 'Unexpected end of file'
    end

    token = tokens.shift

    if '(' == token then
      l = []
      while ')' != tokens[0] do
        l.push read tokens
      end
      tokens.shift
      return l
    elsif "'(" == token then
      r = tokens.shift tokens.index ')'
      tokens.shift
      return r
    elsif ')' == token then
      raise SyntaxError, 'Unexpected closing parenthesis'
    elsif token.is_a? Fixnum
      return token
    else
      return atom token 
    end

  end

  def parse src
    read tokenize src
  end

end
