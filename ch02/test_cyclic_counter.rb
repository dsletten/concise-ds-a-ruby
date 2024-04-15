#!/usr/bin/ruby -w
#    Hey, Emacs, this is a -*- Mode: Ruby -*- file!
#
#    File:
#       test_cyclic_counter.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       240404 Original.

require './cyclic_counter'
require 'test/unit'

class TestCounter < Test::Unit::TestCase
  def test_constructor(constructor)
    assert(constructor.call(8).index.zero?, "New counter index should be zero.")
    n = 10
    assert(n == constructor.call(n).modulus, "Modulus of counter should be #{n}.")
    assert_raises(ArgumentError, "Can't create counter with modulus of 0.") { constructor.call(0) }

    assert(constructor.call.index.zero?, "New default counter index should be zero.")
    assert(1 == constructor.call.modulus, "Modulus of default counter should be 1.")
  end

  def test_advance(constructor)
    n = 10
    c = constructor.call(n)
    c.advance
    assert(1 == c.index, "Index should be 1 after advancing once.")

    c = constructor.call(n)
    c.advance(n)
    assert(c.index.zero?, "Index should be 0 after advancing #{n} times.")
    
    c = constructor.call(n)
    c.advance(-2)
    assert(n-2 == c.index, "Index should be #{n-2} after advancing -2 times.")
  end

  def test_set(constructor)
    n = 10
    c = constructor.call(n)
    c.advance
    c.set(0)
    assert(c.index.zero?, "Index should be 0 after setting.")

    c = constructor.call(n)
    c.advance(2)
    c.set(0)
    assert(c.index.zero?, "Index should be 0 after setting.")

    c = constructor.call(n)
    c.set(-4)
    assert(n-4 == c.index, "Index should be #{n-4} after setting.")

    m = 6
    c = constructor.call(n)
    c.advance
    c.set(m)
    assert(m % n == c.index, "Index should be #{m % n} after setting.")

    m = 16
    c = constructor.call(n)
    c.set(m)
    assert(m % n == c.index, "Index should be #{m % n} after setting.")
  end    

  def test_reset(constructor)
    n = 10
    c = constructor.call(n)
    c.advance
    c.reset
    assert(c.index.zero?, "Index should be 0 after reset.")

    c = constructor.call(n)
    c.set(n-1)
    c.reset
    assert(c.index.zero?, "Index should be 0 after reset.")
  end

  def test_rollover(constructor)
    n = 10
    c = constructor.call(n)

    n.times do
      c.advance
    end

    assert(c.index.zero?, "Counter should roll over after advancing #{n} times.")
  end
end

def counter_test_suite(tester, constructor)
  puts("Testing #{constructor.call.class}")
  tester.test_constructor(constructor)
  tester.test_advance(constructor)
  tester.test_set(constructor)
  tester.test_reset(constructor)
  tester.test_rollover(constructor)
end
  
class TestCyclicCounter < TestCounter
  def test_it
    counter_test_suite(self, lambda {|n=1| CyclicCounter.new(n)})
  end
end
