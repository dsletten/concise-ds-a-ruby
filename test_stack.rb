#!/snap/bin/ruby -w

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
require './stack'
require 'test/unit'

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
      assert_equal(i, stack.size, "Size of stack should be #{i}")
    end
  end

  def test_clear(constructor)
    count = 1000
    stack = constructor.call
    fill(stack, count)
    assert(!stack.empty?, "Stack should have #{count} elements.")
    stack.clear
    assert(stack.empty?, "Stack should be empty.")
  end

  def fill(stack, count)
    1.upto(count) do |i|
      stack.push(i)
    end
  end

  def test_pop(constructor)
    count = 1000
    stack = constructor.call
    fill(stack, count)

    stack.size.downto(1) do |i|
      popped = stack.pop
      assert_equal(i, popped, "Value on top of stack should be #{i} not #{popped}")
    end
    assert(stack.empty?)
  end
    
  def test_peek(constructor)
    count = 1000
    stack = constructor.call
    fill(stack, count)

    stack.size.downto(1) do |i|
      top = stack.peek
      assert_equal(i, top, "Value on top of stack should be #{i} not #{top}")
      stack.pop
    end
    assert(stack.empty?)
  end

  def test_wave(constructor)
    stack = constructor.call
    fill(stack, 5000)
    assert_equal(5000, stack.size, "Size of stack should be 5000")
    3000.times { stack.pop }
    assert_equal(2000, stack.size, "Size of stack should be 2000")
    
    fill(stack, 5000)
    assert_equal(7000, stack.size, "Size of stack should be 7000")
    3000.times { stack.pop }
    assert_equal(4000, stack.size, "Size of stack should be 4000")

    fill(stack, 5000)
    assert_equal(9000, stack.size, "Size of stack should be 9000")
    3000.times { stack.pop }
    assert_equal(6000, stack.size, "Size of stack should be 6000")

    fill(stack, 4000)
    assert_equal(10000, stack.size, "Size of stack should be 10000")
    10000.times { stack.pop }
    assert(stack.empty?, "Stack should be empty.")
  end

  # def test_container_ops
  #   s = LinkedStack.new
  #   assert(s.empty?)
  #   assert_equal(0, s.size)
  #   (1..3).each { |i| s.push(i) }
  #   assert(!s.empty?)
  #   assert_equal(3, s.size)
  #   s.clear
  #   assert(s.empty?)
  #   assert_equal(0, s.size)
  # end
  
  # def test_stack_ops
  #   s = LinkedStack.new
  #   assert_raises(StandardError) { s.pop }
  #   assert_raises(StandardError) { s.top }
  #   (1..20).each { |i| s.push(i) }
  #   assert_equal(20, s.top)
  #   assert_equal(20, s.pop)
  #   assert_equal(19, s.size)
  #   assert_equal(19, s.top)
  # end
end

class TestLinkedStack < TestStack
  def test_it
    test_constructor(lambda {Collections::LinkedStack.new})
    test_empty?(lambda {Collections::LinkedStack.new})
    test_size(lambda {Collections::LinkedStack.new})
    test_clear(lambda {Collections::LinkedStack.new})
    test_pop(lambda {Collections::LinkedStack.new})
    test_peek(lambda {Collections::LinkedStack.new})
    test_wave(lambda {Collections::LinkedStack.new})
  end
end

class TestArrayStack < TestStack
  def test_it
    test_constructor(lambda {Collections::ArrayStack.new})
    test_empty?(lambda {Collections::ArrayStack.new})
    test_size(lambda {Collections::ArrayStack.new})
    test_clear(lambda {Collections::ArrayStack.new})
    test_pop(lambda {Collections::ArrayStack.new})
    test_peek(lambda {Collections::ArrayStack.new})
    test_wave(lambda {Collections::ArrayStack.new})
  end
end

class TestHashStack < TestStack
  def test_it
    test_constructor(lambda {Collections::HashStack.new})
    test_empty?(lambda {Collections::HashStack.new})
    test_size(lambda {Collections::HashStack.new})
    test_clear(lambda {Collections::HashStack.new})
    test_pop(lambda {Collections::HashStack.new})
    test_peek(lambda {Collections::HashStack.new})
    test_wave(lambda {Collections::HashStack.new})
  end
end
