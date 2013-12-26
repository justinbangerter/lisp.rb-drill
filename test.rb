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

def evaluate source
  return Evaluator.new.evaluate parse source
end

class MyTest < Test::Unit::TestCase
  def test_numbers
    assert_equal(['1'], tokenize('1'))
    assert_equal(['15'], tokenize('15'))
    assert_equal(1, parse('1'))
    assert_equal(15, parse('15'))
    assert_equal(1, evaluate('1'))
    assert_equal(15, evaluate('15'))
  end

  def test_strings
    assert_equal('a', evaluate('a'))
    assert_equal('test', evaluate('test'))
  end

  def test_lists
    assert_equal(['(','+','15','5',')'], tokenize('(+ 15 5)'))
    assert_equal([ops['+'],15,5], parse('(+ 15 5)'))

    assert_equal(['(','a','(','x','3',')',')'], tokenize('(a (x 3))'))
    assert_equal(['a',['x',3]], parse('(a (x 3))'))
  end

  def test_missing_closing_paren
    assert_raise(SyntaxError) { evaluate('(3 4') }
  end

  def test_empty
    assert_raise(SyntaxError) { evaluate('') }
  end

  def test_open_list
    assert_equal(['(','3','4',')'],tokenize('3 4')) 
    assert_equal([3,4], parse('3 4')) 
    assert_equal('( 3 4 )', evaluate('3 4')) 
    assert_equal('( test x )', evaluate('test x'))
  end

  def test_basic_math
    assert_equal(4, evaluate('(+ 1 2 1)'))
    assert_equal(4, evaluate('(- 7 2 1)'))
    assert_equal(4, evaluate('(* 1 2 2)'))
    assert_equal(4, evaluate('(/ 16 2 2)'))
  end

  def test_boolean
    assert_equal(['true'], tokenize('true'))
    assert_equal(true, evaluate('true'))
    assert_equal(false, evaluate('false'))
  end
end
