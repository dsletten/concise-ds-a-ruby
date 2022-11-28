#!/snap/bin/ruby -w

#    File:
#       stack.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       211113 Original.

module Containers
  class Stack < Dispenser
    def push(obj)
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)
      do_push(obj)
    end

    def pop
      raise StandardError.new("Stack is empty.") if empty?
      do_pop
    end

    def peek
      raise StandardError.new("Stack is empty.") if empty?
      do_peek
    end

    def fill(count: 1000, generator: ->(x) { x })
      1.upto(count) do |i|
        push(generator.call(i))
      end

      self
    end

    private
    def do_push(obj)
      raise NoMethodError, "#{self.class} does not implement do_push()"
    end

    def do_pop
      raise NoMethodError, "#{self.class} does not implement do_pop()"
    end

    def do_peek
      raise NoMethodError, "#{self.class} does not implement do_peek()"
    end
  end

  class ArrayStack < Stack
    def initialize(type: Object)
      super(type: type)
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
    def do_push(obj)
      @store.push(obj)
    end

    def do_pop
      @store.pop
    end

    def do_peek
      @store[-1]
    end
  end

  class LinkedStack < Stack
    def initialize(type: Object)
      super(type: type)
      @top = nil
      @count = 0
    end

    def size
      @count
    end

    def empty?
      @top.nil?
    end

    def clear   # Call initialize??
      @top = nil
      @count = 0
    end
    
    private
    def do_push(obj)
      @top = Node.new(obj, @top)
      @count += 1
    end

    def do_pop
      #    discard = @top.first
      discard = peek
      @top = @top.rest
      @count -= 1
      discard
    end

    def do_peek
      @top.first
    end
  end

  class LinkedListStack < Stack
    def initialize(type: Object)
      super(type: type)
      @list = SinglyLinkedList.new
    end

    def size
      @list.size
    end

    def empty?
      @list.empty?
    end

    def clear
      @list.clear
    end
    
    private
    def do_push(obj)
      @list.insert(0, obj)
    end

    def do_pop
      @list.delete(0)
    end

    def do_peek
      @list.get(0)
    end
  end

  class HashStack < Stack
    def initialize(type: Object)
      super(type: type)
      @store = {}
    end

    def size
      @store.size
    end

    def empty?
      @store.empty?
    end

    def clear
      @store = {}
    end

    private
    def do_push(obj)
      @store[@store.size+1] = obj
    end

    def do_pop
      @store.delete(@store.size)
    end

    def do_peek
      @store[@store.size]
    end
  end

  class PersistentStack < Stack
    def fill(count: 1000, generator: ->(x) { x })
      stack = self
      1.upto(count) do |i|
        stack = stack.push(generator.call(i))
      end

      stack
    end
  end

  class PersistentLinkedStack < PersistentStack
    def initialize(type: Object) # Client can only create empty PersistentLinkedStack
      super(type: type)
      @top = nil
      @count = 0
    end

    def size
      @count
    end

    def empty?
      @top.nil?
    end

    def clear
      PersistentLinkedStack.new(type: @type)
    end
    
    protected
    def top=(node)
      @top = node
    end

    def count=(count)
      @count = count
    end

    private
    def create_stack(top, count)
      stack = PersistentLinkedStack.new(type: @type)
      stack.top = top
      stack.count = count
      stack
    end
    
    def do_push(obj)
      create_stack(Node.new(obj, @top), @count + 1)
    end

    def do_pop
      create_stack(@top.rest, @count - 1)
    end

    def do_peek
      @top.first
    end
  end

  class PersistentListStack < PersistentStack
    @@empty = PersistentList.new
    
    def initialize(type: Object)
      super(type: type)
      @list = @@empty
    end

    def size
      @list.size
    end

    def empty?
      @list.empty?
    end

    def clear
      PersistentListStack.new(type: @type)
    end

    protected
    def list=(list)
      @list = list
    end
    
    private
    def create_stack(list)
      stack = PersistentListStack.new(type: @type)
      stack.list = list

      stack
    end
    
    def do_push(obj)
      create_stack(@list.insert(0, obj))
    end

    def do_pop
      create_stack(@list.delete(0))
    end

    def do_peek
      @list.get(0)
    end
  end
end
