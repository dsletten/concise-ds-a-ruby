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

module Collections
  class Queue < Dispenser
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

    def empty?
      size.zero?
    end

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

    def empty?
      @store.empty?
    end

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

    def empty?
      size.zero?
    end

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

    def empty?
      size.zero?
    end

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

    def empty?
      @store.empty?
    end

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

    def empty?
      size.zero?
    end

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
        create_queue(reverse(@rear), nil, @count - 1)
      else
        create_queue(@front.rest, @rear, @count - 1)
      end
    end

    def do_front
      @front.first
    end

    def reverse(list)
      do_reverse(list, nil)
    end

    def do_reverse(list, result)
      if list.nil?
        result
      else
        do_reverse(list.rest, Node.new(list.first, result))
      end
    end
  end
end
