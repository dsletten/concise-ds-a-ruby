#!/usr/bin/ruby -w
#    Hey, Emacs, this is a -*- Mode: Ruby -*- file!
#
#    File:
#       test_persistent_cyclic_counter.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       240405 Original.

require './cyclic_counter'
require 'test/unit'

class TestPersistentCounter < Test::Unit::TestCase
  def test_constructor(constructor)
    assert(constructor.call(modulus: 8).index.zero?, "New counter index should be zero.")
    n = 10
    assert(n == constructor.call(modulus: n).modulus, "Modulus of counter should be #{n}.")
    assert_raises(ArgumentError, "Can't create counter with modulus of 0.") { constructor.call(modulus: 0) }

    assert(constructor.call.index.zero?, "New default counter index should be zero.")
    assert(1 == constructor.call.modulus, "Modulus of default counter should be 1.")
    assert(constructor.call(index: 5).index.zero?, "New default counter index should be zero.")
  end

  def test_advance(constructor)
    n = 10
    assert(1 == constructor.call(modulus: n).advance.index, "Index should be 1 after advancing once.")

    assert(constructor.call(modulus: n).advance(n).index.zero?, "Index should be 0 after advancing #{n} times.")
    
    assert(n-2 == constructor.call(modulus: n).advance(-2).index, "Index should be #{n-2} after advancing -2 times.")
  end

  def test_set(constructor)
    n = 10
    assert(constructor.call(modulus: n).advance.set(0).index.zero?, "Index should be 0 after setting.")

    assert(constructor.call(modulus: n).advance(2).set(0).index.zero?, "Index should be 0 after setting.")

    assert(n-4 == constructor.call(modulus: n).set(-4).index, "Index should be #{n-4} after setting.")

    m = 6
    assert(m % n == constructor.call(modulus: n).advance.set(m).index, "Index should be #{m % n} after setting.")

    m = 16
    assert(m % n == constructor.call(modulus: n).advance.set(m).index, "Index should be #{m % n} after setting.")
  end    

  def test_reset(constructor)
    n = 10
    assert(constructor.call(modulus: n).advance.reset.index.zero?, "Index should be 0 after reset.")

    assert(constructor.call(modulus: n).set(n-1).reset.index.zero?, "Index should be 0 after reset.")
  end

  def test_rollover(constructor)
    n = 10
    c = constructor.call(modulus: n)

    n.times do
      c = c.advance
    end

    assert(c.index.zero?, "Counter should roll over after advancing #{n} times.")
  end
end

def persistent_counter_test_suite(tester, constructor)
  puts("Testing #{constructor.call(modulus: 1).class}")
  tester.test_constructor(constructor)
  tester.test_advance(constructor)
  tester.test_set(constructor)
  tester.test_reset(constructor)
  tester.test_rollover(constructor)
end
  
class TestPersistentCyclicCounter < TestPersistentCounter
  def test_it
    persistent_counter_test_suite(self, lambda {|index: 0, modulus: 1| PersistentCyclicCounter.new(index: index, modulus: modulus)})
  end
end
