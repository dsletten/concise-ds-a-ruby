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
require './list'
require './queue'
require 'test/unit'
require 'benchmark'

class TestQueue < Test::Unit::TestCase
  def test_constructor(constructor)
    queue = constructor.call
    assert(queue.empty?, "New queue should be empty.")
    assert(queue.size.zero?, "Size of new queue should be zero.")
    assert_raises(StandardError, "Can't call front() on empty queue.") { queue.front }
    assert_raises(StandardError, "Can't call dequeue() on empty queue.") { queue.dequeue }
  end

  def test_deque_constructor(constructor)
    deque = constructor.call
    assert(deque.empty?, "New deque should be empty.")
    assert(deque.size.zero?, "Size of new deque should be zero.")
    assert_raises(StandardError, "Can't call rear() on empty deque.") { deque.rear }
    assert_raises(StandardError, "Can't call dequeue_rear() on empty deque.") { deque.dequeue_rear }
  end

  def test_queue_empty?(constructor)
    queue = constructor.call
    assert(queue.empty?, "New queue should be empty.")
    queue.enqueue(:foo)
    assert(!queue.empty?, "Queue with elt should not be empty.")
    queue.dequeue
    assert(queue.empty?, "Empty queue should be empty.")
  end

  def test_deque_empty?(constructor)
    deque = constructor.call
    assert(deque.empty?, "New deque should be empty.")
    deque.enqueue_front(:foo)
    assert(!deque.empty?, "Deque with elt should not be empty.")
    deque.dequeue_rear
    assert(deque.empty?, "Empty deque should be empty.")
  end

  def test_queue_size(constructor)
    count = 1000
    queue = constructor.call
    assert(queue.size.zero?, "Size of new queue should be zero.")
    1.upto(count) do |i|
      queue.enqueue(i)
      assert_queue_size(queue, i)
    end
  end

  def assert_queue_size(queue, n)
      assert_equal(n, queue.size, "Size of queue should be #{n}")
  end    

  def test_deque_size(constructor)
    count = 1000
    deque = constructor.call
    assert(deque.size.zero?, "Size of new deque should be zero.")
    1.upto(count) do |i|
      deque.enqueue_front(i)
      assert_queue_size(deque, i)
    end
  end

  def test_clear(constructor)
    count = 1000
    queue = fill(constructor.call, count)
    assert(!queue.empty?, "Queue should have #{count} elements.")
    queue.clear
    assert(queue.empty?, "Queue should be empty.")
    assert_queue_size(queue, 0)
    fill(queue, count)
    assert(!queue.empty?, "Emptying queue should not break it.")
  end

  # def fill(queue, count)
  #   1.upto(count) do |i|
  #     queue.enqueue(i)
  #   end

  #   queue
  # end

  def test_dequeue(constructor)
    count = 1000
    queue = fill(constructor.call, count)

    1.upto(queue.size) do |i|
      dequeued = queue.dequeue
      assert_equal(i, dequeued, "Value on front of queue should be #{i} not #{dequeued}")
    end
    assert(queue.empty?)
  end
    
  def test_front(constructor)
    count = 1000
    queue = fill(constructor.call, count)

    1.upto(queue.size) do |i|
      front = queue.front
      assert_equal(i, front, "Value on front of queue should be #{i} not #{front}")
      queue.dequeue
    end
    assert(queue.empty?)
  end
    
  def test_dequeue_rear(constructor)
    count = 1000
    deque = fill(constructor.call, count)

    deque.size.downto(1) do |i|
      dequeued = deque.dequeue_rear
      assert_equal(i, dequeued, "Value on rear of deque should be #{i} not #{dequeued}")
    end
    assert(deque.empty?)
  end
    
  def test_rear(constructor)
    count = 1000
    deque = fill(constructor.call, count)

    deque.size.downto(1) do |i|
      rear = deque.rear
      assert_equal(i, rear, "Value on rear of deque should be #{i} not #{rear}")
      deque.dequeue_rear
    end
    assert(deque.empty?)
  end
    
  def test_queue_time(constructor)
    count = 100000
    queue = constructor.call
    
    Benchmark.bm do |run|
      run.report("Timing #{queue.class}") do 
        10.times do
          fill(queue, count)
          until queue.empty?
            queue.dequeue
          end
        end
      end
    end
  end

  def test_deque_time(constructor)
    count = 100000
    deque = constructor.call
    
    Benchmark.bm do |run|
      run.report("Timing #{deque.class}") do 
        10.times do
          count.times do |j|
            deque.enqueue_front(j)
          end
          until deque.empty?
            deque.dequeue_rear
          end
        end
      end
    end
  end

  def test_wave(constructor)
    queue = constructor.call
    fill(queue, 5000)
    assert_queue_size(queue, 5000)

    3000.times { queue.dequeue }
    assert_queue_size(queue, 2000)
    
    fill(queue, 5000)
    assert_queue_size(queue, 7000)

    3000.times { queue.dequeue }
    assert_queue_size(queue, 4000)

    fill(queue, 5000)
    assert_queue_size(queue, 9000)

    3000.times { queue.dequeue }
    assert_queue_size(queue, 6000)

    fill(queue, 4000)
    assert_queue_size(queue, 10000)

    10000.times { queue.dequeue }
    assert(queue.empty?, "Queue should be empty.")
  end
end

class TestArrayQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::ArrayQueue.new})
    test_queue_empty?(lambda {Containers::ArrayQueue.new})
    test_queue_size(lambda {Containers::ArrayQueue.new})
    test_clear(lambda {Containers::ArrayQueue.new})
    test_dequeue(lambda {Containers::ArrayQueue.new})
    test_front(lambda {Containers::ArrayQueue.new})
    test_queue_time(lambda {Containers::ArrayQueue.new})
    test_wave(lambda {Containers::ArrayQueue.new})
  end
end

class TestRubyQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::RubyQueue.new})
    test_queue_empty?(lambda {Containers::RubyQueue.new})
    test_queue_size(lambda {Containers::RubyQueue.new})
    test_clear(lambda {Containers::RubyQueue.new})
    test_dequeue(lambda {Containers::RubyQueue.new})
    test_front(lambda {Containers::RubyQueue.new})
    test_queue_time(lambda {Containers::RubyQueue.new})
    test_wave(lambda {Containers::RubyQueue.new})
  end
end

class TestLinkedQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::LinkedQueue.new})
    test_queue_empty?(lambda {Containers::LinkedQueue.new})
    test_queue_size(lambda {Containers::LinkedQueue.new})
    test_clear(lambda {Containers::LinkedQueue.new})
    test_dequeue(lambda {Containers::LinkedQueue.new})
    test_front(lambda {Containers::LinkedQueue.new})
    test_queue_time(lambda {Containers::LinkedQueue.new})
    test_wave(lambda {Containers::LinkedQueue.new})
  end
end

class TestLinkedListQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::LinkedListQueue.new})
    test_queue_empty?(lambda {Containers::LinkedListQueue.new})
    test_queue_size(lambda {Containers::LinkedListQueue.new})
    test_clear(lambda {Containers::LinkedListQueue.new})
    test_dequeue(lambda {Containers::LinkedListQueue.new})
    test_front(lambda {Containers::LinkedListQueue.new})
    test_queue_time(lambda {Containers::LinkedListQueue.new})
    test_wave(lambda {Containers::LinkedListQueue.new})
  end
end

class TestCircularQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::CircularQueue.new})
    test_queue_empty?(lambda {Containers::CircularQueue.new})
    test_queue_size(lambda {Containers::CircularQueue.new})
    test_clear(lambda {Containers::CircularQueue.new})
    test_dequeue(lambda {Containers::CircularQueue.new})
    test_front(lambda {Containers::CircularQueue.new})
    test_queue_time(lambda {Containers::CircularQueue.new})
    test_wave(lambda {Containers::CircularQueue.new})
  end
end

class TestRecyclingQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::RecyclingQueue.new})
    test_queue_empty?(lambda {Containers::RecyclingQueue.new})
    test_queue_size(lambda {Containers::RecyclingQueue.new})
    test_clear(lambda {Containers::RecyclingQueue.new})
    test_dequeue(lambda {Containers::RecyclingQueue.new})
    test_front(lambda {Containers::RecyclingQueue.new})
    test_queue_time(lambda {Containers::RecyclingQueue.new})
    test_wave(lambda {Containers::RecyclingQueue.new})
  end
end

class TestRingBuffer < TestQueue
  def test_it
    test_constructor(lambda {Containers::RingBuffer.new})
    test_queue_empty?(lambda {Containers::RingBuffer.new})
    test_queue_size(lambda {Containers::RingBuffer.new})
    test_clear(lambda {Containers::RingBuffer.new})
    test_dequeue(lambda {Containers::RingBuffer.new})
    test_front(lambda {Containers::RingBuffer.new})
    test_queue_time(lambda {Containers::RingBuffer.new})
    test_wave(lambda {Containers::RingBuffer.new})
  end
end

class TestHashQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::HashQueue.new})
    test_queue_empty?(lambda {Containers::HashQueue.new})
    test_queue_size(lambda {Containers::HashQueue.new})
    test_clear(lambda {Containers::HashQueue.new})
    test_dequeue(lambda {Containers::HashQueue.new})
    test_front(lambda {Containers::HashQueue.new})
    test_queue_time(lambda {Containers::HashQueue.new})
    test_wave(lambda {Containers::HashQueue.new})
  end
end

class TestDllDeque < TestQueue
  def test_it
    test_constructor(lambda {Containers::DllDeque.new})
    test_deque_constructor(lambda {Containers::DllDeque.new})
    test_queue_empty?(lambda {Containers::DllDeque.new})
    test_deque_empty?(lambda {Containers::DllDeque.new})
    test_queue_size(lambda {Containers::DllDeque.new})
    test_deque_size(lambda {Containers::DllDeque.new})
    test_clear(lambda {Containers::DllDeque.new})
    test_dequeue(lambda {Containers::DllDeque.new})
    test_front(lambda {Containers::DllDeque.new})
    test_dequeue_rear(lambda {Containers::DllDeque.new})
    test_rear(lambda {Containers::DllDeque.new})
    test_queue_time(lambda {Containers::DllDeque.new})
    test_deque_time(lambda {Containers::DllDeque.new})
    test_wave(lambda {Containers::DllDeque.new})
  end
end

class TestHashDeque < TestQueue
  def test_it
    test_constructor(lambda {Containers::HashDeque.new})
    test_deque_constructor(lambda {Containers::HashDeque.new})
    test_queue_empty?(lambda {Containers::HashDeque.new})
    test_deque_empty?(lambda {Containers::HashDeque.new})
    test_queue_size(lambda {Containers::HashDeque.new})
    test_deque_size(lambda {Containers::HashDeque.new})
    test_clear(lambda {Containers::HashDeque.new})
    test_dequeue(lambda {Containers::HashDeque.new})
    test_front(lambda {Containers::HashDeque.new})
    test_dequeue_rear(lambda {Containers::HashDeque.new})
    test_rear(lambda {Containers::HashDeque.new})
    test_queue_time(lambda {Containers::HashDeque.new})
    test_deque_time(lambda {Containers::HashDeque.new})
    test_wave(lambda {Containers::HashDeque.new})
  end
end
