#!/usr/bin/ruby -w

#    File:
#       test_persistent_stack.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210304 Original.

require './containers'
require './list'
require './stack'
require 'test/unit'
require 'benchmark'

class TestStack < Test::Unit::TestCase # Conflict with test_stack.rb???
  def test_constructor(constructor)
    stack = constructor.call
    assert(stack.empty?, "New stack should be empty.")
    assert(stack.size.zero?, "Size of new stack should be zero.")
    assert_raises(StandardError, "Can't call peek() on empty stack.") { stack.peek }
    assert_raises(StandardError, "Can't call pop() on empty stack.") { stack.pop }
  end

  def test_empty?(constructor)
    stack = constructor.call
    assert(stack.empty?, "New stack should be empty.")

    stack = stack.push(:foo)
    assert(!stack.empty?, "Stack with elt should not be empty.")

    stack = stack.pop
    assert(stack.empty?, "Empty stack should be empty.")
  end

  def test_size(constructor)
    #  def test_size(constructor, count=1000)
    count = 1000
    stack = constructor.call
    assert(stack.size.zero?, "Size of new stack should be zero.")

    1.upto(count) do |i|
      stack = stack.push(i)
      assert_equal(i, stack.size, "Size of stack should be #{i} not #{stack.size}")
    end

    (count-1).downto(0) do |i|
      stack = stack.pop
      assert_equal(i, stack.size, "Size of stack should be #{i} not #{stack.size}")
    end

    assert(stack.empty?, "Stack should be empty.")
  end

  def test_clear(constructor)
    count = 1000
    original_stack = constructor.call.fill(count: count)

    assert(!original_stack.empty?, "Stack should have #{count} elements.")

    stack = original_stack.clear
    assert(stack.empty?, "Stack should be empty.")
    assert(!original_stack.empty?, "Original stack is unaffected.")
    assert(stack != original_stack, "Cleared stack is new stack.")
    assert_equal(0, stack.size, "Size of empty stack should be 0.")
    assert(stack == stack.clear, "Clearing empty stack has no effect.")
  end

  def test_elements(constructor)
    count = 1000
    stack = constructor.call.fill(count: count)
    expected = (1..count).to_a.reverse
    elts = stack.elements

    assert(expected == elts, "LIFO elements should be #{expected[0, 10]} not #{elts[0, 10]}")
  end
    
  def test_push(constructor)
    count = 1000
    stack = constructor.call

    1.upto(count) do |i|
      stack = stack.push(i)
      assert_equal(i, stack.peek, "Wrong value pushed: #{stack.peek} should be: #{i}")
    end
  end

  def test_push_wrong_type(constructor)
    stack = constructor.call(type: Integer)

    assert_raises(ArgumentError, "Can't push() value of wrong type onto stack.") { stack.push(1.0) }
  end

  def test_peek_pop(constructor)
    count = 1000
    stack = constructor.call.fill(count: count)

    stack.size.downto(1) do |i|
      top = stack.peek
      assert_equal(i, top, "Wrong value popped: #{top} should be #{i}")
      stack = stack.pop
    end

    assert(stack.empty?, "Stack should be empty.")
  end

  def test_time(constructor)
    count = 100000
    
    Benchmark.bm do |run|
      run.report("Timing #{constructor.call.class}") do 
        10.times do
          stack = constructor.call.fill(count: count)

          until stack.empty?
            stack = stack.pop
          end
        end
      end
    end
  end
end

def persistent_stack_test_suite(tester, constructor)
  puts("Testing #{constructor.call.class}")
  tester.test_constructor(constructor)
  tester.test_empty?(constructor)
  tester.test_size(constructor)
  tester.test_clear(constructor)
  tester.test_elements(constructor)
  tester.test_push(constructor)
  tester.test_push_wrong_type(constructor)
  tester.test_peek_pop(constructor)
  tester.test_time(constructor)
end
  
class TestPersistentLinkedStack < TestStack
  def test_it
    persistent_stack_test_suite(self, lambda {|type: Object| Containers::PersistentLinkedStack.new(type: type)})
  end
end

class TestPersistentListStack < TestStack
  def test_it
    persistent_stack_test_suite(self, lambda {|type: Object| Containers::PersistentListStack.new(type: type)})
  end
end

