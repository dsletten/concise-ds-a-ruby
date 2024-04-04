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

    (count-1).downto(0) do |i|
      queue.dequeue
      assert_queue_size(queue, i)
    end

    assert(queue.empty?, "Empty queue should be empty.")
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

    (count-1).downto(0) do |i|
      deque.dequeue_rear
      assert_queue_size(deque, i)
    end

    assert(deque.empty?, "Empty deque should be empty.")
  end

  def test_clear(constructor)
    count = 1000
    queue = constructor.call.fill(count:  count)

    assert(!queue.empty?, "Queue should have #{count} elements.")

    queue.clear
    assert(queue.empty?, "Queue should be empty.")
    assert_queue_size(queue, 0)

    queue.fill(count: count)
    assert(!queue.empty?, "Emptying queue should not break it.")
  end

  def test_elements(constructor)
    count = 1000
    queue = constructor.call.fill(count: count)
    expected = (1..count).to_a
    elts = queue.elements

    assert(expected == elts, "FIFO elements should be #{expected[0, 10]} not #{elts[0, 10]}")
    assert(queue.empty?, "Mutable queue should be empty after elements are extracted.")
  end
    
  def test_enqueue(constructor)
    count = 1000
    queue = constructor.call

    1.upto(count) do |i|
      queue.enqueue(i)
      dequeued = queue.dequeue
      assert_equal(i, dequeued, "Wrong value enqueued: #{dequeued} should be: #{i}")
    end
  end

  def test_enqueue_wrong_type(constructor)
    queue = constructor.call(type: Integer)

    assert_raises(ArgumentError, "Can't enqueue() value of wrong type onto queue.") { queue.enqueue(1.0) }
  end

  def test_enqueue_front(constructor)
    count = 1000
    deque = constructor.call

    1.upto(count) do |i|
      deque.enqueue_front(i)
      dequeued = deque.dequeue_rear
      assert_equal(i, dequeued, "Wrong value enqueued: #{dequeued} should be: #{i}")
    end
  end

  def test_enqueue_front_wrong_type(constructor)
    deque = constructor.call(type: Integer)

    assert_raises(ArgumentError, "Can't enqueue_front() value of wrong type onto deque.") { deque.enqueue_front(1.0) }
  end

  def test_front_dequeue(constructor)
    count = 1000
    queue = constructor.call.fill(count:  count)

    queue.size.times do
      front = queue.front
      dequeued = queue.dequeue
      assert_equal(front, dequeued, "Value on front of queue should be #{front} not #{dequeued}")
    end

    assert(queue.empty?)
  end
    
  def test_rear_dequeue_rear(constructor)
    count = 1000
    deque = constructor.call.fill(count:  count)

    deque.size.times do
      rear = deque.rear
      dequeued = deque.dequeue_rear
      assert_equal(rear, dequeued, "Value on rear of deque should be #{rear} not #{dequeued}")
    end

    assert(deque.empty?)
  end
    
  def test_queue_time(constructor)
    count = 100000
    queue = constructor.call
    
    Benchmark.bm do |run|
      run.report("Timing #{queue.class}") do 
        10.times do
          queue.fill(count:  count)
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

    Benchmark.bm do |run|
      run.report("Test wave") do 
        queue.fill(count:  5000)
        assert_queue_size(queue, 5000)

        3000.times { queue.dequeue }
        assert_queue_size(queue, 2000)
        
        queue.fill(count:  5000)
        assert_queue_size(queue, 7000)

        3000.times { queue.dequeue }
        assert_queue_size(queue, 4000)

        queue.fill(count:  5000)
        assert_queue_size(queue, 9000)

        3000.times { queue.dequeue }
        assert_queue_size(queue, 6000)

        queue.fill(count:  4000)
        assert_queue_size(queue, 10000)

        10000.times { queue.dequeue }
        assert(queue.empty?, "Queue should be empty.")
      end
    end
  end
end

def queue_test_suite(tester, constructor)
  puts("Testing #{constructor.call.class}")
  tester.test_constructor(constructor)
  tester.test_queue_empty?(constructor)
  tester.test_queue_size(constructor)
  tester.test_clear(constructor)
  tester.test_elements(constructor)
  tester.test_enqueue(constructor)
  tester.test_enqueue_wrong_type(constructor)
  tester.test_front_dequeue(constructor)
  tester.test_queue_time(constructor)
  tester.test_wave(constructor)
end

def deque_test_suite(tester, constructor)
  queue_test_suite(tester, constructor)

  tester.test_deque_constructor(constructor)
  tester.test_deque_empty?(constructor)
  tester.test_deque_size(constructor)
  tester.test_enqueue_front(constructor)
  tester.test_enqueue_front_wrong_type(constructor)
  tester.test_rear_dequeue_rear(constructor)
  tester.test_deque_time(constructor)
end

class TestArrayRingBuffer < TestQueue
  def test_it
    queue_test_suite(self, lambda {|type: Object| Containers::ArrayRingBuffer.new(type: type)})
  end
end

class TestRubyQueue < TestQueue
  def test_it
    queue_test_suite(self, lambda {|type: Object| Containers::RubyQueue.new(type: type)})
  end
end

class TestLinkedQueue < TestQueue
  def test_it
    queue_test_suite(self, lambda {|type: Object| Containers::LinkedQueue.new(type: type)})
  end
end

class TestLinkedListQueue < TestQueue
  def test_it
    queue_test_suite(self, lambda {|type: Object| Containers::LinkedListQueue.new(type: type)})
  end
end

class TestDllQueue < TestQueue
  def test_it
    queue_test_suite(self, lambda {|type: Object| Containers::DllQueue.new(type: type)})
  end
end

class TestCircularQueue < TestQueue
  def test_it
    queue_test_suite(self, lambda {|type: Object| Containers::CircularQueue.new(type: type)})
  end
end

class TestRecyclingQueue < TestQueue
  def test_it
    queue_test_suite(self, lambda {|type: Object| Containers::RecyclingQueue.new(type: type)})
  end
end

class TestLinkedRingBuffer < TestQueue
  def test_it
    queue_test_suite(self, lambda {|type: Object| Containers::LinkedRingBuffer.new(type: type)})
  end
end

class TestHashQueue < TestQueue
  def test_it
    queue_test_suite(self, lambda {|type: Object| Containers::HashQueue.new(type: type)})
  end
end

class TestArrayRingBufferDeque < TestQueue
  def test_it
    deque_test_suite(self, lambda {|type: Object| Containers::ArrayRingBufferDeque.new(type: type)})
  end
end

class TestArrayRingBufferDequeX < TestQueue
  def test_it
    deque_test_suite(self, lambda {|type: Object| Containers::ArrayRingBufferDequeX.new(type: type)})
  end
end

class TestDllDeque < TestQueue
  def test_it
    deque_test_suite(self, lambda {|type: Object| Containers::DllDeque.new(type: type)})
  end
end

class TestHashDeque < TestQueue
  def test_it
    deque_test_suite(self, lambda {|type: Object| Containers::HashDeque.new(type: type)})
  end
end
