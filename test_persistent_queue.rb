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
    assert(!queue.enqueue(:foo).empty?, "Queue with elt should not be empty.")
    assert(queue.enqueue(:foo).dequeue.empty?, "Empty queue should be empty.")
  end

  def test_deque_empty?(constructor)
    deque = constructor.call
    assert(deque.empty?, "New deque should be empty.")
    assert(!deque.enqueue_front(:foo).empty?, "Deque with elt should not be empty.")
    assert(deque.enqueue_front(:foo).dequeue_rear.empty?, "Empty deque should be empty.")
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
  end

  def test_clear(constructor)
    count = 1000
    queue = fill(constructor.call, count)
    assert(!queue.empty?, "Queue should have #{count} elements.")
    assert(queue.clear.empty?, "Queue should be empty.")
    assert_queue_size(queue.clear, 0)
  end

  def fill(queue, count)
    1.upto(count) do |i|
      queue = queue.enqueue(i)
    end

    queue
  end

  #
  #    This is identical to test_front in Ruby implementation. No multiple values to return dequeued value along with new queue...
  #    
  # def test_dequeue(constructor)
  #   count = 1000
  #   queue = fill(constructor.call, count)

  #   limit = queue.size
  #   1.upto(limit) do |i|
  #     front = queue.front
  #     assert_equal(i, front, "Value on front of queue should be #{i} not #{front}")
  #     queue = queue.dequeue
  #   end
  #   assert(queue.empty?)
  # end

  def test_front(constructor)
    count = 1000
    queue = fill(constructor.call, count)

    1.upto(count) do |i|
      front = queue.front
      assert_equal(i, front, "Value on front of queue should be #{i} not #{front}")
      queue = queue.dequeue
    end
    assert(queue.empty?)
  end

  def test_rear(constructor)
    count = 1000
    deque = fill(constructor.call, count)

    count.downto(1) do |i|
      rear = deque.rear
      assert_equal(i, rear, "Value on rear of deque should be #{i} not #{rear}")
      deque = deque.dequeue_rear
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
          new_queue = fill(queue, count)
          until new_queue.empty?
            new_queue = new_queue.dequeue
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
          new_deque = deque
          count.times do |j|
            new_deque = new_deque.enqueue_front(j)
          end
          until new_deque.empty?
            new_deque = new_deque.dequeue_rear
          end
        end
      end
    end
  end
end

class TestPersistentQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::PersistentQueue.new})
    test_empty?(lambda {Containers::PersistentQueue.new})
    test_size(lambda {Containers::PersistentQueue.new})
    test_clear(lambda {Containers::PersistentQueue.new})
#    test_dequeue(lambda {Containers::PersistentQueue.new})
    test_front(lambda {Containers::PersistentQueue.new})
    test_time(lambda {Containers::PersistentQueue.new})
  end
end

class TestPersistentListQueue < TestQueue
  def test_it
    test_constructor(lambda {Containers::PersistentListQueue.new})
    test_empty?(lambda {Containers::PersistentListQueue.new})
    test_size(lambda {Containers::PersistentListQueue.new})
    test_clear(lambda {Containers::PersistentListQueue.new})
#    test_dequeue(lambda {Containers::PersistentListQueue.new})
    test_front(lambda {Containers::PersistentListQueue.new})
    test_time(lambda {Containers::PersistentListQueue.new})
  end
end

class TestPersistentDeque < TestQueue
  def test_it
    test_constructor(lambda {Containers::PersistentDeque.new})
    test_deque_constructor(lambda {Containers::PersistentDeque.new})
    test_empty?(lambda {Containers::PersistentDeque.new})
    test_deque_empty?(lambda {Containers::PersistentDeque.new})
    test_size(lambda {Containers::PersistentDeque.new})
    test_deque_size(lambda {Containers::PersistentDeque.new})
    test_clear(lambda {Containers::PersistentDeque.new})
#    test_dequeue(lambda {Containers::PersistentDeque.new})
    test_front(lambda {Containers::PersistentDeque.new})
    test_rear(lambda {Containers::PersistentDeque.new})
    test_time(lambda {Containers::PersistentDeque.new})
    test_deque_time(lambda {Containers::PersistentDeque.new})
  end
end

class TestPersistentListDeque < TestQueue
  def test_it
    test_constructor(lambda {Containers::PersistentListDeque.new})
    test_deque_constructor(lambda {Containers::PersistentListDeque.new})
    test_empty?(lambda {Containers::PersistentListDeque.new})
    test_deque_empty?(lambda {Containers::PersistentListDeque.new})
    test_size(lambda {Containers::PersistentListDeque.new})
    test_deque_size(lambda {Containers::PersistentListDeque.new})
    test_clear(lambda {Containers::PersistentListDeque.new})
#    test_dequeue(lambda {Containers::PersistentListDeque.new})
    test_front(lambda {Containers::PersistentListDeque.new})
    test_rear(lambda {Containers::PersistentListDeque.new})
    test_time(lambda {Containers::PersistentListDeque.new})
    test_deque_time(lambda {Containers::PersistentListDeque.new})
  end
end
