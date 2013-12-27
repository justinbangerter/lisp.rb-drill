require_relative './types'

class Evaluator

  def evaluate x, ret=true
    if x.is_a? Array

      z = x.map do |y|
        evaluate y
      end.select do |y|
        y != ''
      end

      if z.size == 1
        z = z[0]
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
  end

  def to_s x
    if x.is_a? Array
      x.select! do |y|
        !y.nil?
      end
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
