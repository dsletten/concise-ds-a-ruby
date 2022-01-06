#!/snap/bin/ruby -w

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
    assert(!queue.enqueue(:foo).empty?, "Queue with elt should not be empty.")
    assert(queue.enqueue(:foo).dequeue.empty?, "Empty queue should be empty.")
  end

  def test_size(constructor)
    #  def test_size(constructor, count=1000)
    count = 1000
    queue = constructor.call
    assert(queue.size.zero?, "Size of new queue should be zero.")
    1.upto(count) do |i|
      queue = queue.enqueue(i)
      assert_equal(i, queue.size, "Size of queue should be #{i}")
    end
  end

  def test_clear(constructor)
    count = 1000
    queue = fill(constructor.call, count)
    assert(!queue.empty?, "Queue should have #{count} elements.")
    assert(queue.clear.empty?, "Queue should be empty.")
  end

  def fill(queue, count)
    1.upto(count) do |i|
      queue = queue.enqueue(i)
    end

    queue
  end

  #
  #    This is identical to test_front in Ruby implementation. No multiple values to return dequeueped value along with new queue...
  #    
  def test_dequeue(constructor)
    count = 1000
    queue = fill(constructor.call, count)

    limit = queue.size
    1.upto(limit) do |i|
      front = queue.front
      assert_equal(i, front, "Value on front of queue should be #{i} not #{front}")
      queue = queue.dequeue
    end
    assert(queue.empty?)
  end

  def test_front(constructor)
    count = 1000
    queue = fill(constructor.call, count)

    limit = queue.size
    1.upto(limit) do |i|
      front = queue.front
      assert_equal(i, front, "Value on front of queue should be #{i} not #{front}")
      queue = queue.dequeue
    end
    assert(queue.empty?)
  end
end

class TestPersistentQueue < TestQueue
  def test_it
    test_constructor(lambda {Collections::PersistentQueue.new})
    test_empty?(lambda {Collections::PersistentQueue.new})
    test_size(lambda {Collections::PersistentQueue.new})
    test_clear(lambda {Collections::PersistentQueue.new})
    test_dequeue(lambda {Collections::PersistentQueue.new})
    test_front(lambda {Collections::PersistentQueue.new})
  end
end

