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
  end

  def assert_stack_size(stack, n)
      assert_equal(n, stack.size, "Size of stack should be #{n}")
  end    

  def test_clear(constructor)
    count = 1000
    stack = fill(constructor.call, count)
    assert(!stack.empty?, "Stack should have #{count} elements.")
    stack.clear
    assert(stack.empty?, "Stack should be empty.")
    assert_stack_size(stack, 0)
  end

  def fill(stack, count)
    1.upto(count) do |i|
      stack.push(i)
    end

    stack
  end

  def test_pop(constructor)
    count = 1000
    stack = fill(constructor.call, count)

    stack.size.downto(1) do |i|
      popped = stack.pop
      assert_equal(i, popped, "Value on top of stack should be #{i} not #{popped}")
    end
    assert(stack.empty?)
  end
    
  def test_peek(constructor)
    count = 1000
    stack = fill(constructor.call, count)

    stack.size.downto(1) do |i|
      top = stack.peek
      assert_equal(i, top, "Value on top of stack should be #{i} not #{top}")
      stack.pop
    end
    assert(stack.empty?)
  end

  def test_time(constructor)
    count = 100000
    stack = constructor.call
    
    Benchmark.bm do |run|
      run.report("Timing #{stack.class}") do 
        10.times do
          fill(stack, count)
          until stack.empty?
            stack.pop
          end
        end
      end
    end
  end

  def test_wave(constructor)
    stack = constructor.call
    fill(stack, 5000)
    assert_stack_size(stack, 5000)

    3000.times { stack.pop }
    assert_stack_size(stack, 2000)
    
    fill(stack, 5000)
    assert_stack_size(stack, 7000)

    3000.times { stack.pop }
    assert_stack_size(stack, 4000)

    fill(stack, 5000)
    assert_stack_size(stack, 9000)

    3000.times { stack.pop }
    assert_stack_size(stack, 6000)

    fill(stack, 4000)
    assert_stack_size(stack, 10000)

    10000.times { stack.pop }
    assert(stack.empty?, "Stack should be empty.")
  end
end

class TestArrayStack < TestStack
  def test_it
    test_constructor(lambda {Containers::ArrayStack.new})
    test_empty?(lambda {Containers::ArrayStack.new})
    test_size(lambda {Containers::ArrayStack.new})
    test_clear(lambda {Containers::ArrayStack.new})
    test_pop(lambda {Containers::ArrayStack.new})
    test_peek(lambda {Containers::ArrayStack.new})
    test_time(lambda {Containers::ArrayStack.new})
    test_wave(lambda {Containers::ArrayStack.new})
  end
end

class TestLinkedStack < TestStack
  def test_it
    test_constructor(lambda {Containers::LinkedStack.new})
    test_empty?(lambda {Containers::LinkedStack.new})
    test_size(lambda {Containers::LinkedStack.new})
    test_clear(lambda {Containers::LinkedStack.new})
    test_pop(lambda {Containers::LinkedStack.new})
    test_peek(lambda {Containers::LinkedStack.new})
    test_time(lambda {Containers::LinkedStack.new})
    test_wave(lambda {Containers::LinkedStack.new})
  end
end

class TestLinkedListStack < TestStack
  def test_it
    test_constructor(lambda {Containers::LinkedListStack.new})
    test_empty?(lambda {Containers::LinkedListStack.new})
    test_size(lambda {Containers::LinkedListStack.new})
    test_clear(lambda {Containers::LinkedListStack.new})
    test_pop(lambda {Containers::LinkedListStack.new})
    test_peek(lambda {Containers::LinkedListStack.new})
    test_time(lambda {Containers::LinkedListStack.new})
    test_wave(lambda {Containers::LinkedListStack.new})
  end
end

class TestHashStack < TestStack
  def test_it
    test_constructor(lambda {Containers::HashStack.new})
    test_empty?(lambda {Containers::HashStack.new})
    test_size(lambda {Containers::HashStack.new})
    test_clear(lambda {Containers::HashStack.new})
    test_pop(lambda {Containers::HashStack.new})
    test_peek(lambda {Containers::HashStack.new})
    test_time(lambda {Containers::HashStack.new})
    test_wave(lambda {Containers::HashStack.new})
  end
end
