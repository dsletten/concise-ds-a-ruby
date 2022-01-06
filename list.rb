#!/snap/bin/ruby -w

#    File:
#       list.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       211113 Original.

#
#    No distinction between type of list and type of `fill_elt`??? Compare Lisp...
#    

module Collections
  class List < Collection
    attr_reader :fill_elt
    
    def initialize(type, fill_elt)
      raise ArgumentError.new("Incompatible fill_elt type") unless fill_elt.is_a?(type)

      super(type)
      @fill_elt = fill_elt
    end

    def to_s
      result = "("
      i = iterator

      until i.done?
        result << i.current.to_s # Invisible nil!
        i.next
        result << " " unless i.done?
      end

      result << ")"
    end

# PersistentList !!!
#    def equals(l)
    def ==(list)
#      if list.is_a?(ArrayList)  &&  list.size == self.size
      if list.size == self.size
        i1 = self.iterator
        i2 = list.iterator

        until i1.done?  &&  i2.done?
          return false unless i1.current == i2.current
          i1.next
          i2.next
        end

        true
      else
        false
      end
    end
     
    def each
      i = iterator
      until i.done?
        yield i.current
        i.next
      end
    end

    # def each
    #   self.size.times do |i|
    #     yield self[i]
    #   end
    # end

    def list_iterator
      raise NoMethodError, "#{self.class} does not implement list_iterator()"
    end

    ##########################################Structural modification############################
    def add(*objs)
      raise ArgumentError.new("Type mismatch with objs") unless objs.all? {|obj| obj.is_a?(type)}

      do_add(*objs) unless objs.empty?
    end

    def insert(i, obj)
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)

      if i.negative?
        j = i + size
        unless j.negative?
          insert(j, obj)
        end
      elsif i >= size
        extend_list(i, obj)
      else
        do_insert(i, obj)
      end
    end

    def delete(i)
      raise StandardError.new("List is empty.") if empty?

      if i.negative?
        j = i + size
        unless j.negative?
          delete(j)
        end
      elsif i < size # This is inconsistent with empty? test. (I.e., size = 0: 0 < 0)
        do_delete(i)
      end
    end
    #############################################################################################

    def [](i)
      if i.negative?
        j = i + size
        if j.negative?
          nil
        else
          self[j]
        end
      elsif i >= size
        nil
      else
        do_get(i)
      end
    end

    def []=(i, obj)
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)

      if i.negative?
        j = i + size
        unless j.negative?
          self[j] = obj
        end
      elsif i >= size
        extend_list(i, obj)
      else
        do_set(i, obj)
      end
    end
    
    def index(obj)
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)
      do_index(obj)
    end
    
    def slice(i, n)
      raise ArgumentError.new("Slice count must be non-negative: #{n}") if n < 0

      if i.negative?
        j = i + size
        if j.negative?
          slice(0, 0)
        else
          slice(j, n)
        end
      else
        do_slice(i, n)
      end
    end

    private
    def do_add(obj)
      raise NoMethodError, "#{self.class} does not implement do_add()"
    end

    def extend_list(i, obj)
        tail = Array.new(i - size, @fill_elt) << obj
        add(*tail)
    end

    def do_insert(i, obj)
      raise NoMethodError, "#{self.class} does not implement do_insert()"
    end

    def do_delete(i)
      raise NoMethodError, "#{self.class} does not implement do_delete()"
    end

    def do_get(i) # Syntax??
      raise NoMethodError, "#{self.class} does not implement do_get()"
    end

    def do_set(i, obj) # Syntax??
      raise NoMethodError, "#{self.class} does not implement do_set()"
    end

    def do_index(obj)
      raise NoMethodError, "#{self.class} does not implement do_index()"
    end

    def do_slice(i, n)
      raise NoMethodError, "#{self.class} does not implement do_slice()"
    end
  end

  class MutableList < List
    attr_reader :modification_count

    def initialize(type, fill_elt)
      super(type, fill_elt)
      @modification_count = 0
    end

    def count_modification
      @modification_count += 1
    end

    def clear
      count_modification
      do_clear
    end

    private
    def do_clear
      raise NoMethodError, "#{self.class} does not implement do_clear()"
    end

    def do_add(*objs)
      count_modification
      do_do_add(*objs)
    end

    def do_insert(i, obj)
      count_modification
      do_do_insert(i, obj)
    end

    def do_delete(i)
      count_modification
      do_do_delete(i)
    end

    def do_do_add(obj)
      raise NoMethodError, "#{self.class} does not implement do_do_add()"
    end

    def do_do_insert(i, obj)
      raise NoMethodError, "#{self.class} does not implement do_do_insert()"
    end

    def do_do_delete(i)
      raise NoMethodError, "#{self.class} does not implement do_do_delete()"
    end
  end
  
  class LinkedList < List
    #private    These can't be private!!! Called by list iterator...
    ##########################################Structural modification############################
    def insert_before(node, obj)
      if !obj.is_a?(type)
        raise ArgumentError.new("#{obj} is not of type #{type}")
      elsif node.nil?
        raise ArgumentError.new("Invalid node")
      else
        do_insert_before(node, obj)
      end
    end
    
    def insert_after(node, obj)
      if !obj.is_a?(type)
        raise ArgumentError.new("#{obj} is not of type #{type}")
      elsif node.nil?
        raise ArgumentError.new("Invalid node")
      else
        do_insert_after(node, obj)
      end
    end

    #
    #    These are necessary in Ruby--no type check on node
    #    
    def delete_node(doomed)
      raise ArgumentError.new("Invalid node") if doomed.nil?
      do_delete_node(doomed)
    end

    def delete_child(parent)
      raise ArgumentError.new("Invalid node") if parent.nil?
      do_delete_child(parent)
    end

    private
    def do_insert_before(node, obj)
      raise NoMethodError, "#{self.class} does not implement do_insert_before()"
    end
      
    def do_insert_after(node, obj)
      raise NoMethodError, "#{self.class} does not implement do_insert_after()"
    end

    def do_delete_node(doomed)
      raise NoMethodError, "#{self.class} does not implement do_delete_node()"
    end

    def do_delete_child(parent)
      raise NoMethodError, "#{self.class} does not implement do_delete_child()"
    end
    #############################################################################################
  end
    
  class MutableLinkedList < LinkedList
    attr_reader :modification_count

    def initialize(type, fill_elt)
      super(type, fill_elt)
      @modification_count = 0
    end

    def count_modification
      @modification_count += 1
    end

    def clear
      count_modification
      do_clear
    end

    private
    def do_clear
      raise NoMethodError, "#{self.class} does not implement do_clear()"
    end

    def do_add(*objs)
      count_modification
      do_do_add(*objs)
    end

    def do_insert(i, obj)
      count_modification
      do_do_insert(i, obj)
    end

    def do_delete(i)
      count_modification
      do_do_delete(i)
    end

    def do_insert_before(node, obj)
      count_modification
      do_do_insert_before(node, obj)
    end
      
    def do_insert_after(node, obj)
      count_modification
      do_do_insert_after(node, obj)
    end

    def do_delete_node(doomed)
      count_modification
      do_do_delete_node(doomed)
    end

    def do_delete_child(parent)
      count_modification
      do_do_delete_child(parent)
    end

    def do_do_add(obj)
      raise NoMethodError, "#{self.class} does not implement do_do_add()"
    end

    def do_do_insert(i, obj)
      raise NoMethodError, "#{self.class} does not implement do_do_insert()"
    end

    def do_do_delete(i)
      raise NoMethodError, "#{self.class} does not implement do_do_delete()"
    end

    def do_do_insert_before(node, obj)
      raise NoMethodError, "#{self.class} does not implement do_do_insert_before()"
    end
      
    def do_do_insert_after(node, obj)
      raise NoMethodError, "#{self.class} does not implement do_do_insert_after()"
    end

    def do_do_delete_node(doomed)
      raise NoMethodError, "#{self.class} does not implement do_do_delete_node()"
    end

    def do_do_delete_child(parent)
      raise NoMethodError, "#{self.class} does not implement do_do_delete_child()"
    end
  end

  class ArrayList < MutableList
    def initialize(type=Object, fill_elt=nil)
      super(type, fill_elt)
      @store = []
    end

    def size
      @store.size
    end

    def empty?
      @store.empty?
    end

    def iterator
      RandomAccessListIterator.new(self)
    end
    
    def list_iterator(start=0)
      RandomAccessListListIterator.new(self, start)
    end
    
    private
    def do_clear
      @store = []
    end

    def do_contains?(obj)
      @store.include?(obj)
    end

    def do_do_add(*objs)
      @store += objs
    end

    #
    #    Is this worth the trouble just to manipulate the fill element?
    #    
    # def do_insert(i, obj)
    #   #      @store.insert(i, obj) # Always fills with `nil`
    #   if i < 0
    #     j = i + size
    #     do_insert(j, obj) unless j < 0
    #   else
    #     if i > size
    #       until size > i
    #         @store << fill_elt
    #       end
    #       @store[i] = obj
    #     else
    #       @store.insert(i, obj)
    #     end
    #   end
    # end

    def do_do_insert(i, obj)
      @store.insert(i, obj)
    end

    def do_do_delete(i)
      @store.delete_at(i)
    end
    
    def do_get(i)
      @store[i]
    end

    def do_set(i, obj)
      @store[i] = obj
    end
    
    def do_index(obj)
      @store.index(obj)
    end

    #
    #    Returns empty ArrayList if negative i is too far
    #    vs. Array#slice => nil
    #    
    def do_slice(i, n)
      list = ArrayList.new(type, fill_elt)
      list.add(*(@store[i, n])) # Compare Common Lisp version to calculate what to add!
      list
    end
  end

  class RandomAccessListIterator < MutableCollectionIterator
    def initialize(list)
      super(list)
      @cursor = 0
    end

    private
    def do_do_current  # ?!?!
      @collection[@cursor]
    end

    def do_done?
      @cursor == @collection.size
    end

    def do_next
      @cursor += 1 unless done?
    end

  end

  class SinglyLinkedList < MutableLinkedList
    attr_reader :store

    def initialize(type=Object, fill_elt=nil)
      super(type, fill_elt)
      @store = nil
      @count = 0
    end
    
    def size
      @count
    end

    def empty?
      @store.nil?
    end

    def iterator
      SinglyLinkedListIterator.new(self)
    end
    
    def list_iterator(start=0)
      SinglyLinkedListListIterator.new(self, start)
    end

    private
    def do_clear
      @store = nil
      @count = 0
    end

    def do_contains?(obj)
      Node.include?(@store, obj)
    end

    def do_do_add(*objs)
      node = nil
      objs.reverse_each do |elt|
        node = Node.new(elt, node)
      end
      
      if self.empty?
        @store = node
      else
        @store.last.rest = node
      end
      
      @count += objs.size
    end

    # def do_insert(i, obj)
    #   if i.zero?
    #     @store = Node.new(obj, @store)
    #   else
    #     head = Node.nthcdr(@store, i - 1)
    #     head.rest = Node.new(obj, head.rest)
    #   end
      
    #   @count += 1
    # end

    def do_do_insert(i, obj)
      do_insert_before(Node.nthcdr(@store, i), obj)
    end

    def do_insert_before(node, obj)
      copy = Node.new(node.first, node.rest)
      node.first = obj
      node.rest = copy

      count_modification
      @count += 1
    end

    def do_insert_after(node, obj)
      tail = Node.new(obj, node.rest)
      node.rest = tail

      count_modification
      @count += 1
    end

    # def do_delete(i)
    #   if i.zero?
    #     doomed = @store.first
    #     @store = @store.rest
    #     @count -= 1
    #     doomed
    #   else
    #     head = Node.nthcdr(@store, i - 1)
    #     doomed = head.rest.first
    #     head.rest = head.rest.rest
    #     @count -= 1
    #     doomed
    #   end
    # end

    def do_do_delete(i)
      if i.zero?
        delete_node(@store)
      else
        delete_child(Node.nthcdr(@store, i - 1))
      end
    end

    def do_delete_node(doomed)
      content = doomed.first
      saved = doomed.rest

      if doomed == @store
        @store = saved
      elsif saved.nil?
        raise StandardError.new("Current node must have non-nil next node")
      else
        doomed.first = saved.first
        doomed.rest = saved.rest
      end

      count_modification
      @count -= 1

      content
    end

    def do_delete_child(parent)
      child = parent.rest

      if child.nil?
        raise StandardError.new("Parent must have child node")
      else
        result = child.first
        parent.rest = child.rest

        count_modification
        @count -= 1

        result
      end
    end

    def do_get(i)
      Node.nth(@store, i)
    end

    def do_set(i, obj)
      Node.set_nth(@store, i, obj)
    end

    def do_index(obj)
      Node.index(@store, obj)
    end

    #
    #    Returns empty SinglyLinkedList if negative i is too far
    #    vs. Array#slice => nil
    #    
    def do_slice(i, n)
      list = SinglyLinkedList.new(type, fill_elt)
      start = [i, @count].min
      m = [i+n, @count].min - start
      slice = Node.slice(@store, start, m)

      list.add(*slice)
      list
    end
  end    

  class SinglyLinkedListIterator < MutableCollectionIterator
    def initialize(list)
      super(list)
      @cursor = @collection.store
    end

    private
    def do_do_current
      @cursor.first
    end

    def do_done?
      @cursor.nil?
    end

    def do_next
      @cursor = @cursor.rest unless done?
    end
  end

  class Dcons
    attr_accessor :content, :pred, :succ

    def initialize(content)
      @content = content
    end

    def self.link(pred, succ)
      pred.succ = succ
      succ.pred = pred
    end
  end

  class Dcursor
#    protected ?!
    attr_reader :node, :index

    def initialize(list)
      @list = list
      @node = nil
      @index = 0

      if @list.empty?
        @node = nil
      else
        @node = @list.store
      end
    end

    def initialized?
      !@node.nil?
    end

    def start?
      @index.zero?
    end

    def end?
      @index == @list.size - 1
    end

    def reset
      @index = 0
      if @list.empty?
        @node = nil
      else
        @node = @list.store
      end
    end
      
    def advance(step=1)
      if initialized?
        do_advance(step)
      else
        raise StandardError.new("Cursor has not been initialized.")
      end
    end

    def rewind(step=1)
      if initialized?
        do_rewind(step)
      else
        raise StandardError.new("Cursor has not been initialized.")
      end
    end

    private
    def do_advance(step)
      raise ArgumentError.new("Step must be a positive value: #{step}") if step <= 0
      step.times do
        @index += 1
        @node = @node.succ
      end

      @index = @index % @list.size
    end

    def do_rewind(step)
      raise ArgumentError.new("Step must be a positive value: #{step}") if step <= 0
      step.times do
        @index -= 1
        @node = @node.pred
      end

      @index = @index % @list.size
    end
  end

  #
  #    Circular doubly-linked list w/ cursor to preserve recently accessed position
  #    
  class DoublyLinkedList < MutableLinkedList
#    protected
    attr_reader :store
    
    def initialize(type=Object, fill_elt=nil)
      super(type, fill_elt)
      @store = nil
      @count = 0
      @cursor = Dcursor.new(self)
    end
    
    def size
      @count
    end
    
    def empty?
      @store.nil?
    end
    
    def iterator
      DoublyLinkedListIterator.new(self)
    end

    def list_iterator
      DoublyLinkedListListIterator.new(self)
    end

#    protected
#    attr_reader :head, :cursor

    private
    # def clear
    #   @store = nil # Memory leak?!
    #   @count = 0
    #   @head.reset
    #   @cursor.reset
    # end

    def do_clear
      unless empty?
        dcons = @store
        @count.times do
          dcons.pred = nil
          dcons = dcons.succ
        end

        @store.succ = nil
        @store = nil
        @count = 0
        @cursor.reset
      end
    end

    def nth_dcons(i)
      raise ArgumentError.new("Invalid index: #{i}") if (i < 0  ||  i >= size)

      if empty?
        raise ArgumentError.new("List is empty.")
      else
        index = @cursor.index
        
        if i.zero?
          @store
        elsif i == index
          @cursor.node
        elsif i < index / 2
          @cursor.reset
          @cursor.advance(i)
          @cursor.node
        elsif i < index
          @cursor.rewind(index - i)
          @cursor.node
        elsif i <= (size + index) / 2
          @cursor.advance(i - index)
          @cursor.node
        else
          @cursor.reset
          @cursor.rewind(size - i)
          @cursor.node
        end
      end
    end

    # def do_contains?(obj)
    #   @count.times do |i|
    #     return true if self[i] == obj # This is reasonable due to cursor... Oops! Nope.
    #   end

    #   return false
    # end

    def do_contains?(obj)
      dcons = @store
      @count.times do
        return true if dcons.content == obj
        dcons = dcons.succ
      end

      return false
    end

    def do_do_add(*objs)
      elt, *elts = objs
      dcons = Dcons.new(elt)
      if empty?
        @store = dcons
      else
        tail = @store.pred
        Dcons.link(tail, dcons)
      end
      
      add_nodes(@store, dcons, elts)

      @cursor.reset unless @cursor.initialized?
    end

    def add_nodes(head, start, elts)
      dcons = start
      i = 1
      elts.each do |elt|
        Dcons.link(dcons, Dcons.new(elt))
        dcons = dcons.succ
        i += 1
      end
      Dcons.link(dcons, head)
      @count += i
    end

    def do_get(i)
      nth_dcons(i).content
    end

    def do_set(i, obj)
      nth_dcons(i).content = obj
    end

    def do_do_insert(i, obj)
      new_dcons = Dcons.new(obj)

      if i.zero?
        if empty?
          Dcons.link(new_dcons, new_dcons)
        else
          Dcons.link(@store.pred, new_dcons)
          Dcons.link(new_dcons, @store)
        end

        @store = new_dcons
      else
        dcons = nth_dcons(i)

        Dcons.link(dcons.pred, new_dcons)
        Dcons.link(new_dcons, dcons)
      end

      @count += 1

      if !@cursor.initialized?  ||
         i.between?(0, @cursor.index)  ||
         (i.negative? && (i + @count).between?(0, @cursor.index))
        @cursor.reset
      end
    end
    
    def do_do_delete(i)
      if i.zero?
        doomed = @store.content

        if @store == @store.succ
          @store = nil
        else
          new_store = @store.succ
          Dcons.link(@store.pred, new_store)
          @store = new_store
        end

        @count -= 1

        @cursor.reset
        doomed
      else
        dcons = nth_dcons(i)
        doomed = dcons.content
        Dcons.link(dcons.pred, dcons.succ)
        @count -= 1

        @cursor.reset
        doomed
      end

#      @cursor.reset
    end

    # def do_index(obj)
    #   @count.times do |i|
    #     return i if self[i] == obj # This is reasonable due to cursor D'oh!
    #   end

    #   return nil
    # end

    def do_index(obj)
      dcons = @store
      @count.times do |i|
        return i if dcons.content == obj
        dcons = dcons.succ
      end

      return nil
    end

    #
    #    Inclusive `i`, exclusive `j`
    #    
    def subseq(i, j)
      result = []
      
      if i < j
        dcons = nth_dcons(i)
        (i...j).each do
          result << dcons.content
          dcons = dcons.succ
        end
      end

      result
    end

    #
    #    Returns empty DoublyLinkedList if negative i is too far
    #    vs. Array#slice => nil
    #    
    def do_slice(i, n)
      list = DoublyLinkedList.new(type, fill_elt)
      slice = subseq([i, @count].min, [i+n, @count].min)

      list.add(*slice)
      list
    end
  end

  class DoublyLinkedListIterator < Iterator
    def initialize(list)
      @cursor = Dcursor.new(list)
      @sealed_for_your_protection = true
    end

    def done?
      !@cursor.initialized?  ||  (!@sealed_for_your_protection && @cursor.start?)
    end

    def next
      if done?
        nil
      else
        @cursor.advance
        @sealed_for_your_protection = false
      end
    end

    private
    def do_current
      @cursor.node.content
    end
  end

  class HashList < MutableList
    def initialize(type=Object, fill_elt=nil)
      super(type, fill_elt)
      @store = {}
    end

    def size
      @store.size
    end

    def empty?
      @store.empty?
    end

    def iterator
      RandomAccessListIterator.new(self)
    end
    
    def list_iterator(start=0)
      RandomAccessListListIterator.new(self, start)
    end
    
    private
    def do_clear
      @store = {}
    end

    def do_contains?(obj)
      size.times do |i|
        if @store[i] == obj
          return true
        end
      end

      return false
    end

    def do_do_add(*objs)
      i = size
      objs.each do |obj|
        @store[i] = obj
        i += 1
      end
    end

    def do_do_insert(i, obj)
      count_modification
      size.downto(i+1) do |j|
        @store[j] = @store[j-1]
      end
      @store[i] = obj
    end

    def do_do_delete(i)
      count_modification
      doomed = @store[i]
      i.upto(size-2) do |j|
        @store[j] = @store[j+1]
      end
      @store.delete(size-1)

      doomed
    end
    
    def do_get(i)
      @store[i]
    end

    def do_set(i, obj)
      @store[i] = obj
    end
    
    def do_index(obj)
      size.times do |i|
        if @store[i] == obj
          return i
        end
      end

      return nil
    end

    def do_slice(i, n)
      list = HashList.new(type, fill_elt)

      low = [i, size].min
      high = [i+n, size].min
      slice = []

      low.upto(high-1) do |j|
        slice << @store[j]
      end

      list.add(*slice)
      list
    end
  end

  class ListIterator
    def type
      raise NoMethodError, "#{self.class} does not implement type()"
    end

    def empty?
      raise NoMethodError, "#{self.class} does not implement empty?()"
    end

    def current
      raise StandardError.new("List is empty.") if empty?
      do_current
    end

    def current_index
      raise StandardError.new("List is empty.") if empty?
      do_current_index
    end

    def current=(obj)
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)
      raise StandardError.new("List is empty.") if empty?
      do_set_current(obj)
    end

    def next
      raise StandardError.new("List is empty.") if empty?
      do_next
    end

    def previous
      raise StandardError.new("List is empty.") if empty?
      do_previous
    end

    def has_next?
      raise NoMethodError, "#{self.class} does not implement has_next?()"
    end

    def has_previous?
      raise NoMethodError, "#{self.class} does not implement has_previous?()"
    end

    def remove
      raise StandardError.new("List is empty.") if empty?
      do_remove
    end

    def add_before(obj)
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)
      do_add_before(obj)
    end

    def add_after(obj)
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)
      do_add_after(obj)
    end

    private
    def do_current
      raise NoMethodError, "#{self.class} does not implement do_current()"
    end

    def do_current_index
      raise NoMethodError, "#{self.class} does not implement do_current_index()"
    end

    def do_set_current(obj)
      raise NoMethodError, "#{self.class} does not implement do_set_current()"
    end

    def do_next
      raise NoMethodError, "#{self.class} does not implement do_next()"
    end

    def do_previous
      raise NoMethodError, "#{self.class} does not implement do_previous()"
    end

    def do_remove
      raise NoMethodError, "#{self.class} does not implement do_remove()"
    end

    def do_add_before(obj)
      raise NoMethodError, "#{self.class} does not implement do_add_before()"
    end

    def do_add_after(obj)
      raise NoMethodError, "#{self.class} does not implement do_add_after()"
    end
  end

  class MutableListListIterator < ListIterator
    def initialize(list)
      @list = list
      @expected_modification_count = @list.modification_count
    end
    
    def count_modification
      @expected_modification_count += 1
    end

    def has_next?
      raise StandardError.new("List iterator invalid due to structural modification of collection.") if comodified?
      do_has_next?
    end

    def has_previous?
      raise StandardError.new("List iterator invalid due to structural modification of collection.") if comodified?
      do_has_previous?
    end

    private
    def comodified?
      @expected_modification_count != @list.modification_count
    end

    def do_current
      raise StandardError.new("List iterator invalid due to structural modification of collection.") if comodified?
      do_do_current
    end
    
    def do_current_index
      raise StandardError.new("List iterator invalid due to structural modification of collection.") if comodified?
      do_do_current_index
    end

    def do_set_current(obj)
      raise StandardError.new("List iterator invalid due to structural modification of collection.") if comodified?
      do_do_set_current(obj)
    end

    def do_next
      raise StandardError.new("List iterator invalid due to structural modification of collection.") if comodified?
      do_do_next
    end

    def do_previous
      raise StandardError.new("List iterator invalid due to structural modification of collection.") if comodified?
      do_do_previous
    end

    def do_has_next?
      raise NoMethodError, "#{self.class} does not implement do_has_next?()"
    end

    def do_has_previous?
      raise NoMethodError, "#{self.class} does not implement do_has_previous?()"
    end

    def do_remove
      raise StandardError.new("List iterator invalid due to structural modification of collection.") if comodified?
      do_do_remove
    end

    def do_add_before(obj)
      raise StandardError.new("List iterator invalid due to structural modification of collection.") if comodified?
      do_do_add_before(obj)
    end

    def do_add_after(obj)
      raise StandardError.new("List iterator invalid due to structural modification of collection.") if comodified?
      do_do_add_after(obj)
    end

    def do_do_current  
      raise NoMethodError, "#{self.class} does not implement do_do_current()"
    end

    def do_do_current_index
      raise NoMethodError, "#{self.class} does not implement do_do_current_index()"
    end

    def do_do_set_current(obj)
      raise NoMethodError, "#{self.class} does not implement do_do_set_current()"
    end

    def do_do_next
      raise NoMethodError, "#{self.class} does not implement do_do_next()"
    end

    def do_do_previous
      raise NoMethodError, "#{self.class} does not implement do_do_previous()"
    end

    def do_do_remove
      raise NoMethodError, "#{self.class} does not implement do_do_remove()"
    end

    def do_do_add_before(obj)
      raise NoMethodError, "#{self.class} does not implement do_do_add_before()"
    end

    def do_do_add_after(obj)
      raise NoMethodError, "#{self.class} does not implement do_do_add_after()"
    end
  end

  class RandomAccessListListIterator < MutableListListIterator
    def initialize(list, start)
      super(list)
      raise ArgumentError.new("Invalid index: #{start}") unless (start >= 0  &&  start < [@list.size, 1].max)
      @cursor = start
    end

    def type
      @list.type
    end

    def empty?
      @list.empty?
    end

    private
    def do_has_next?
      @cursor < @list.size - 1
    end

    def do_has_previous?
      @cursor > 0
    end

    def do_do_current
      @list[@cursor]
    end

    def do_do_current_index
      @cursor
    end

    def do_do_set_current(obj)
      @list[@cursor] = obj
    end

    def do_do_next
      if has_next?
        @cursor += 1
      else
        nil
      end
    end

    def do_do_previous
      if has_previous?
        @cursor -= 1
      else
        nil
      end
    end

    def do_do_remove
      index = @cursor
      if has_previous? and !has_next?
        @cursor -= 1
      end

      result = @list.delete(index)
      count_modification

      result
    end
    
    def do_do_add_before(obj)
      if empty?
        @list.add(obj)
      else
        @list.insert(@cursor, obj)
        @cursor += 1
      end

      count_modification
    end

    def do_do_add_after(obj)
      if empty?
        @list.add(obj)
      else
        @list.insert(@cursor+1, obj)
      end

      count_modification
    end
  end

  class SinglyLinkedListListIterator < MutableListListIterator
    def initialize(list, start)
      super(list)
      raise ArgumentError.new("Invalid index: #{start}") unless (start >= 0  &&  start < [@list.size, 1].max)
      @cursor = @list.store
      @index = 0
      @history = LinkedStack.new

      start.times do
        next
      end
    end

    def type
      @list.type
    end

    def empty?
      @list.empty?
    end

    private
    def initialize_cursor
      @cursor = @list.store
    end

    def do_has_next?
      initialize_cursor if @cursor.nil?
      !@cursor.rest.nil?
    end

    def do_has_previous?
      initialize_cursor if @cursor.nil?
      @cursor != @list.store
    end

    def do_do_current
      initialize_cursor if @cursor.nil?
      @cursor.first
    end

    def do_do_current_index
      initialize_cursor if @cursor.nil?
      @index
    end

    def do_do_set_current(obj)
      initialize_cursor if @cursor.nil?
      @cursor.first = obj
    end

    def do_do_next
      initialize_cursor if @cursor.nil?
      if has_next?
        @history.push(@cursor)
        @cursor = @cursor.rest
        @index += 1
        current
      else
        nil
      end
    end

    def do_do_previous
      initialize_cursor if @cursor.nil?
      if has_previous?
        @cursor = @history.pop
        @index -= 1
        current
      else
        nil
      end
    end

    def do_do_remove
      initialize_cursor if @cursor.nil?

      if @index.zero?
        result = @list.delete_node(@cursor)
        initialize_cursor
      else
        parent = @history.peek
        if has_next?
          @cursor = @cursor.rest
        else
          @cursor = @history.pop
          @index -= 1
        end

        result = @list.delete_child(parent)
      end

      count_modification
      result
    end
    
    def do_do_add_before(obj)
      if empty?
        @list.add(obj)
        initialize_cursor
      else
        @list.insert_before(@cursor, obj)
        @history.push(@cursor)
        @cursor = @cursor.rest
        @index += 1
      end

      count_modification
    end

    def do_do_add_after(obj)
      if empty?
        @list.add(obj)
        initialize_cursor
      else
        @list.insert_after(@cursor, obj)
      end

      count_modification
    end
  end
end
