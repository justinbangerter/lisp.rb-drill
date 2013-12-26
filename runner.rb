require_relative './types'

class Evaluator

  def evaluate x
    if x.is_a? Array

      z = x.map do |y|
        evaluate y
      end

      if z[0].is_a? Sym
        op = z.shift.op
        op.call z
      else
        "'( #{z.join(' ')} )"
      end

    else
      x
    end
  end

end
