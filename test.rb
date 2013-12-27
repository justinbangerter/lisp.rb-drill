#!/usr/bin/ruby

require 'test/unit'
require_relative './parser'
require_relative './runner'

def ops 
  Symbols.ops
end

def tokenize src
  Parser.new.tokenize src
end

def parse src
  Parser.new.parse src
end

def evaluate src
  Vars.clear
  Evaluator.new.evaluate parse src
end

def full_run src
  Evaluator.new.to_s evaluate src
end

class MyTest < Test::Unit::TestCase
  def test_numbers
    assert_equal(['(','1', ')'], tokenize('1'))
    assert_equal(['(','15', ')'], tokenize('15'))
    assert_equal([1], parse('1'))
    assert_equal([15], parse('15'))
    assert_equal(1, evaluate('1'))
    assert_equal(15, evaluate('15'))
  end

  def test_strings
    assert_equal('a', evaluate('a'))
    assert_equal('test', evaluate('test'))
  end

  def test_lists
    assert_equal(['(','(','+','15','5',')', ')'], tokenize('(+ 15 5)'))
    assert_equal([[ops['+'],15,5]], parse('(+ 15 5)'))

    assert_equal(['(',"'(",'+','15','5',')', ')'], tokenize("'(+ 15 5)"))
    assert_equal([['+','15','5']], parse("'(+ 15 5)"))

    assert_equal(['(','(','a','(','x','3',')',')', ')'], tokenize('(a (x 3))'))
    assert_equal([['a',['x',3]]], parse('(a (x 3))'))
  end

  def test_missing_closing_paren
    assert_raise(SyntaxError) { evaluate('(3 4') }
  end

  def test_empty
    assert_raise(SyntaxError) { evaluate('') }
  end

  def test_open_list
    assert_raise(SyntaxError) { tokenize('3 4') } 
    assert_raise(SyntaxError) { parse('3 4') } 
    assert_raise(SyntaxError) { evaluate('3 4') } 
    assert_raise(SyntaxError) { evaluate('test x') } 
  end

  def test_basic_math
    assert_equal(4, evaluate('(+ 1 2 1)'))
    assert_equal(4, evaluate('(- 7 2 1)'))
    assert_equal(4, evaluate('(* 1 2 2)'))
    assert_equal(4, evaluate('(/ 16 2 2)'))
  end

  def test_boolean
    assert_equal(['(','true',')'], tokenize('true'))
    assert_equal([true], parse('true'))
    assert_equal(true, evaluate('true'))

    assert_equal(true, evaluate('tRue'))
    assert_equal(false, evaluate('false'))
    assert_equal(false, evaluate('fAlse'))
  end

  def test_equality
    assert_equal([[ops['eq?'], 1, 1]], parse('(eq? 1 1)'))
    assert_equal(true, evaluate('(eq? 1 1)'))
    assert_equal(false, evaluate('(eq? 1 2)'))

    assert_equal(true, evaluate('(eq? a a)'))
    assert_equal(false, evaluate('(eq? a b)'))

    assert_equal(true, evaluate('(eq? true true)'))
    assert_equal(false, evaluate('(eq? false true)'))
  end

  def test_quote
    assert_equal(['(','(', 'quote' , "'(", "1", "1", ")", ')', ')'], tokenize("(quote '(1 1))"))
    assert_equal([[ops['quote'], [ "1", "1" ]]], parse("(quote '(1 1))"))
    assert_equal("'( 1 1 )", full_run("(quote '(1 1))"))
    assert_equal("'( 1 2 3 )", full_run("(quote '(1 2 3))"))
    assert_equal("'a", evaluate("(quote a)"))
  end

  def test_cons
    assert_equal("'( 1 2 3 )", full_run("(cons 1 2 3)"))
  end

  def test_car
    assert_raises(SyntaxError) do evaluate("(car 1 2 3)") end

    assert_equal([[ops['car'], [1, 2, 3]]], parse("(car (1 2 3))"))
    assert_equal(1, evaluate("(car (1 2 3))"))

    assert_equal(1, evaluate("(car '(1 2 3))"))
  end

  def test_cdr
    assert_raises(SyntaxError) do evaluate("(cdr 1 2 3)") end

    assert_equal([[ops['cdr'], [1, 2, 3]]], parse("(cdr (1 2 3))"))
    assert_equal("'( 2 3 )", full_run("(cdr (1 2 3))"))
  end

  def test_atom
    assert_equal(true, evaluate("( atom? asdf)"))
    assert_equal(true, evaluate("( atom? 1)"))
    assert_equal(true, evaluate("( atom? +)"))
    assert_equal(false, evaluate("( atom? '(1 2 3 4))"))
  end

  def test_define
    assert_equal("", full_run("(define a 5)"))

    assert_equal("", full_run("(define box (cons 3 4))"))
    
    assert_equal(
      ['(',"(", "define", "box", "(", "cons", "3", "4", ")", ")", "(", "cons", "3", "box", ")", ')'],
      tokenize("(define box (cons 3 4))\n(cons 3 box)")
    )
    assert_equal(
      [[ops['define'],'box',[ops['cons'],3,4]],[ops['cons'],3,'box']],
      parse("(define box (cons 3 4))\n(cons 3 box)")
    )
    assert_equal([3, [3, 4]], evaluate("(define box (cons 3 4))\n(cons 3 box)"))
    assert_equal("'( 3 '( 3 4 ) )", full_run("(define box (cons 3 4))\n(cons 3 box)"))

    assert_equal(3, evaluate("(define box (cons 3 4))(car box)"))
    assert_equal(3, evaluate("(define box (cons 3 4)) (car box)"))
    assert_equal(3, evaluate("(define box (cons 3 4))\n(car box)"))

    assert_equal([4], evaluate("(define box (cons 3 4))(cdr box)"))
  end

  def test_multi_define
    assert_equal(11, full_run("(define a 5)(define b (+ a 1))(+ a b)"))
    assert_equal(11, full_run("(define a 5) (define b (+ a 1)) (+ a b)"))
    assert_equal(11, full_run("(define a 5)\n(define b (+ a 1))\n(+ a b)"))
  end

  def test_empty_list
    assert_equal(['(','(',')', ')'], tokenize("()"))
    assert_equal([[]], parse("()"))
    assert_equal([], evaluate("()"))
    assert_equal("'(  )", full_run("()"))
    assert_equal([[[],[]]], parse("(()())"))
    assert_equal([[],[]], evaluate("(()())"))
    assert_equal([[[]]], parse("(())"))
    assert_equal([[]], evaluate("(())"))
    assert_equal("'( '(  ) )", full_run("(())"))

    assert_equal([], evaluate("(cdr (cdr (cdr (1 2 3))))"))
    assert_equal("'(  )", full_run("(cdr (cdr (cdr (1 2 3))))"))
  end

  def test_nested_lists
    assert_equal("'( '( '(  ) '(  ) ) '(  ) )", full_run("( ( () () ) ())"))
    assert_equal("'( '( '(  ) '(  ) ) '(  ) )", full_run("( ( () () ) ())"))
    assert_equal(['(','(', 'y', '(', '(', ')', 'x', ')', '(', '(', ')', 'x', ')', '(', 'x', ')', ')', ')'], tokenize(<<END
(y (() x)
   (() x)
   (x))
END
    ))
    assert_equal([['y', [[], 'x'], [[], 'x'], ['x']]], parse(<<END
(y (() x)
   (() x)
   (x))
END
    ))
    assert_equal(['y', [[], 'x'], [[], 'x'], ['x']], evaluate(<<END
(y (() x)
   (() x)
   (x))
END
    ))
    assert_equal("'( y '( '(  ) x ) '( '(  ) x ) '( x ) )", full_run(<<END
(y (() x)
   (() x)
   (x))
END
  ))
  end

  def test_cond
    assert_equal("'three", full_run(<<END
(define a 3)
(cond ((eq? a 1) 'one)
      ((eq? a 2) 'two)
      ((eq? a 3) 'three)
      (else 'no-idea))
END
                                   ))
  end
end
