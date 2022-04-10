#!/snap/bin/ruby -w

#    File:
#       queue.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       211113 Original.
#
#
#    RingBuffer and RecyclingQueue are kind of pointless.
#    (CircularQueue is also just trivially different from LinkedQueue).
#    

module Containers
  class Queue < Dispenser
    def empty?
      size.zero?
    end

    def clear
      dequeue until empty?
    end
    
    def enqueue(obj)
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)
      do_enqueue(obj)
    end

    def dequeue
      raise StandardError.new("Queue is empty.") if empty?
      do_dequeue
    end

    def front
      raise StandardError.new("Queue is empty.") if empty?
      do_front
    end

    private
    def do_enqueue(obj)
      raise NoMethodError, "#{self.class} does not implement do_enqueue()"
    end

    def do_dequeue
      raise NoMethodError, "#{self.class} does not implement do_dequeue()"
    end

    def do_front
      raise NoMethodError, "#{self.class} does not implement do_front()"
    end
  end

  #
  #    Prosaic array. Assumed to be fixed-length -> manual resize. Queue "wraps around" as long as there is space.
  #    This is traditional `ring buffer`
  #    
  class ArrayQueue < Queue
    ARRAY_QUEUE_CAPACITY = 20
    def initialize(type=Object)
      super(type)
      @store = Array.new(ARRAY_QUEUE_CAPACITY)
      @front = 0
      @count = 0
    end

    def size
      @count
    end

    # def empty?
    #   size.zero?
    # end

    #    This is not good enough. Must release the references to elements. Use superclass method.
    # def clear
    #   @front = 0
    #   @count = 0
    # end

    private
    def do_enqueue(obj)
      if size == @store.size
        resize
      end

      @store[(@front + @count) % @store.size] = obj
      @count += 1
    end

    def do_dequeue
      discard = front
      @store[@front] = nil
      @front = (@front + 1) % @store.size
      @count -= 1
      discard
    end

    def do_front
      @store[@front]
    end

    def resize
      new_store = Array.new(@store.size * 2)
      @count.times do |i|
        new_store[i] = @store[(@front + i) % @store.size]
      end

      @store = new_store
      @front = 0
    end
  end

  #
  #    Another array-based queue, but this relies on built-in Ruby features, namely
  #    push() at end of array and shift() at front of array.
  #    
  class RubyQueue < Queue
    def initialize(type=Object)
      super(type)
      @store = []
    end

    def size
      @store.size
    end

    # def empty?
    #   @store.empty?
    # end

    def clear
      @store = []
    end

    private
    def do_enqueue(obj)
      @store.push(obj)
    end

    def do_dequeue
      @store.shift
    end

    def do_front
      @store[0]
    end
  end

  class LinkedQueue < Queue
    LINKED_QUEUE_CAPACITY = 20
    def initialize(type=Object)
      super(type)
      @front = nil
      @rear = nil
      @count = 0
    end

    def size
      @count
    end

    # def empty?
    #   size.zero?
    # end

    def clear   # Call initialize??
      @front = nil
      @rear = nil
      @count = 0
    end
    
    private
    def do_enqueue(obj)
      node = Node.new(obj, nil)
      if @front.nil?
        raise StandardError.new("Queue is in illegal state.") unless @rear.nil?
        @rear = @front = node
      else
        @rear = @rear.rest = node
      end
      @count += 1
    end

    def do_dequeue
      discard = front

      @front = @front.rest
      if @front.nil?
        @rear = @front
      end

      @count -= 1
      discard
    end

    def do_front
      @front.first
    end
  end

  class LinkedListQueue < Queue
    def initialize(type=Object)
      super(type)
      @list = SinglyLinkedListX.new
    end

    def size
      @list.size
    end

    def clear
      @list.clear
    end
    
    private
    def do_enqueue(obj)
      @list.add(obj)
    end

    def do_dequeue
      @list.delete(0)
    end

    def do_front
      @list.get(0)
    end
  end

  #
  #    See ch. 6 exercise 5
  #
  class CircularQueue < Queue
    def initialize(type=Object)
      super(type)
      @index = nil
      @count = 0
    end

    def size
      @count
    end

    # def empty?
    #   size.zero?
    # end

    def clear   # Call initialize??
      @index = nil
      @count = 0
    end
    
    private
    def do_enqueue(obj)
      node = Node.new(obj, nil)
      if @index.nil?
        @index = node
        @index.rest = node
      else
        node.rest = @index.rest
        @index.rest = node
        @index = node
      end
      @count += 1
    end

    def do_dequeue
      discard = front

      if @index == @index.rest
        @index = nil
      else
        @index.rest = @index.rest.rest
      end

      @count -= 1
      discard
    end

    def do_front
      @index.rest.first
    end
  end

  class RecyclingQueue < LinkedQueue
    def initialize(type=Object)
      super(type)
      @front = Node.empty_list(LINKED_QUEUE_CAPACITY)
      @rear = @front
      @ass = @front.last
    end

    def clear
      dequeue until empty?
    end

    private
    def do_enqueue(obj)
      @rear.first = obj

      if @rear == @ass
        more = Node.empty_list(@count + 1)
        @ass.rest = more
        @ass = more.last
      end

      @rear = @rear.rest
      @count += 1
    end

    def do_dequeue
      discard = front
      @ass.rest = @front
      @ass = @front
      @front = @front.rest
      @ass.first = nil
      @ass.rest = nil
      @count -= 1

      discard
    end
  end

  class RingBuffer < LinkedQueue
    def initialize(type=Object)
      super(type)
      @front = Node.empty_list(LINKED_QUEUE_CAPACITY)
      @rear = @front
      @front.last.rest = @front
    end
      
    def clear
      dequeue until empty?
    end

    private
    def do_enqueue(obj)
      @rear.first = obj
      if @rear.rest == @front
        more = Node.empty_list(@count + 1)
        @rear.rest = more
        more.last.rest = @front
      end

      @rear = @rear.rest
      @count += 1
    end

    def do_dequeue
      discard = @front.first
      @front.first = nil
      @front = @front.rest
      @count -= 1

      discard
    end
  end
  
  class HashQueue < Queue
    def initialize(type=Object)
      super(type)
      @store = {}
      @front = 0
      @rear = 0
    end

    def size
      @store.size
    end

    # def empty?
    #   @store.empty?
    # end

    def clear
      @store = {}
      @front = 0
      @rear = 0
    end

    private
    def do_enqueue(obj)
      @store[@rear] = obj
      @rear += 1
    end

    def do_dequeue
      discard = @store.delete(@front)
      @front += 1
      discard
    end

    def do_front
      @store[@front]
    end
  end

  class PersistentQueue < Queue
    def initialize(type=Object) # Client can only create empty PersistentQueue
      super(type)
      @front = nil
      @rear = nil
      @count = 0
    end

    def size
      @count
    end

    # def empty?
    #   size.zero?
    # end

    def clear
      PersistentQueue.new(@type)
    end
    
    protected
    def create_queue(front, rear, count)
      queue = PersistentQueue.new(@type)
      queue.front = front
      queue.rear = rear
      queue.count = count
      queue
    end
    
    #
    #    Writers only exist to adjust non-empty PersistentQueue after creation.
    #    Constructor only creates empty queues since it is public.
    #    
    def front=(node)
      @front = node
    end

    def rear=(node)
      @rear = node
    end

    def count=(count)
      @count = count
    end

    private
    def do_enqueue(obj)
      if empty?
        create_queue(Node.new(obj, @front), nil, 1)
      else
        create_queue(@front, Node.new(obj, @rear), @count + 1)
      end
    end

    def do_dequeue
      if @front.rest.nil?
        create_queue(Node.reverse(@rear), nil, @count - 1)
      else
        create_queue(@front.rest, @rear, @count - 1)
      end
    end

    def do_front
      @front.first
    end
  end

  class PersistentListQueue < Queue
    @@empty = PersistentList.new
    def initialize(type=Object)
      super(type)
      @list = @@empty
    end

    def size
      @list.size
    end

    def clear
      PersistentListQueue.new(@type)
    end
    
    protected
    #
    #    Writers only exist to adjust non-empty PersistentListQueue after creation.
    #    Constructor only creates empty queues since it is public.
    #    
    def list=(list)
      @list = list
    end

    private
    def create_queue(list)
      queue = PersistentListQueue.new(@type)
      queue.list = list

      queue
    end
    
    def do_enqueue(obj)
      create_queue(@list.add(obj))
    end

    def do_dequeue
      create_queue(@list.delete(0))
    end

    def do_front
      @list.get(0)
    end
  end

  class Deque < Queue
    # def dequeue
    #   raise StandardError.new("Deque is empty.") if empty?
    #   do_dequeue
    # end

    # def front
    #   raise StandardError.new("Deque is empty.") if empty?
    #   do_front
    # end

    def enqueue_front(obj)
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)
      do_enqueue_front(obj)
    end

    def dequeue_rear
      raise StandardError.new("Deque is empty.") if empty?
      do_dequeue_rear
    end

    def rear
      raise StandardError.new("Deque is empty.") if empty?
      do_rear
    end

    private
    def do_enqueue_front(obj)
      raise NoMethodError, "#{self.class} does not implement do_enqueue_front()"
    end

    def do_dequeue_rear
      raise NoMethodError, "#{self.class} does not implement do_dequeue_rear()"
    end

    def do_rear
      raise NoMethodError, "#{self.class} does not implement do_rear()"
    end
  end

  class DllDeque < Deque
    def initialize(type=Object)
      super(type)
      @list = DoublyLinkedList.new(type)
    end
    
    def size
      @list.size
    end

    private
    def do_enqueue(obj)
      @list.add(obj)
    end

    def do_dequeue
      discard = front
      @list.delete(0)
      discard
    end

    def do_enqueue_front(obj)
      @list.insert(0, obj)
    end

    def do_dequeue_rear
      discard = rear
      @list.delete(-1)
      discard
    end
    
    def do_front
      @list.get(0)
    end

    def do_rear
      @list.get(-1)
    end
  end

  class HashDeque < Deque
    def initialize(type=Object)
      super(type)
      @store = {}
      @front = 0
      @rear = 0
    end
    
    def size
      @store.size
    end

    def clear
      @store = {}
      @front = 0
      @rear = 0
    end

    private
    def do_enqueue(obj)
      @rear += 1 unless empty?
      @store[@rear] = obj
    end

    def do_dequeue
      discard = @store.delete(@front)
      @front += 1 unless empty?
      discard
    end

    def do_enqueue_front(obj)
      @front -= 1 unless empty?
      @store[@front] = obj
    end

    def do_dequeue_rear
      discard = @store.delete(@rear)
      @rear -= 1 unless empty?
      discard
    end
    
    def do_front
      @store[@front]
    end

    def do_rear
      @store[@rear]
    end
  end

  class PersistentDeque < Deque
    def initialize(type=Object)
      super(type)
      @front = nil
      @rear = nil
      @count = 0
    end

    def size
      @count
    end

    def clear
      PersistentDeque.new(@type)
    end

    protected
    def initialize_deque(front, rear, count)
      dq = PersistentDeque.new(@type)
      dq.front = front
      dq.rear = rear
      dq.count = count

      dq
    end

    def front=(node)
      @front = node
    end

    def rear=(node)
      @rear = node
    end

    def count=(count)
      @count = count
    end
    
    private
    def do_enqueue(obj)
      if empty?
        initialize_deque(Node.new(obj, nil), Node.new(obj, nil), 1)
      else
        initialize_deque(@front, Node.new(obj, @rear), @count + 1)
      end
    end

    def do_dequeue
      if @front.rest.nil?
        if @rear.rest.nil?
          clear
        else
          initialize_deque(Node.reverse(@rear).rest, Node.new(@rear, nil), @count - 1)
        end
      else
        initialize_deque(@front.rest, @rear, @count - 1)
      end
    end

    def do_enqueue_front(obj)
      if empty?
        initialize_deque(Node.new(obj, nil), Node.new(obj, nil), 1)
      else
        initialize_deque(Node.new(obj, @front), @rear, @count + 1)
      end
    end

    def do_dequeue_rear
      if @rear.rest.nil?
        if @front.rest.nil?
          clear
        else
          initialize_deque(Node.new(@front, nil), Node.reverse(@front).rest, @count - 1)
        end
      else
        initialize_deque(@front, @rear.rest, @count - 1)
      end
    end
    
    def do_front
      @front.first
    end

    def do_rear
      @rear.first
    end
  end
end
