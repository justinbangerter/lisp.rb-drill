require_relative './types'

class Evaluator

  def evaluate x, env={}, level_one=true
    result = if x.is_a? Array
      if Symbols.ops['lambda'] == x[0]
        raise SyntaxError, 'Only supply a block and a body to a lambda' if 3 != x.size
        z = x[0..1].map do |y|
          evaluate y, env, false
        end
        z.push x[2]
      else
        z = x.map do |y|
          evaluate y, env, false
        end
      end

      if z[0].is_a? Sym
        op = z.shift.op
        op.call z
      elsif z[0].is_a? Lambda
        l = z.shift

        l.call self, z
      else
        z
      end
    else
      Vars.var x or env[x] or x
    end

    if level_one
      result.pop
    else
      result
    end
  end

  def to_s x
    if x.is_a? Array
      x.map! do |y|
        to_s y
      end
      "'( #{x.join(' ')} )"
    else
      if Vars.var? x
        Vars.var x
      else
        x
      end
    end
  end
end
