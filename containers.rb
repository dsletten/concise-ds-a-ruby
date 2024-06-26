#    File:
#       containers.rb
#
#    Synopsis:
#
#
#        http://chrisstump.online/2016/03/23/stop-abusing-notimplementederror/
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210102 Original.

module Containers
  class Container
    attr_reader :type

    def initialize(type: Object)
      @type = type
    end
    
    def size
      raise NoMethodError, "#{self.class} does not implement size()"
    end

    def empty?
      raise NoMethodError, "#{self.class} does not implement empty?()"
    end

    def clear
      unless empty?
        do_clear
      end
    end

    def elements
      raise NoMethodError, "#{self.class} does not implement elements()"
    end

    private
    def do_clear
      raise NoMethodError, "#{self.class} does not implement do_clear()"
    end
  end

  class Dispenser < Container
  end

  #
  #    Node#first has a type?
  #    Alternatively, Node is completely hidden. Container enforces type on public push()
  #    
  class Node
    attr_accessor :first, :rest # Have to be able to modify for queue!

    def initialize(first, rest)
      @first = first
      @rest = rest
    end

    #
    #    Assumes proper list?!
    #    
    def last
      node = self
      node = node.rest until node.rest.nil?
      node
    end

    def to_s
      car_print(@first) + cdr_print(@rest)
    end

    #
    #    Can't be instance method in case node is nil????
    #    
    # def self.nth(node, i)
    #   if node.nil?
    #     nil
    #   elsif i.zero?
    #     node.first
    #   else
    #     nth(node.rest, i - 1)
    #   end
    # end
    
    def self.nth(node, i)
      nth_node = nthcdr(node, i)
      
      if nth_node.nil?
        nil
      else
        nth_node.first
      end
    end
    
    # def nth(i)
    #   if i.zero?  ||  
    #     self.first
    #   else
      
#    def self.nth=(node, i, obj)
    def self.set_nth(node, i, obj)
      nth_node = nthcdr(node, i)
      
      if nth_node.nil?
        nil
      else
        nth_node.first = obj
      end
      # if node.nil?
      #   nil
      # elsif i.zero?
      #   node.first = obj
      # else
      #   set_nth(node.rest, i - 1, obj)
      # end
    end

    # def self.nthcdr(node, i)
    #   if node.nil?
    #     nil
    #   elsif i.zero?
    #     node
    #   else
    #     nthcdr(node.rest, i - 1)
    #   end
    # end
    
    def self.nthcdr(node, i)
      raise ArgumentError.new("Invalid index: #{i}") if i < 0

      j = 0
      until i == j
        return nil if node.nil?

        node = node.rest
        j += 1
      end

      node
    end
    
    def self.empty_list(count)
      list = nil
      count.times do
        list = Node.new(nil, list)
      end

      list
    end

    #    This returns an array. Should also have sublist()??
    # def self.slice(node, i, n)
    #   if i.zero?
    #     result = []
    #     n.times do
    #       return result if node.nil?
    #       result << node.first
    #       node = node.rest
    #     end
        
    #     result
    #   else
    #     slice(node.rest, i-1, n)
    #   end
    # end

    def self.slice(node, i, n)
      head = nthcdr(node, i)
      result = []
      n.times do
        return result if head.nil?

        result << head.first
        head = head.rest
      end
        
      result
    end

#     def self.include?(node, obj, test: ->(x, y) {x == y})
#       if node.nil?
#         nil
# #      elsif node.first == obj
#       elsif test.call(obj, node.first)
#         node.first
#       else
#         include?(node.rest, obj, test: test)
#       end
#     end

    def self.include?(node, obj, test: ->(x, y) {x == y})
      until node.nil?
        return node.first if test.call(obj, node.first)

        node = node.rest
      end

      nil
    end

    # def self.index(node, obj, test: ->(x, y) {x == y})
    #   _index(node, obj, 0, test)
    # end

    def self.index(node, obj, test: ->(x, y) {x == y})
      i = 0
      until node.nil?
        return i if test.call(obj, node.first)

        node = node.rest
        i += 1
      end

      nil

    end

    def self.append(l1, l2)
      if l1.nil?
        l2
      else
#        Node.new(l1.first, append(l1.rest, l2))
        node = Node.new(l1.first, l1.rest)
        tail = node
        until tail.rest.nil?
          tail.rest = Node.new(tail.rest.first, tail.rest.rest)
          tail = tail.rest
        end
        tail.rest = l2

        node
      end
    end

    # def self.reverse(list)
    #   _reverse(list, nil)
    # end

    def self.reverse(list)
      result = nil
      node = list

      until node.nil?
        result = Node.new(node.first, result)
        node = node.rest
      end

      result
    end

    def splice_before(obj)
      copy = Node.new(@first, @rest)
      @first = obj
      @rest = copy
    end
    
    def splice_after(obj)
      tail = Node.new(obj, @rest)
      @rest = tail
    end

    def excise_node
      doomed = @first
      saved = @rest

      if saved.nil?
        raise StandardError.new("Target node must have non-nil next node")
      else
        @first = saved.first
        @rest = saved.rest
      end

      doomed
    end

    def excise_child
      child = @rest
      
      if child.nil?
        raise StandardError.new("Parent must have child node")
      else
        @rest = child.rest
      end

      child.first
    end

    private
    def car_print(obj)
      "(#{obj}"
    end

    def cdr_print(obj)
      if obj.nil?
        ")"
      elsif !obj.is_a?(Node)
        " . #{obj})"
      else
        " #{obj.first()}" + cdr_print(obj.rest())
      end
    end

    def self._index(node, obj, i, test)
      if node.nil?
        nil
      elsif test.call(obj, node.first)
        i
      else
        _index(node.rest, obj, i+1, test)
      end
    end

    # def self._reverse(list, result)
    #   if list.nil?
    #     result
    #   else
    #     _reverse(list.rest, Node.new(list.first, result))
    #   end
    # end
  end
  
  class Collection < Container
    def iterator
      raise NoMethodError, "#{self.class} does not implement iterator()"
    end

    def contains?(obj, test: ->(x, y) {x == y})
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)
      do_contains?(obj, test)
    end

    def ==(collection, test)
      raise NoMethodError, "#{self.class} does not implement =="
    end

    def each # block??
      raise NoMethodError, "#{self.class} does not implement each()"
    end

    private
    def do_contains?(obj, test)
      iter = iterator

      until iter.done?
        elt = iter.current

        return elt if test.call(obj, elt)

        iter.next
      end

      nil
    end
  end

  # class RemoteControl
  #   def initialize(interface)
  #     @interface = interface
  #   end

  #   def press(method, *args)
  #     @interface[method].call(*args)
  #   end
  # end
  
  class Cursor
    attr_reader :done, :current, :advance
    def initialize(done:, current:, advance:)
      @done = done
      @current = current
      @advance = advance
    end

    def self.make_random_access_list_cursor(list)
      index = 0
      Cursor.new(done: ->() {index == list.size},
                 current: ->() {list.get(index)},
                 advance: ->() {index += 1})
    end

    def self.make_singly_linked_list_cursor(node)
      Cursor.new(done: ->() {node.nil?},
                 current: ->() {node.first},
                 advance: ->() {node = node.rest})
    end

    def self.make_doubly_linked_list_cursor(dcursor)
      sealed_for_your_protection = true      
      Cursor.new(done: ->() {!dcursor.initialized? ||
                             (!sealed_for_your_protection && dcursor.start?)},
                 current: ->() {dcursor.node.content}, # ???
                 advance: ->() {dcursor.advance; sealed_for_your_protection = false})
    end

    def self.make_persistent_list_cursor(list)
      Cursor.new(done: ->() {list.empty?},
                 current: ->() {list.get(0)},
                 advance: ->() {list.delete(0).iterator})
    end
  end
  
  class Iterator
    def initialize(cursor)
      @cursor = cursor
    end

    def done?
      check_done
    end

    def current
      raise StandardError.new("Iteration already finished.") if done?

      current_element
    end

    def next
      if done?
        nil
      else
        next_element

        if done?
          nil
        else
          current
        end
      end
    end

    private
    def check_done
      @cursor.done.call
    end

    def current_element
      @cursor.current.call
    end

    def next_element
      @cursor.advance.call
    end
  end

  class MutableCollectionIterator < Iterator
    def initialize(cursor:, modification_count:)
      super(cursor)
      @modification_count = modification_count
      @expected_modification_count = @modification_count.call
    end

    private
    def comodified?
      @expected_modification_count != @modification_count.call
    end

    def check_comodification
      raise StandardError.new("Iterator invalid due to structural modification of collection.") if comodified?
    end
    
    def check_done
      check_comodification
      super
    end

    def current_element
      check_comodification
      super
    end

    def next_element
      check_comodification
      super
    end
  end

  class PersistentCollectionIterator < Iterator
    def initialize(cursor)
      super(cursor)
    end

    def next
      if done?
        self
      else
        @cursor.advance.call
      end
    end
  end
end
