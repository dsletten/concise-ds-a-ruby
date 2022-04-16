#!/snap/bin/ruby -w

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

    def initialize(type)
      @type = type
    end
    
    def size
      raise NoMethodError, "#{self.class} does not implement size()"
    end

    def empty?
      raise NoMethodError, "#{self.class} does not implement empty?()"
    end

    def clear
      raise NoMethodError, "#{self.class} does not implement clear()"
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

    #
    #    Can't be instance method in case node is nil????
    #    
    def self.nth(node, i)
      if node.nil?
        nil
      elsif i.zero?
        node.first
      else
        nth(node.rest, i - 1)
      end
    end
    
    # def nth(i)
    #   if i.zero?  ||  
    #     self.first
    #   else
      
#    def self.nth=(node, i, obj)
    def self.set_nth(node, i, obj)
      if node.nil?
        nil
      elsif i.zero?
        node.first = obj
      else
        set_nth(node.rest, i - 1, obj)
      end
    end

    def self.nthcdr(node, i)
      if node.nil?
        nil
      elsif i.zero?
        node
      else
        nthcdr(node.rest, i - 1)
      end
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

    def self.include?(node, obj, test: ->(x, y) {x == y})
      if node.nil?
        nil
#      elsif node.first == obj
      elsif test.call(obj, node.first)
        node.first
      else
        include?(node.rest, obj, test: test)
      end
    end

    def self.index(node, obj, test: ->(x, y) {x == y})
      _index(node, obj, 0, test)
    end

    def self.append(l1, l2)
      if l1.nil?
        l2
      else
        Node.new(l1.first, append(l1.rest, l2))
      end
    end

    def self.reverse(list)
      _reverse(list, nil)
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
    def self._index(node, obj, i, test)
      if node.nil?
        nil
      elsif test.call(obj, node.first)
        i
      else
        _index(node.rest, obj, i+1, test)
      end
    end

    def self._reverse(list, result)
      if list.nil?
        result
      else
        _reverse(list.rest, Node.new(list.first, result))
      end
    end
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
      raise NoMethodError, "#{self.class} does not implement do_contains?()"
    end
  end

  class Iterator
    def current
      raise StandardError.new("Iteration already finished.") if done?
      do_current
    end

    def next
      raise NoMethodError, "#{self.class} does not implement next()"
    end
    
    def done?
      raise NoMethodError, "#{self.class} does not implement done?()"
    end

    private
    def do_current
      raise NoMethodError, "#{self.class} does not implement do_current()"
    end
  end

  class MutableCollectionIterator < Iterator
    def initialize(collection)
      @collection = collection
      @expected_modification_count = @collection.modification_count
    end

    def done?
      check_comodification
      do_done?
    end

    def next
      check_comodification
      do_next
    end

    private
    def comodified?
      @expected_modification_count != @collection.modification_count
    end

    def check_comodification
      raise StandardError.new("Iterator invalid due to structural modification of collection.") if comodified?
    end
    
    def do_done?
      raise NoMethodError, "#{self.class} does not implement do_done?()"
    end

    def do_next
      raise NoMethodError, "#{self.class} does not implement do_next()"
    end

    def do_current
      check_comodification
      do_do_current #?!?!?!
    end

    def do_do_current
      raise NoMethodError, "#{self.class} does not implement do_do_current()"
    end
  end
end
