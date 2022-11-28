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
      assert_stack_size(stack, i)
    end

    (count-1).downto(0) do |i|
      stack = stack.pop
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

    stack = stack.clear
    assert(stack.empty?, "Stack should be empty.")
    assert_stack_size(stack, 0)
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
      assert_equal(i, stack.peek, "Wrong value popped: #{stack.peek} should be #{i}")
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

class TestPersistentLinkedStack < TestStack
  def test_it
    constructor = lambda {|type: Object| Containers::PersistentLinkedStack.new(type: type)}

    test_constructor(constructor)
    test_empty?(constructor)
    test_size(constructor)
    test_clear(constructor)
    test_push(constructor)
    test_push_wrong_type(constructor)
    test_peek_pop(constructor)
    test_time(constructor)
  end
end

class TestPersistentListStack < TestStack
  def test_it
    constructor = lambda {|type: Object| Containers::PersistentListStack.new(type: type)}

    test_constructor(constructor)
    test_empty?(constructor)
    test_size(constructor)
    test_clear(constructor)
    test_push(constructor)
    test_push_wrong_type(constructor)
    test_peek_pop(constructor)
    test_time(constructor)
  end
end

