require_relative './types'

class Evaluator

  def evaluate x, level_one=true
    result = if x.is_a? Array
      z = x.map do |y|
        evaluate y, false
      end

      if z[0].is_a? Sym
        op = z.shift.op
        op.call z
      else
        z
      end

    else

      if Vars.var? x
        Vars.var x
      else
        x
      end
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
