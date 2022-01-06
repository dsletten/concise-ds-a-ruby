#!/snap/bin/ruby -w

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
require 'test/unit'

class TestStack < Test::Unit::TestCase
  def test_constructor(constructor)
    stack = constructor.call
    assert(stack.empty?, "New stack should be empty.")
    assert(stack.size.zero?, "Size of new stack should be zero.")
    assert_raises(StandardError, "Can't call top() on empty stack.") { stack.top }
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
      assert_equal(i, stack.size, "Size of stack should be #{i}")
    end
  end

  def test_clear(constructor)
    count = 1000
    stack = fill(constructor.call, count)
    assert(!stack.empty?, "Stack should have #{count} elements.")
    assert(stack.clear.empty?, "Stack should be empty.")
  end

  def fill(stack, count)
    1.upto(count) do |i|
      stack = stack.push(i)
    end

    stack
  end

  #
  #    This is identical to test_top in Ruby implementation. No multiple values to return popped value along with new stack...
  #    
  def test_pop(constructor)
    count = 1000
    stack = fill(constructor.call, count)

    stack.size.downto(1) do |i|
      top = stack.top
      assert_equal(i, top, "Value on top of stack should be #{i} not #{top}")
      stack = stack.pop
    end
    assert(stack.empty?)
  end

  def test_top(constructor)
    count = 1000
    stack = fill(constructor.call, count)

    stack.size.downto(1) do |i|
      top = stack.top
      assert_equal(i, top, "Value on top of stack should be #{i} not #{top}")
      stack = stack.pop
    end
    assert(stack.empty?)
  end
end

class TestPersistentStack < TestStack
  def test_it
    test_constructor(lambda {Collections::PersistentStack.new})
    test_empty?(lambda {Collections::PersistentStack.new})
    test_size(lambda {Collections::PersistentStack.new})
    test_clear(lambda {Collections::PersistentStack.new})
    test_pop(lambda {Collections::PersistentStack.new})
    test_top(lambda {Collections::PersistentStack.new})
  end
end

