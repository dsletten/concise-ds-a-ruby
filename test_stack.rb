#!/usr/bin/ruby -w

#    File:
#       test_stack.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210116 Original.

require './containers'
require './list'
require './stack'
require 'test/unit'
require 'benchmark'

class TestStack < Test::Unit::TestCase
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
    stack.push(:foo)
    assert(!stack.empty?, "Stack with elt should not be empty.")
    stack.pop
    assert(stack.empty?, "Empty stack should be empty.")
  end

  def test_size(constructor)
#  def test_size(constructor, count=1000)
    count = 1000
    stack = constructor.call

    assert(stack.size.zero?, "Size of new stack should be zero.")

    1.upto(count) do |i|
      stack.push(i)
      assert_stack_size(stack, i)
    end
    
    (count-1).downto(0) do |i|
      stack.pop
      assert_stack_size(stack, i)
    end
      
    assert(stack.empty?, "Stack should be empty.")
  end

  def assert_stack_size(stack, n)
      assert_equal(n, stack.size, "Size of stack should be #{n}")
  end    

  def test_clear(constructor)
    count = 1000
    stack = constructor.call.fill(count: count)
    assert(!stack.empty?, "Stack should have #{count} elements.")

    stack.clear
    assert(stack.empty?, "Stack should be empty.")
    assert_stack_size(stack, 0)
  end

  def test_elements(constructor)
    count = 1000
    stack = constructor.call.fill(count: count)
    expected = (1..count).to_a.reverse
    elts = stack.elements

    assert(expected == elts, "LIFO elements should be #{expected[0, 10]} not #{elts[0, 10]}")
    assert(stack.empty?, "Mutable stack should be empty after elements are extracted.")
  end
    
  def test_push(constructor)
    count = 1000
    stack = constructor.call

    1.upto(count) do |i|
      stack.push(i)
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

    stack.size.times do
      top = stack.peek
      popped = stack.pop
      assert_equal(top, popped, "Wrong value popped: #{popped} should be #{top}")
    end

    assert(stack.empty?, "Stack should be empty.")
  end

  def test_time(constructor)
    count = 100000
    stack = constructor.call
    
    Benchmark.bm do |run|
      run.report("Timing #{stack.class}") do 
        10.times do
          stack.fill(count: count)
          until stack.empty?
            stack.pop
          end
        end
      end
    end
  end

  def test_wave(constructor)
    stack = constructor.call

    Benchmark.bm do |run|
      run.report("Test wave") do 
        stack.fill(count: 5000)
        assert_stack_size(stack, 5000)

        3000.times { stack.pop }
        assert_stack_size(stack, 2000)
        
        stack.fill(count: 5000)
        assert_stack_size(stack, 7000)

        3000.times { stack.pop }
        assert_stack_size(stack, 4000)

        stack.fill(count: 5000)
        assert_stack_size(stack, 9000)

        3000.times { stack.pop }
        assert_stack_size(stack, 6000)

        stack.fill(count: 4000)
        assert_stack_size(stack, 10000)

        10000.times { stack.pop }
        assert(stack.empty?, "Stack should be empty.")
      end
    end
  end
end

def stack_test_suite(tester, constructor)
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
  tester.test_wave(constructor)
end
  
class TestArrayStack < TestStack
  def test_it
    stack_test_suite(self, lambda {|type: Object| Containers::ArrayStack.new(type: type)})
  end
end

class TestLinkedStack < TestStack
  def test_it
    stack_test_suite(self, lambda {|type: Object| Containers::LinkedStack.new(type: type)})
  end
end

class TestLinkedListStack < TestStack
  def test_it
    stack_test_suite(self, lambda {|type: Object| Containers::LinkedListStack.new(type: type)})
  end
end

class TestHashStack < TestStack
  def test_it
    stack_test_suite(self, lambda {|type: Object| Containers::HashStack.new(type: type)})
  end
end
