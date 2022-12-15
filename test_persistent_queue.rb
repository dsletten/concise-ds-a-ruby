#!/usr/bin/ruby -w

#    File:
#       test_persistent_queue.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210329 Original.

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

  def test_empty?(constructor)
    queue = constructor.call
    assert(queue.empty?, "New queue should be empty.")

    queue = queue.enqueue(:foo)
    assert(!queue.empty?, "Queue with elt should not be empty.")

    queue = queue.dequeue
    assert(queue.empty?, "Empty queue should be empty.")
  end

  def test_deque_empty?(constructor)
    deque = constructor.call
    assert(deque.empty?, "New deque should be empty.")

    deque = deque.enqueue_front(:foo)
    assert(!deque.empty?, "Deque with elt should not be empty.")

    deque = deque.dequeue_rear
    assert(deque.empty?, "Empty deque should be empty.")
  end

  def test_size(constructor)
    #  def test_size(constructor, count=1000)
    count = 1000
    queue = constructor.call
    assert(queue.size.zero?, "Size of new queue should be zero.")

    1.upto(count) do |i|
      queue = queue.enqueue(i)
      assert_queue_size(queue, i)
    end

    (count-1).downto(0) do |i|
      queue = queue.dequeue
      assert_queue_size(queue, i)
    end

    assert(queue.empty?, "Empty queue should be empty.")
  end

  def assert_queue_size(queue, n)
      assert_equal(n, queue.size, "Size of queue should be #{n}")
  end    

  def test_deque_size(constructor)
    #  def test_deque_size(constructor, count=1000)
    count = 1000
    deque = constructor.call
    assert(deque.size.zero?, "Size of new deque should be zero.")

    1.upto(count) do |i|
      deque = deque.enqueue_front(i)
      assert_queue_size(deque, i)
    end

    (count-1).downto(0) do |i|
      deque = deque.dequeue_rear
      assert_queue_size(deque, i)
    end

    assert(deque.empty?, "Empty deque should be empty.")
  end

  def test_clear(constructor)
    count = 1000
    queue = constructor.call.fill(count: count)

    assert(!queue.empty?, "Queue should have #{count} elements.")

    queue = queue.clear
    assert(queue.empty?, "Queue should be empty.")
    assert_queue_size(queue, 0)

    queue = queue.fill(count: count)
    assert(!queue.empty?, "Emptying queue should not break it.")
  end

  def test_elements(constructor)
    count = 1000
    queue = constructor.call.fill(count: count)
    expected = (1..count).to_a
    elts = queue.elements

    assert(expected == elts, "FIFO elements should be #{expected[0, 10]} not #{elts[0, 10]}")
  end
    
  def test_enqueue(constructor)
    count = 1000
    queue = constructor.call

    1.upto(count) do |i|
      dequeued = queue.enqueue(i).front
      assert_equal(i, dequeued, "Wrong value enqueueed: #{dequeued} should be: #{i}")
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
      dequeued = deque.enqueue_front(i).rear
      assert_equal(i, dequeued, "Wrong value enqueued at front: #{dequeued} should be: #{i}")
    end
  end

  def test_enqueue_front_wrong_type(constructor)
    deque = constructor.call(type: Integer)

    assert_raises(ArgumentError, "Can't enqueue_front() value of wrong type onto deque.") { deque.enqueue_front(1.0) }
  end

  def test_front_dequeue(constructor)
    count = 1000
    queue = constructor.call.fill(count: count)

    1.upto(count) do |i|
      front = queue.front
      assert_equal(i, front, "Wrong value dequeued: #{front} should be: #{i}")
      queue = queue.dequeue
    end

    assert(queue.empty?)
  end

  def test_rear_dequeue_rear(constructor)
    count = 1000
    deque = constructor.call.fill(count: count)

    count.downto(1) do |i|
      rear = deque.rear
      deque = deque.dequeue_rear
      assert_equal(rear, i, "Wrong value dequeued from rear: #{rear} should be: #{i}")
    end
    assert(deque.empty?)
  end

  def test_time(constructor)
#    count = 100000
    count = 1000
    queue = constructor.call
    
    Benchmark.bm do |run|
      run.report("Timing #{queue.class}") do 
        10.times do
          queue = queue.fill(count: count)

          until queue.empty?
            queue = queue.dequeue
          end
        end
      end
    end
  end

  def test_deque_time(constructor)
#    count = 100000
    count = 1000
    deque = constructor.call
    
    Benchmark.bm do |run|
      run.report("Timing #{deque.class}") do 
        10.times do
          count.times do |j|
            deque = deque.enqueue_front(j)
          end

          until deque.empty?
            deque = deque.dequeue_rear
          end
        end
      end
    end
  end
end

def persistent_queue_test_suite(tester, constructor)
  puts("Testing #{constructor.call.class}")
  tester.test_constructor(constructor)
  tester.test_empty?(constructor)
  tester.test_size(constructor)
  tester.test_clear(constructor)
  tester.test_elements(constructor)
  tester.test_enqueue(constructor)
  tester.test_enqueue_wrong_type(constructor)
  tester.test_front_dequeue(constructor)
  tester.test_time(constructor)
end

def persistent_deque_test_suite(tester, constructor)
  persistent_queue_test_suite(tester, constructor)
  
  tester.test_deque_constructor(constructor)
  tester.test_deque_empty?(constructor)
  tester.test_deque_size(constructor)
  tester.test_enqueue_front(constructor)
  tester.test_enqueue_front_wrong_type(constructor)
  tester.test_rear_dequeue_rear(constructor)
  tester.test_deque_time(constructor)
end

class TestPersistentLinkedQueue < TestQueue
  def test_it
    persistent_queue_test_suite(self, lambda {|type: Object| Containers::PersistentLinkedQueue.new(type: type)})
  end
end

class TestPersistentListQueue < TestQueue
  def test_it
    persistent_queue_test_suite(self, lambda {|type: Object| Containers::PersistentListQueue.new(type: type)})
  end
end

class TestPersistentLinkedDeque < TestQueue
  def test_it
    persistent_deque_test_suite(self, lambda {|type: Object| Containers::PersistentLinkedDeque.new(type: type)})
  end
end

class TestPersistentListDeque < TestQueue
  def test_it
    persistent_deque_test_suite(self, lambda {|type: Object| Containers::PersistentListDeque.new(type: type)})
  end
end
