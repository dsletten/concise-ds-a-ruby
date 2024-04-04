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
#    LinkedRingBuffer and RecyclingQueue are kind of pointless.
#    (CircularQueue is also just trivially different from LinkedQueue).
#
#    LinkedRingBuffer and RecyclingQueue were originally both subclasses of LinkedQueue. However,
#    with the introduction of the RingBuffer class and due to the limitations of single inheritance,
#    the two headed in different directions.
#    
#    In CLOS, they each inherit from both RING-BUFFER and LINKED-QUEUE. But in Ruby:
#      class LinkedRingBuffer < RingBuffer
#      class RecyclingQueue < LinkedQueue
#
#    Each choice has consequences:
#    1. LinkedRingBuffer does not inherit from LinkedQueue anymore, so it must duplicate some of the
#       parent class code. LinkedRingBuffer already overrode a couple of inherited methods prior to
#       the change, so this is not terrible.
#    2. RecyclingQueue is not really a RingBuffer, so some of the behavior enforced by the parent
#       class could be subverted without care to duplicate it, e.g., enqueue() forces resize() as
#       necessary.
#
#    Another related issue is enforcing RingBuffer's constraints on the ring buffer Deques. In Ruby
#    I wound up duplicating RingBuffer as RingBufferDeque... This is not DRY, but it provides a better
#    guarantee to resize() for enqueue_front(), for example.
#
#    RingBuffer should be mixin? RingBufferDeque can extend?
#    


module Containers
  class Queue < Dispenser
    def empty?
      size.zero?
    end

    def do_clear
      dequeue until empty?
    end
    
    def enqueue(obj)
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)
      do_enqueue(obj)
    end

    def dequeue
      raise StandardError.new("#{self.class} is empty.") if empty?
      do_dequeue
    end

    def front
      raise StandardError.new("#{self.class} is empty.") if empty?
      do_front
    end

    def fill(count: 1000, generator: ->(x) { x })
      1.upto(count) do |i|
        enqueue(generator.call(i))
      end

      self
    end

    def elements
      elts = [];

      until empty?
        elts.push(dequeue)
      end
      
      elts
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

  module RingBuffer
    def full?
      raise NoMethodError, "#{self.class} does not implement full?()"
    end

    def resize
      raise StandardError.new("resize() called without full store") unless full?
      do_resize
    end

    private
    def do_enqueue(obj)
      if full?
        resize
      end

      enqueue_elt(obj)
    end

    def do_resize
      raise NoMethodError, "#{self.class} does not implement do_resize()"
    end

    def enqueue_elt(obj)
      raise NoMethodError, "#{self.class} does not implement enqueue_elt()"
    end
  end
  
  #
  #    Prosaic array. Assumed to be fixed-length -> manual resize. Queue "wraps around" as long as there is space.
  #    This is traditional `ring buffer`
  #    
  class ArrayRingBuffer < Queue
    include RingBuffer

    ARRAY_RING_BUFFER_CAPACITY = 20
    attr_accessor :store, :count

    def initialize(type: Object)
      super(type: type)
      @store = Array.new(ARRAY_RING_BUFFER_CAPACITY)
      @front = 0
      @count = 0
    end

    def size
      @count
    end

    def offset(i)
      (i + @front) % @store.size
    end

    def full?
      size == @store.size
    end

    def head=(n)  #????????
      @front = n
    end
    
    private
    def do_resize
      new_store = Array.new(@store.size * 2)
      @count.times do |i|
        new_store[i] = @store[offset(i)]
      end
      
      @store = new_store
      @front = 0
    end
    
    def enqueue_elt(obj)
      @store[offset(@count)] = obj
      @count += 1
    end

    def do_dequeue
      discard = front

      @store[@front] = nil
      @front = offset(1)
      @count -= 1

      discard
    end

    def do_front
      @store[@front]
    end
  end

  #
  #    Another array-based queue, but this relies on built-in Ruby features, namely
  #    push() at end of array and shift() at front of array.
  #    
  class RubyQueue < Queue
    def initialize(type: Object)
      super(type: type)
      @store = []
    end

    def size
      @store.size
    end

    def do_clear
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

    def initialize(type: Object)
      super(type: type)
      @front = nil
      @rear = nil
      @count = 0
    end

    def size
      @count
    end

    def do_clear   # Call initialize??
      @front = nil
      @rear = nil
      @count = 0
    end
    
    private
    def do_enqueue(obj)
      node = Node.new(obj, nil)

      if empty?
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
    def initialize(type: Object)
      super(type: type)
      @list = SinglyLinkedListX.new
    end

    def size
      @list.size
    end

    def do_clear
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

  class DllQueue < Queue
    def initialize(type: Object)
      super(type: type)
      @list = DoublyLinkedList.new
    end

    def size
      @list.size
    end

    def do_clear
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
    def initialize(type: Object)
      super(type: type)
      @index = nil
      @count = 0
    end

    def size
      @count
    end

    def do_clear   # Call initialize??
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
    include RingBuffer

    def initialize(type: Object)
      super(type: type)
      @front = Node.empty_list(LINKED_QUEUE_CAPACITY)
      @rear = @front
      @ass = @front.last
    end

    def do_clear
      dequeue until empty?
    end

    def full?
      @rear == @ass
    end

    private
    def do_resize
      more = Node.empty_list(@count + 1)
      @ass.rest = more
      @ass = more.last
    end

    def enqueue_elt(obj)
      @rear.first = obj
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

  class LinkedRingBuffer < LinkedQueue
    include RingBuffer

    def initialize(type: Object)
      super(type: type)
      @front = Node.empty_list(LINKED_QUEUE_CAPACITY)
      @rear = @front
      @front.last.rest = @front
    end
      
    def do_clear
      dequeue until empty?
    end

    def full?
      @rear.rest == @front
    end
    
    private
    def do_resize
      more = Node.empty_list(@count + 1)
      @rear.rest = more
      more.last.rest = @front
    end

    def enqueue_elt(obj)
      @rear.first = obj
      @rear = @rear.rest
      @count += 1
    end

    def do_dequeue
      discard = front

      @front.first = nil
      @front = @front.rest
      @count -= 1

      discard
    end
  end
  
  class HashQueue < Queue
    def initialize(type: Object)
      super(type: type)
      @store = {}
      @front = 0
      @rear = 0
    end

    def size
      @store.size
    end

    def do_clear
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
    def clear
      if empty?
        self
      else
        make_empty_persistent_queue
      end
    end
    
    def fill(count: 1000, generator: ->(x) { x })
      queue = self
      
      1.upto(count) do |i|
        queue = queue.enqueue(generator.call(i))
      end

      queue
    end

    def elements
      elts = [];
      queue = self

      until queue.empty?
        elts.push(queue.front)
        queue = queue.dequeue
      end
      
      elts
    end
  end

  class PersistentLinkedQueue < PersistentQueue
    def initialize(type: Object) # Client can only create empty PersistentLinkedQueue
      super(type: type)
      @front = nil
      @rear = nil
      @count = 0
    end

    def size
      @count
    end

    protected
    def create_queue(front, rear, count)  # private???
      queue = make_empty_persistent_queue
      queue.front = front
      queue.rear = rear
      queue.count = count
      queue
    end

    def make_empty_persistent_queue
      PersistentLinkedQueue.new(type: @type)
    end

    #
    #    Writers only exist to adjust non-empty PersistentLinkedQueue after creation.
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

  class PersistentListQueue < PersistentQueue
    @@empty = PersistentList.new
    def initialize(type: Object)
      super(type: type)
      @list = @@empty
    end

    def size
      @list.size
    end

    protected
    def make_empty_persistent_queue
      PersistentListQueue.new(type: @type)
    end

    #
    #    Writers only exist to adjust non-empty PersistentListQueue after creation.
    #    Constructor only creates empty queues since it is public.
    #    
    def list=(list)
      @list = list
    end

    private
    def create_queue(list) # protected??
      queue = PersistentListQueue.new(type: @type)
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

  module RingBufferDeque
    include RingBuffer

    private
    def do_enqueue_front(obj)
      if full?
        resize
      end

      enqueue_front_elt(obj)
    end
    
    def enqueue_front_elt(obj)
      raise NoMethodError, "#{self.class} does not implement enqueue_front_elt()"
    end
  end

  class ArrayRingBufferDeque < Deque
    include RingBufferDeque
    
    ARRAY_RING_BUFFER_DEQUE_CAPACITY = 20

    def initialize(type: Object)
      super(type: type)
      @store = Array.new(ARRAY_RING_BUFFER_DEQUE_CAPACITY)
      @front = 0
      @count = 0
    end

    def size
      @count
    end

    private
    def offset(i)
      (i + @front) % @store.size
    end

    def full?
      size == @store.size
    end

    def do_resize
      new_store = Array.new(@store.size * 2)
      @count.times do |i|
        new_store[i] = @store[offset(i)]
      end

      @store = new_store
      @front = 0
    end
    
    def enqueue_elt(obj)
      @store[offset(@count)] = obj
      @count += 1
    end

    def do_dequeue
      discard = front

      @store[@front] = nil
      @front = offset(1)
      @count -= 1

      discard
    end

    def enqueue_front_elt(obj)
      @front = offset(-1)
      @store[offset(0)] = obj
      @count += 1
    end

    def do_dequeue_rear
      discard = rear

      @store[offset(@count - 1)] = nil
      @count -= 1

      discard
    end

    def do_front
      @store[@front]
    end

    def do_rear
      @store[offset(@count - 1)]
    end
  end

  # class ArrayRingBufferDeque < ArrayRingBuffer
  #   include RingBufferDeque
    
  #   ARRAY_RING_BUFFER_DEQUE_CAPACITY = 20

  #   def initialize(type: Object)
  #     super(type: type)
  #   end

  #   private
  #   def do_enqueue_front(obj)
  #     @front = offset(-1)
  #     @store[offset(0)] = obj
  #     @count += 1
  #   end

  #   def do_dequeue_rear
  #     discard = rear

  #     @store[offset(@count - 1)] = nil
  #     @count -= 1

  #     discard
  #   end

  #   def do_rear
  #     @store[offset(@count - 1)]
  #   end
  # end

  class ArrayRingBufferDequeX < Deque  # RingBufferDeque??
    def initialize(type: Object)
      super(type: type)
      @ring_buffer = ArrayRingBuffer.new
    end

    def size
      @ring_buffer.size
    end

    private
    def do_enqueue(obj)
      @ring_buffer.enqueue(obj)
    end

    def do_dequeue
      @ring_buffer.dequeue
    end

    def do_enqueue_front(obj)
      if size == @ring_buffer.store.size
        @ring_buffer.resize
      end

      @ring_buffer.head = @ring_buffer.offset(-1)
      @ring_buffer.store[@ring_buffer.offset(0)] = obj
      @ring_buffer.count += 1
    end

    def do_dequeue_rear
      discard = rear

      @ring_buffer.store[@ring_buffer.offset(@ring_buffer.count - 1)] = nil
      @ring_buffer.count -= 1

      discard
    end

    def do_front
      @ring_buffer.front
    end

    def do_rear
      @ring_buffer.store[@ring_buffer.offset(@ring_buffer.count - 1)]
    end
  end

  class DllDeque < Deque
    def initialize(type: Object)
      super(type: type)
      @list = DoublyLinkedList.new
    end
    
    def size
      @list.size
    end

    def do_clear
      @list.clear
    end
    
    private
    def do_enqueue(obj)
      @list.add(obj)
    end

    def do_dequeue
      @list.delete(0)
    end

    def do_enqueue_front(obj)
      @list.insert(0, obj)
    end

    def do_dequeue_rear
      @list.delete(-1)
    end
    
    def do_front
      @list.get(0)
    end

    def do_rear
      @list.get(-1)
    end
  end

  class HashDeque < Deque
    def initialize(type: Object)
      super(type: type)
      @store = {}
      @front = 0
      @rear = 0
    end
    
    def size
      @store.size
    end

    def do_clear
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
    def clear
      if empty?
        self
      else
        make_empty_persistent_deque
      end
    end

    def fill(count: 1000, generator: ->(x) { x })
      deque = self
      
      1.upto(count) do |i|
        deque = deque.enqueue(generator.call(i))
      end

      deque
    end

    def elements
      elts = [];
      deque = self

      until deque.empty?
        elts.push(deque.front)
        deque = deque.dequeue
      end
      
      elts
    end
  end

  class PersistentLinkedDeque < PersistentDeque
    def initialize(type: Object)
      super(type: type)
      @front = nil
      @rear = nil
      @count = 0
    end

    def size
      @count
    end

    protected
    def initialize_deque(front, rear, count)
      dq = make_empty_persistent_deque
      dq.front = front
      dq.rear = rear
      dq.count = count

      dq
    end

    def make_empty_persistent_deque
      PersistentLinkedDeque.new(type: @type)
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

  class PersistentListDeque < PersistentDeque
    @@empty = PersistentList.new
    def initialize(type: Object)
      super(type: type)
      @list = @@empty
    end

    def size
      @list.size
    end

    protected
    def make_empty_persistent_deque
      PersistentListDeque.new(type: @type)
    end

    #
    #    Writers only exist to adjust non-empty PersistentListDeque after creation.
    #    Constructor only creates empty deques since it is public.
    #    
    def list=(list)
      @list = list
    end

    private
    def create_deque(list)
      dq = PersistentListDeque.new(type: @type)
      dq.list = list

      dq
    end

    def do_enqueue(obj)
      create_deque(@list.add(obj))
    end

    def do_dequeue
      create_deque(@list.delete(0))
    end

    def do_enqueue_front(obj)
      create_deque(@list.insert(0, obj))
    end

    def do_dequeue_rear
      create_deque(@list.delete(-1))
    end
    
    def do_front
      @list.get(0)
    end

    def do_rear
      @list.get(-1)
    end
  end
end
