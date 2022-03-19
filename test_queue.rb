#!/usr/bin/ruby -w

#    File:
#       test_queue.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210322 Original.

require './containers'
require './queue'
require 'test/unit'

class TestQueue < Test::Unit::TestCase
  def test_constructor(constructor)
    queue = constructor.call
    assert(queue.empty?, "New queue should be empty.")
    assert(queue.size.zero?, "Size of new queue should be zero.")
    assert_raises(StandardError, "Can't call front() on empty queue.") { queue.front }
    assert_raises(StandardError, "Can't call dequeue() on empty queue.") { queue.dequeue }
  end

  def test_empty?(constructor)
    queue = constructor.call
    assert(queue.empty?, "New queue should be empty.")
    queue.enqueue(:foo)
    assert(!queue.empty?, "Queue with elt should not be empty.")
    queue.dequeue
    assert(queue.empty?, "Empty queue should be empty.")
  end

  def test_size(constructor)
    count = 1000
    queue = constructor.call
    assert(queue.size.zero?, "Size of new queue should be zero.")
    1.upto(count) do |i|
      queue.enqueue(i)
      assert_equal(i, queue.size, "Size of queue should be #{i}")
    end
  end

  def test_clear(constructor)
    count = 1000
    queue = constructor.call
    fill(queue, count)
    assert(!queue.empty?, "Queue should have #{count} elements.")
    queue.clear
    assert(queue.empty?, "Queue should be empty.")
  end

  def fill(queue, count)
    1.upto(count) do |i|
      queue.enqueue(i)
    end
  end

  def test_dequeue(constructor)
    count = 1000
    queue = constructor.call
    fill(queue, count)

    limit = queue.size
    1.upto(limit) do |i|
      dequeued = queue.dequeue
      assert_equal(i, dequeued, "Value on front of queue should be #{i} not #{dequeued}")
    end
    assert(queue.empty?)
  end
    
  def test_front(constructor)
    count = 1000
    queue = constructor.call
    fill(queue, count)

    limit = queue.size
    1.upto(limit) do |i|
      front = queue.front
      assert_equal(i, front, "Value on front of queue should be #{i} not #{front}")
      queue.dequeue
    end
    assert(queue.empty?)
  end
    
  def test_wave(constructor)
    queue = constructor.call
    fill(queue, 5000)
    assert_equal(5000, queue.size, "Size of queue should be 5000")
    3000.times { queue.dequeue }
    assert_equal(2000, queue.size, "Size of queue should be 2000")
    
    fill(queue, 5000)
    assert_equal(7000, queue.size, "Size of queue should be 7000")
    3000.times { queue.dequeue }
    assert_equal(4000, queue.size, "Size of queue should be 4000")

    fill(queue, 5000)
    assert_equal(9000, queue.size, "Size of queue should be 9000")
    3000.times { queue.dequeue }
    assert_equal(6000, queue.size, "Size of queue should be 6000")

    fill(queue, 4000)
    assert_equal(10000, queue.size, "Size of queue should be 10000")
    10000.times { queue.dequeue }
    assert(queue.empty?, "Queue should be empty.")
  end
end

class TestLinkedQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::LinkedQueue.new})
    test_empty?(lambda {Containers::LinkedQueue.new})
    test_size(lambda {Containers::LinkedQueue.new})
    test_clear(lambda {Containers::LinkedQueue.new})
    test_dequeue(lambda {Containers::LinkedQueue.new})
    test_front(lambda {Containers::LinkedQueue.new})
    test_wave(lambda {Containers::LinkedQueue.new})
  end
end

class TestCircularQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::CircularQueue.new})
    test_empty?(lambda {Containers::CircularQueue.new})
    test_size(lambda {Containers::CircularQueue.new})
    test_clear(lambda {Containers::CircularQueue.new})
    test_dequeue(lambda {Containers::CircularQueue.new})
    test_front(lambda {Containers::CircularQueue.new})
    test_wave(lambda {Containers::CircularQueue.new})
  end
end

class TestRecyclingQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::RecyclingQueue.new})
    test_empty?(lambda {Containers::RecyclingQueue.new})
    test_size(lambda {Containers::RecyclingQueue.new})
    test_clear(lambda {Containers::RecyclingQueue.new})
    test_dequeue(lambda {Containers::RecyclingQueue.new})
    test_front(lambda {Containers::RecyclingQueue.new})
    test_wave(lambda {Containers::RecyclingQueue.new})
  end
end

class TestRingBuffer < TestQueue
  def test_it
    test_constructor(lambda {Containers::RingBuffer.new})
    test_empty?(lambda {Containers::RingBuffer.new})
    test_size(lambda {Containers::RingBuffer.new})
    test_clear(lambda {Containers::RingBuffer.new})
    test_dequeue(lambda {Containers::RingBuffer.new})
    test_front(lambda {Containers::RingBuffer.new})
    test_wave(lambda {Containers::RingBuffer.new})
  end
end

class TestRubyQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::RubyQueue.new})
    test_empty?(lambda {Containers::RubyQueue.new})
    test_size(lambda {Containers::RubyQueue.new})
    test_clear(lambda {Containers::RubyQueue.new})
    test_dequeue(lambda {Containers::RubyQueue.new})
    test_front(lambda {Containers::RubyQueue.new})
    test_wave(lambda {Containers::RubyQueue.new})
  end
end

class TestArrayQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::ArrayQueue.new})
    test_empty?(lambda {Containers::ArrayQueue.new})
    test_size(lambda {Containers::ArrayQueue.new})
    test_clear(lambda {Containers::ArrayQueue.new})
    test_dequeue(lambda {Containers::ArrayQueue.new})
    test_front(lambda {Containers::ArrayQueue.new})
    test_wave(lambda {Containers::ArrayQueue.new})
  end
end

class TestHashQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::HashQueue.new})
    test_empty?(lambda {Containers::HashQueue.new})
    test_size(lambda {Containers::HashQueue.new})
    test_clear(lambda {Containers::HashQueue.new})
    test_dequeue(lambda {Containers::HashQueue.new})
    test_front(lambda {Containers::HashQueue.new})
    test_wave(lambda {Containers::HashQueue.new})
  end
end
