require_relative './types'

class Parser

  def tokenize str
    x = str.gsub(')',' ) ').gsub(/(?<!\')\(/,' \0 ').gsub("'("," '( ").split(' ')

    if x.length > 1 and (!x.include? '(' and !x.include? "'(") then
      ['(', *x, ')'] 
    else
      x
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

      if tokens.size == 0 or tokens.uniq[0] == ')'
        return l
      else
        return [l, (read tokens)]
      end
    elsif "'(" == token then
      return tokens.shift tokens.index ')'
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
