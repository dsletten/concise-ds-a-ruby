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
    assert(!stack.push(:foo).empty?, "Stack with elt should not be empty.")
    assert(stack.push(:foo).pop.empty?, "Empty stack should be empty.")
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
  end

  def assert_stack_size(stack, n)
      assert_equal(n, stack.size, "Size of stack should be #{n}")
  end    

  def test_clear(constructor)
    count = 1000
    stack = fill(constructor.call, count)
    assert(!stack.empty?, "Stack should have #{count} elements.")
    assert(stack.clear.empty?, "Stack should be empty.")
    assert_stack_size(stack.clear, 0)
  end

  def fill(stack, count)
    1.upto(count) do |i|
      stack = stack.push(i)
    end

    stack
  end

  #
  #    This is identical to test_peek in Ruby implementation. No multiple values to return popped value along with new stack...
  #    
  # def test_pop(constructor)
  #   count = 1000
  #   stack = fill(constructor.call, count)

  #   stack.size.downto(1) do |i|
  #     top = stack.peek
  #     assert_equal(i, top, "Value on top of stack should be #{i} not #{top}")
  #     stack = stack.pop
  #   end
  #   assert(stack.empty?)
  # end

  def test_peek(constructor)
    count = 1000
    stack = fill(constructor.call, count)

    stack.size.downto(1) do |i|
      top = stack.peek
      assert_equal(i, top, "Value on top of stack should be #{i} not #{top}")
      stack = stack.pop
    end

    assert(stack.empty?)
  end

  def test_time(constructor)
    count = 100000
    stack = constructor.call
    
    Benchmark.bm do |run|
      run.report("Timing #{stack.class}") do 
        10.times do
          new_stack = fill(stack, count)
          until new_stack.empty?
            new_stack = new_stack.pop
          end
        end
      end
    end
  end
end

class TestPersistentStack < TestStack
  def test_it
    test_constructor(lambda {Containers::PersistentStack.new})
    test_empty?(lambda {Containers::PersistentStack.new})
    test_size(lambda {Containers::PersistentStack.new})
    test_clear(lambda {Containers::PersistentStack.new})
#    test_pop(lambda {Containers::PersistentStack.new})
    test_peek(lambda {Containers::PersistentStack.new})
    test_time(lambda {Containers::PersistentStack.new})
  end
end

class TestPersistentListStack < TestStack
  def test_it
    test_constructor(lambda {Containers::PersistentListStack.new})
    test_empty?(lambda {Containers::PersistentListStack.new})
    test_size(lambda {Containers::PersistentListStack.new})
    test_clear(lambda {Containers::PersistentListStack.new})
#    test_pop(lambda {Containers::PersistentListStack.new})
    test_peek(lambda {Containers::PersistentListStack.new})
    test_time(lambda {Containers::PersistentListStack.new})
  end
end

