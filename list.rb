# coding: utf-8
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
#    TODO:
#    -Tests!!
#
#    No distinction between type of list and type of `fill_elt`??? Compare Lisp...
#
#    Array syntax is convenient and consistent with arrays/hashes. But assignment
#    is problematic for PersistentList, which must return new instance rather than
#    RHS.
#    l[i] vs. l.get(i)
#    l[i] = x vs. l.set(i, x)
#    

module Containers
  class RemoteControl
    def initialize(interface)
      @interface = interface
    end

    def press(method, *args)
      @interface[method].call(*args)
    end
  end
  
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

    def equals(list, test: ->(x, y) {x == y})
      if list.is_a?(PersistentList) # ???????????????????????
        list.equals(self, test: ->(x, y) { test.call(y, x) })
      elsif list.size == self.size
        i1 = self.iterator
        i2 = list.iterator

        until i1.done?  &&  i2.done?
          return false unless test.call(i1.current, i2.current)
          i1.next
          i2.next
        end

        true
      else
        false
      end
    end
     
    alias == equals

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

      do_add(objs)
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

#    def [](i)
    def get(i)
      if i.negative?
        j = i + size
        if j.negative?
          nil
        else
          #          self[j]
          get(j)
        end
      elsif i >= size
        nil
      else
        do_get(i)
      end
    end

#    def []=(i, obj)
    def set(i, obj)
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)

      if i.negative?
        j = i + size
        unless j.negative?
          #          self[j] = obj
          set(j, obj)
        end
      elsif i >= size
        extend_list(i, obj)
      else
        do_set(i, obj)
      end
    end
    
    def index(obj, test: ->(x, y) {x == y})
      raise ArgumentError.new("#{obj} is not of type #{type}") unless obj.is_a?(type)
      do_index(obj, test)
    end
    
    def slice(i, n=nil)
      if i.negative?
        j = i + size
        if j.negative?
          slice(0, 0)
        else
          slice(j, n)
        end
      elsif n.nil?
        do_slice(i, size - i)
      elsif n.negative?
        raise ArgumentError.new("Slice count must be non-negative: #{n}")
      else
        do_slice(i, n)
      end
    end

    private
    def do_add(objs)
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

    def do_index(obj, test)
      raise NoMethodError, "#{self.class} does not implement do_index()"
    end

    def do_slice(i, n)
      raise NoMethodError, "#{self.class} does not implement do_slice()"
    end
  end

  class MutableList < List
#    attr_reader :modification_count

    def initialize(type, fill_elt)
      super(type, fill_elt)
      @modification_count = 0
    end

    def clear
      count_modification
      do_clear
    end

    private
    def count_modification
      @modification_count += 1
    end

    def do_clear
      raise NoMethodError, "#{self.class} does not implement do_clear()"
    end

    def do_add(objs)
      unless objs.empty?
        count_modification
        do_do_add(objs)
      end
    end

    def do_insert(i, obj)
      count_modification
      do_do_insert(i, obj)
    end

    def do_delete(i)
      count_modification
      do_do_delete(i)
    end

    def do_do_add(objs)
      raise NoMethodError, "#{self.class} does not implement do_do_add()"
    end

    def do_do_insert(i, obj)
      raise NoMethodError, "#{self.class} does not implement do_do_insert()"
    end

    def do_do_delete(i)
      raise NoMethodError, "#{self.class} does not implement do_do_delete()"
    end
  end
  
  class MutableLinkedList < MutableList
    def initialize(type, fill_elt)
      super(type, fill_elt)
    end

    ##########################################Structural modification############################
    def insert_before(node, obj)
      if !obj.is_a?(type)
        raise ArgumentError.new("#{obj} is not of type #{type}")
      elsif node.nil?
        raise ArgumentError.new("Invalid node")
      else
        do_insert_before(node, obj)
        count_modification
      end
    end
    
    def insert_after(node, obj)
      if !obj.is_a?(type)
        raise ArgumentError.new("#{obj} is not of type #{type}")
      elsif node.nil?
        raise ArgumentError.new("Invalid node")
      else
        do_insert_after(node, obj)
        count_modification
      end
    end

    def delete_node(node)
      raise ArgumentError.new("Invalid node") if node.nil?
      doomed = do_delete_node(node)
      count_modification

      doomed
    end

    def delete_child(parent)
      raise ArgumentError.new("Invalid node") if parent.nil?
      child = do_delete_child(parent)
      count_modification

      child
    end

    private
    def do_insert_before(node, obj)
      raise NoMethodError, "#{self.class} does not implement do_insert_before()"
    end
      
    def do_insert_after(node, obj)
      raise NoMethodError, "#{self.class} does not implement do_insert_after()"
    end

    def do_delete_node(node)
      raise NoMethodError, "#{self.class} does not implement do_delete_node()"
    end

    def do_delete_child(parent)
      raise NoMethodError, "#{self.class} does not implement do_delete_child()"
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
      cursor = 0
      MutableCollectionIterator.new(modification_count: ->() {@modification_count},
                                    done: ->() {cursor == size},
                                    current: ->() {get(cursor)},
                                    advance: ->() {cursor += 1})
    end
    
    def list_iterator(start=0)
      RandomAccessListListIterator.new(list: self,
                                       start: start,
                                       remote_control:
                                         RemoteControl.new({:modification_count =>
                                                            ->() {@modification_count}}))
    end
    
    private
    def do_clear
      @store = []
    end

    def do_contains?(obj, test)
      @store.find(&->(elt) {test.call(obj, elt)})
    end

    def do_do_add(objs)
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
    
    def do_index(obj, test)
      @store.find_index(&->(elt) {test.call(obj, elt)})
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

  # class ArrayListX < MutableList
  #   def initialize(type=Object, fill_elt=nil)
  #     super(type, fill_elt)
  #     @store = []
  #     @offset = 0
  #   end

  #   def size
  #     @store.size - @offset
  #   end

  #   def empty?
  #     size.zero?
  #   end

  #   def iterator
  #     RandomAccessListIterator.new(self)
  #   end
    
  #   def list_iterator(start=0)
  #     RandomAccessListListIterator.new(self, start)
  #   end
    
  #   private
  #   def do_clear
  #     @store = []
  #     @offset = 0
  #   end

  #   def do_contains?(obj)
  #     @store[@offest..-1].include?(obj) # ???????
  #   end

  #   def do_do_add(*objs)
  #     @store += objs
  #   end

  #   def do_do_insert(i, obj)
  #     j = i + @offset

  #     if @offset.zero?  ||  size/2 > i
  #       @store.insert(j, obj)
  #     else
  #       @offset -= 1
  #       @store[@offset..j] = @store[@offset+1...j] # collapses element???
  #       @store[i+@offset] = obj
  #     end
  #   end
    
  #   def do_do_delete(i)
  #     j = i + @offset
  #     doomed = @store[j]

  #     if i <= size/2
  #       @store[@offset+1..j] = @store[@offset...j] # collapses element???
  #       @store[@offset] = fill_elt
  #       @offset += 1
  #     else
  #       @store.delete_at(i)
  #     end

  #     doomed
  #   end
    
  #   def do_get(i)
  #     @store[i+@offset]
  #   end

  #   def do_set(i, obj)
  #     @store[i+@offset] = obj
  #   end
    
  #   def do_index(obj)
  #     pos = @store.index(obj)
  #     if pos.nil?
  #       pos
  #     else
  #       pos + @offset
  #     end
  #   end

  #   #
  #   #    Returns empty ArrayList if negative i is too far
  #   #    vs. Array#slice => nil
  #   #    
  #   def do_slice(i, n)
  #     list = ArrayList.new(type, fill_elt)
  #     list.add(*(@store[i+@offset, n])) # Compare Common Lisp version to calculate what to add!
  #     list
  #   end
  # end

  class SinglyLinkedList < MutableLinkedList
#    attr_reader :store

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
      cursor = @store
      MutableCollectionIterator.new(modification_count: ->() {@modification_count},
                                    done: ->() {cursor.nil?},
                                    current: ->() {cursor.first},
                                    advance: ->() {cursor = cursor.rest})
    end
    
    def list_iterator(start=0)
      SinglyLinkedListListIterator.new(list: self,
                                       start: start,
                                       remote_control:
                                         RemoteControl.new({:modification_count =>
                                                            ->() {@modification_count},
                                                            :head_node =>
                                                            ->() {@store}}))
    end

    private
    def do_clear
      @store = nil
      @count = 0
    end

    def do_contains?(obj, test)
      Node.include?(@store, obj, test: test)
    end

    def do_do_add(objs)
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

    def do_do_insert(i, obj)
      Node.nthcdr(@store, i).splice_before(obj)
      @count += 1
    end

    def do_insert_before(node, obj)
      node.splice_before(obj)
      @count += 1
    end

    def do_insert_after(node, obj)
      node.splice_after(obj)
      @count += 1
    end

    def do_do_delete(i)
      if i.zero?
        result = @store.first
        @store = @store.rest
      else
        result = Node.nthcdr(@store, i - 1).excise_child
      end
      
      @count -= 1
      result
    end

    def do_delete_node(doomed)
      if doomed == @store
        result = @store.first
        @store = @store.rest
      else
        result = doomed.excise_node
      end

      @count -= 1
      result
    end

    def do_delete_child(parent)
      result = parent.excise_child
      
      @count -= 1
      result
    end

    def do_get(i)
      Node.nth(@store, i)
    end

    def do_set(i, obj)
      Node.set_nth(@store, i, obj)
    end

    def do_index(obj, test)
      Node.index(@store, obj, test: test)
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

  class SinglyLinkedListX < MutableLinkedList
#    attr_reader :front

    def initialize(type=Object, fill_elt=nil)
      super(type, fill_elt)
      @front = nil
      @rear = nil
      @count = 0
    end
    
    def size
      @count
    end

    def empty?
      @front.nil?
    end

    def iterator
      cursor = @front
      MutableCollectionIterator.new(modification_count: ->() {@modification_count},
                                    done: ->() {cursor.nil?},
                                    current: ->() {cursor.first},
                                    advance: ->() {cursor = cursor.rest})
    end
    
    def list_iterator(start=0)
      SinglyLinkedListListIterator.new(list: self,
                                       start: start,
                                       remote_control:
                                         RemoteControl.new({:modification_count =>
                                                            ->() {@modification_count},
                                                            :head_node =>
                                                            ->() {@front}}))
    end

    private
    def do_clear
      @front = nil
      @rear = nil
      @count = 0
    end

    def do_contains?(obj, test)
      Node.include?(@front, obj, test: test)
    end

    def do_do_add(objs)
      if self.empty?
        elt, *elts = objs
        @rear = @front = Node.new(elt, nil)
        @count += 1
        add_nodes(elts)
      else
        add_nodes(objs)
      end
    end

    def add_nodes(objs)
      objs.each do |obj|
        @rear = @rear.rest = Node.new(obj, nil)
      end

      @count += objs.size
    end

    def do_do_insert(i, obj)
      node = Node.nthcdr(@front, i)
      node.splice_before(obj)

      @rear = @rear.rest if node == @rear
      
      @count += 1
    end

    def do_insert_before(node, obj)
      node.splice_before(obj)

      @rear = @rear.rest if node == @rear
      
      @count += 1
    end

    def do_insert_after(node, obj)
      node.splice_after(obj)

      @rear = @rear.rest if node == @rear
      
      @count += 1
    end

    def do_do_delete(i)
      if i.zero?
        result = @front.first
        @front = @front.rest
        
        @rear = nil if @front.nil?
      else
        parent = Node.nthcdr(@front, i - 1)
        result = parent.excise_child

        @rear = parent if parent.rest.nil?
      end
      
      @count -= 1
      result
    end

    def do_delete_node(doomed)
      if doomed == @front
        result = @front.first
        @front = @front.rest
        
        @rear = nil if @front.nil?
      else
        result = doomed.excise_node

        @rear = doomed if doomed.rest.nil?
      end

      @count -= 1
      result
    end

    def do_delete_child(parent)
      result = parent.excise_child
      
      @rear = parent if parent.rest.nil?

      @count -= 1
      result
    end

    def do_get(i)
      Node.nth(@front, i)
    end

    def do_set(i, obj)
      Node.set_nth(@front, i, obj)
    end

    def do_index(obj, test)
      Node.index(@store, obj, test: test)
    end

    #
    #    Returns empty SinglyLinkedListX if negative i is too far
    #    vs. Array#slice => nil
    #    
    def do_slice(i, n)
      list = SinglyLinkedListX.new(type, fill_elt)
      start = [i, @count].min
      m = [i+n, @count].min - start
      slice = Node.slice(@front, start, m)

      list.add(*slice)
      list
    end
  end    

  class Dcons
    attr_accessor :content, :pred, :succ

    def initialize(content)
      @content = content
    end

    def to_s
      "<#{print_pred}#{@content}#{print_succ}>"
    end

    def link(succ)
      @succ = succ
      succ.pred = self
    end
    
    def splice_before(obj)
      new_dcons = Dcons.new(obj)
      self.pred.link(new_dcons)
      new_dcons.link(self)
    end
    
    def splice_after(obj)
      new_dcons = Dcons.new(obj)
      new_dcons.link(self.succ)
      self.link(new_dcons)
    end

    def excise_node
      if self == @succ
        raise StandardError.new("Cannot delete sole node.")
      else
        @pred.link(@succ)
      end

      @content
    end

    def excise_child
      child = @succ

      if self == child
        raise StandardError.new("Parent must have child node")
      else
        self.link(child.succ)
      end

      child.content
    end

    private
    def print_pred
      if @pred.nil?
        "∅ ← "
      elsif self == @pred
        "↻ "
      else
        "#{@pred.content} ← "
      end
    end

    def print_succ
      if @succ.nil?
        " → ∅"
      elsif self == @succ
        " ↺"
      else
        " → #{@succ.content}"
      end
    end
  end

  class Dcursor
#    protected ?!
    attr_reader :node
#    attr_accessor :index # ???? Needed for add_before??? 
    attr_reader :index # current_index

    def initialize(remote_control)
      @remote_control = remote_control
      @node = @remote_control.press(:head_node)
      @index = 0
    end

    def initialized?
      !@node.nil?
    end

    def start?
      !initialized?  ||  @index.zero?
    end

    def end?
      !initialized?  ||  @index == @remote_control.press(:size) - 1
    end

    def reset
      @index = 0
      @node = @remote_control.press(:head_node)
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

    #
    #    Bump cursor to next node without advancing index.
    #    Used when removing node.
    #    
    def bump
      if initialized?
        do_bump
      else
        raise StandardError.new("Cursor has not been initialized.")
      end
    end

    def nudge
      if initialized?
        do_nudge
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

      @index = @index % @remote_control.press(:size)
    end

    def do_rewind(step)
      raise ArgumentError.new("Step must be a positive value: #{step}") if step <= 0
      step.times do
        @index -= 1
        @node = @node.pred
      end

      @index = @index % @remote_control.press(:size)
    end

    def do_bump
      @node = @node.succ
    end

    def do_nudge
      @index += 1
    end
  end

  #
  #    Circular doubly-linked list w/ cursor to preserve recently accessed position
  #    
  class DoublyLinkedList < MutableLinkedList
#    protected
#    attr_reader :store
    
    def initialize(type=Object, fill_elt=nil)
      super(type, fill_elt)
      @store = nil
      @count = 0
      @cursor = setup_cursor
    end
    
    def size
      @count
    end
    
    def empty?
      @store.nil?
    end
    
    def iterator
      cursor = setup_cursor
      sealed_for_your_protection = true
      MutableCollectionIterator.new(modification_count: ->() {@modification_count},
                                    done: ->() {!cursor.initialized? ||
                                                (!sealed_for_your_protection && cursor.start?)},
                                    current: ->() {cursor.node.content}, # ???
                                    advance: ->() {cursor.advance; sealed_for_your_protection = false})
    end

    def list_iterator(start=0)
      DoublyLinkedListListIterator.new(list: self,
                                       start: start,
                                       remote_control:
                                         RemoteControl.new({:modification_count =>
                                                            ->() {@modification_count},
                                                            :initialize =>
                                                            ->() {setup_cursor}}))
    end

#    protected
#    attr_reader :head, :cursor

    private
    def setup_cursor
      Dcursor.new(RemoteControl.new({:head_node => ->() {@store},
                                     :size => ->() {@count}}))
    end

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

    # def nth_dcons(i)
    #   raise ArgumentError.new("Invalid index: #{i}") if (i < 0  ||  i >= size)

    #   if empty?
    #     raise ArgumentError.new("List is empty.")
    #   else
    #     index = @cursor.index
        
    #     if i.zero?
    #       @store
    #     elsif i == index
    #       @cursor.node
    #     elsif i < index / 2
    #       @cursor.reset
    #       @cursor.advance(i)
    #       @cursor.node
    #     elsif i < index
    #       @cursor.rewind(index - i)
    #       @cursor.node
    #     elsif i <= (size + index) / 2
    #       @cursor.advance(i - index)
    #       @cursor.node
    #     else
    #       @cursor.reset
    #       @cursor.rewind(size - i)
    #       @cursor.node
    #     end
    #   end
    # end

    def nth_dcons(i)
      if empty?
        raise ArgumentError.new("List is empty.")
      else
        raise ArgumentError.new("Invalid index: #{i}") if (i < 0  ||  i >= size)
        
        reposition_cursor(i)

        @cursor.node
      end
    end

    def reposition_cursor(i)
        index = @cursor.index
        
        if i.zero?
          @cursor.reset
        elsif i < index
          index_delta = index - i

          if i < index_delta
            @cursor.reset
            @cursor.advance(i)
          else
            @cursor.rewind(index_delta)
          end
        elsif i > index
          index_delta = i - index
          size_delta = size - i

          if index_delta <= size_delta
            @cursor.advance(index_delta)
          else
            @cursor.reset
            @cursor.rewind(size_delta)
          end
        end
    end

    # def do_contains?(obj)
    #   @count.times do |i|
    #     return true if self[i] == obj # This is reasonable due to cursor... Oops! Nope.
    #   end

    #   return false
    # end

    def do_contains?(obj, test)
      dcons = @store
      @count.times do
        return dcons.content if test.call(obj, dcons.content)
        dcons = dcons.succ
      end

      return nil
    end

    def do_do_add(objs)
      elt, *elts = objs
      dcons = Dcons.new(elt)
      if empty?
        @store = dcons
      else
        tail = @store.pred
        tail.link(dcons)
      end
      
      add_nodes(@store, dcons, elts)

      @cursor.reset unless @cursor.initialized?
    end

    def add_nodes(head, start, elts)
      dcons = start
      i = 1
      elts.each do |elt|
        dcons.link(Dcons.new(elt))
        dcons = dcons.succ
        i += 1
      end
      dcons.link(head)
      @count += i
    end

    def do_get(i)
      nth_dcons(i).content
    end

    def do_set(i, obj)
      nth_dcons(i).content = obj
    end

    def do_do_insert(i, obj)
      nth_dcons(i).splice_before(obj)

      if i.zero?
        @store = @store.pred
      end

      @count += 1

      if !@cursor.initialized?  ||
         i.between?(0, @cursor.index)  ||
         (i.negative? && (i + @count).between?(0, @cursor.index))
        @cursor.reset
      end
    end

    def do_insert_before(node, obj)
      node.splice_before(obj)

      if node == @store
        @store = @store.pred
      end
      
      @count += 1
#      @cursor.index += 1
      @cursor.reset
    end

    def do_insert_after(node, obj)
      node.splice_after(obj)
      @count += 1
      @cursor.reset
    end
    
    def do_do_delete(i)
      doomed = delete_dcons(nth_dcons(i))

      @count -= 1
      @cursor.reset
      
      doomed
    end

    def do_delete_node(doomed)
      result = delete_dcons(doomed)

      @count -= 1
      @cursor.reset
      
      result
    end

    #
    #    This is not really needed for DoublyLinkedList.
    #    
    def do_delete_child(parent)
      child = parent.succ

      if child == @store
        raise StandardError.new("Parent must have child node")
      else
        result = parent.excise_child

        @count -= 1
        @cursor.reset
      
        result
      end
    end

    def delete_dcons(doomed)
      if doomed == doomed.succ
        doomed.succ = nil # Release for GC
        @store = nil
        doomed.content
      else
        result = doomed.excise_node
        if doomed == @store
          @store = doomed.succ
        end

        result
      end
    end

    # def do_index(obj)
    #   @count.times do |i|
    #     return i if self[i] == obj # This is reasonable due to cursor D'oh!
    #   end

    #   return nil
    # end

    def do_index(obj, test)
      dcons = @store
      @count.times do |i|
        return i if test.call(obj, dcons.content)
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
      cursor = 0
      MutableCollectionIterator.new(modification_count: ->() {@modification_count},
                                    done: ->() {cursor == size},
                                    current: ->() {get(cursor)},
                                    advance: ->() {cursor += 1})
    end
    
    def list_iterator(start=0)
      RandomAccessListListIterator.new(list: self,
                                       start: start,
                                       remote_control:
                                         RemoteControl.new({:modification_count =>
                                                            ->() {@modification_count}}))
    end
    
    private
    def do_clear
      @store = {}
    end

    def do_contains?(obj, test)
      size.times do |i|
        elt = get(i)
        if test.call(obj, elt)
          return elt
        end
      end

      return nil
    end

    def do_do_add(objs)
      i = size
      objs.each do |obj|
        @store[i] = obj
        i += 1
      end
    end

    def do_do_insert(i, obj)
      size.downto(i+1) do |j|
        @store[j] = @store[j-1]
      end
      @store[i] = obj
    end

    def do_do_delete(i)
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
    
    def do_index(obj, test)
      size.times do |i|
        if test.call(obj, get(i))
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
        slice << get(j)
      end

      list.add(*slice)
      list
    end
  end

  class PersistentList < List
    attr_reader :store

    def initialize(type=Object, fill_elt=nil)
      super(type, fill_elt)
      @store = nil
      @count = 0
    end
    
    def to_s
      result = "("
      unless empty?
        i = iterator
        result << i.current.to_s

        i = i.next
        until i.done?
          result << " #{i.current.to_s}" # Invisible nil!
          i = i.next
        end
      end
      result << ")"
    end

    alias == equals
    def equals(list, test: ->(x, y) {x == y})
      if list.is_a?(PersistentList)
        pequals(list, test)
      else
        lequals(list, test)
      end
    end

    def each
      i = iterator
      until i.done?
        yield i.current
        i = i.next
      end
    end

    def size
      @count
    end

    def empty?
      @store.nil?
    end

    def clear
      PersistentList.new(@type, @fill_elt)
    end

    def iterator
      PersistentCollectionIterator.new(done: ->() {empty?},
                                       current: ->() {get(0)},
                                       advance: ->() {delete(0).iterator})
    end
    
    def list_iterator(start=0)
      PersistentListListIterator.new(list: self,
                                     start: start,
                                     remote_control:
                                       RemoteControl.new({:head_node => ->() {@store}}))
    end

    def delete(i)
      raise StandardError.new("List is empty.") if empty?

      if i >= @count 
        self
      elsif i < -@count
        self
      else
        super
      end
    end

    protected
    def store=(obj)
      @store = obj
    end

    def count=(n)
      @count = n
    end

    private
    def initialize_list(store, count)
      list = PersistentList.new(@type, @fill_elt)
      list.store = store
      list.count = count
      list
    end
    
    def pequals(list, test)
      if list.size == self.size
        i1 = self.iterator
        i2 = list.iterator

        until i1.done?  &&  i2.done?
          return false unless test.call(i1.current, i2.current)
          i1 = i1.next
          i2 = i2.next
        end

        true
      else
        false
      end
    end
     
    def lequals(list, test)
      if list.size == self.size
        i1 = self.iterator
        i2 = list.iterator

        until i1.done?  &&  i2.done?
          return false unless test.call(i1.current, i2.current)
          i1 = i1.next
          i2.next
        end

        true
      else
        false
      end
    end
     
    def do_contains?(obj, test)
      Node.include?(@store, obj, test: test)
    end

    def do_add(objs)
      if objs.empty?
        self
      else
        node = nil
        objs.reverse_each do |elt|
          node = Node.new(elt, node)
        end

        initialize_list(Node.append(@store, node), @count + objs.size)
      end
    end

    def adjust_node(store, i, adjustment)
      front = nil
      rear = nil
      node = @store
      
      i.times do |j|
        new_node = Node.new(node.first, nil)
        
        if front.nil?
          rear = front = new_node
        else
          rear = rear.rest = new_node
        end
        
        node = node.rest
      end
      
      tail = adjustment.call(node)
      
      if front.nil?
        front = tail
      else
        rear.rest = tail
      end
      
      front
    end

    def do_insert(i, obj)
      initialize_list(adjust_node(@store, i, ->(node) { Node.new(obj, node) }), @count + 1)
    end

    def do_delete(i)
      initialize_list(adjust_node(@store, i, ->(node) { node.rest }), @count - 1)
    end

    def do_get(i)
      Node.nth(@store, i)
    end

    def do_set(i, obj)
      initialize_list(adjust_node(@store, i, ->(node) { Node.new(obj, node.rest) }), @count)
    end
    
    def do_index(obj, test)
      Node.index(@store, obj, test: test)
    end
  end

  class ListIterator
    def initialize(list:, remote_control:)
      @list = list
      @remote_control = remote_control
    end
    
    def type
      @list.type
    end

    def empty?
      @list.empty?
    end

    def current
      raise StandardError.new("List is empty.") if empty?
      do_current
    end

    def current_index
      raise StandardError.new("List is empty.") if empty?
      do_current_index
    end

#    def current=(obj)
    def set_current(obj)
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
    def initialize(list:, remote_control:)
      super(list: list, remote_control: remote_control)
      @expected_modification_count = @remote_control.press(:modification_count)
    end
    
    def count_modification
      @expected_modification_count += 1
    end

    def has_next?
      check_comodification

      do_has_next?
    end

    def has_previous?
      check_comodification

      do_has_previous?
    end

    private
    def comodified?
      @expected_modification_count != @remote_control.press(:modification_count)
    end

    def check_comodification
      raise StandardError.new("List iterator invalid due to structural modification of collection.") if comodified?
    end

    def do_current
      check_comodification

      do_do_current
    end
    
    def do_current_index
      check_comodification

      do_do_current_index
    end

    def do_set_current(obj)
      check_comodification

      do_do_set_current(obj)
    end

    def do_next
      check_comodification

      do_do_next
    end

    def do_previous
      check_comodification

      do_do_previous
    end

    def do_has_next?
      raise NoMethodError, "#{self.class} does not implement do_has_next?()"
    end

    def do_has_previous?
      raise NoMethodError, "#{self.class} does not implement do_has_previous?()"
    end

    def do_remove
      check_comodification

      doomed = do_do_remove

      count_modification

      doomed
    end

    def do_add_before(obj)
      check_comodification

      do_do_add_before(obj)

      count_modification
    end

    def do_add_after(obj)
      check_comodification

      do_do_add_after(obj)

      count_modification
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
    def initialize(list:, remote_control:, start:)
      super(list: list, remote_control: remote_control)

      if start < 0 
        raise ArgumentError.new("Invalid index: #{start}")
      elsif list.empty?
        @cursor = 0
      else
        @cursor = [start, list.size - 1].min
      end
    end

    private
    def do_has_next?
      @cursor < @list.size - 1
    end

    def do_has_previous?
      @cursor > 0
    end

    def do_do_current
#      @list[@cursor]
      @list.get(@cursor)
    end

    def do_do_current_index
      @cursor
    end

    def do_do_set_current(obj)
#      @list[@cursor] = obj
      @list.set(@cursor, obj)
    end

    def do_do_next
      if has_next?
        @cursor += 1
        current
      else
        nil
      end
    end

    def do_do_previous
      if has_previous?
        @cursor -= 1
        current
      else
        nil
      end
    end

    def do_do_remove
      index = @cursor
      if has_previous? and !has_next?
        @cursor -= 1
      end

      @list.delete(index)
    end
    
    def do_do_add_before(obj)
      if empty?
        @list.add(obj)
      else
        @list.insert(@cursor, obj)
        @cursor += 1
      end
    end

    def do_do_add_after(obj)
      if empty?
        @list.add(obj)
      else
        @list.insert(@cursor+1, obj)
      end
    end
  end

  class SinglyLinkedListListIterator < MutableListListIterator
    def initialize(list:, remote_control:, start:)
      super(list: list, remote_control: remote_control)
      @cursor = initialize_cursor
      @index = 0
      @history = LinkedStack.new

      raise ArgumentError.new("Invalid index: #{start}") if start < 0 

      unless list.empty?
        [start, list.size - 1].min.times do
          self.next # !!!!
        end
      end
    end

    private
    def initialize_cursor
      @cursor = @remote_control.press(:head_node)
    end

    def do_has_next?
      !(@cursor.nil?  ||  @cursor.rest.nil?)
    end

    def do_has_previous?
      !(@cursor.nil?  ||  @cursor == @remote_control.press(:head_node))
    end

    def do_do_current
      @cursor.first
    end

    def do_do_current_index
      @index
    end

    def do_do_set_current(obj)
      @cursor.first = obj
    end

    def do_do_next
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
      if has_previous?
        @cursor = @history.pop
        @index -= 1
        current
      else
        nil
      end
    end

    def do_do_remove
      if @index.zero?
        doomed = @list.delete_node(@cursor)
        initialize_cursor
        doomed
      else
        parent = @history.peek
        if has_next?
          @cursor = @cursor.rest
        else
          @cursor = @history.pop
          @index -= 1
        end

        @list.delete_child(parent)
      end
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
    end

    def do_do_add_after(obj)
      if empty?
        @list.add(obj)
        initialize_cursor
      else
        @list.insert_after(@cursor, obj)
      end
    end
  end

  class DoublyLinkedListListIterator < MutableListListIterator
    def initialize(list:, remote_control:, start:)
      super(list: list, remote_control: remote_control)
      raise ArgumentError.new("Invalid index: #{start}") if start < 0 

      @cursor = @remote_control.press(:initialize)
      @cursor.advance([start, list.size - 1].min) unless start.zero?
    end

    private
    def do_has_next?
      !@cursor.end?
    end

    def do_has_previous?
      !@cursor.start?
    end

    def do_do_current
      @cursor.node.content
    end

    def do_do_current_index
      @cursor.index
    end

    def do_do_set_current(obj)
      @cursor.node.content = obj
    end

    def do_do_next
      if has_next?
        @cursor.advance
        current
      else
        nil
      end
    end

    def do_do_previous
      if has_previous?
        @cursor.rewind
        current
      else
        nil
      end
    end

    def do_do_remove
      if @cursor.index.zero?
        doomed = @list.delete_node(@cursor.node)
        @cursor.reset
        doomed
      else
        current_node = @cursor.node
        if has_next?
          @cursor.bump
        else
          @cursor.rewind
        end

        @list.delete_node(current_node)
      end
    end
    
    def do_do_add_before(obj)
      if empty?
        @list.add(obj)
        @cursor.reset
      else
        @list.insert_before(@cursor.node, obj)
        @cursor.nudge
      end
    end

    def do_do_add_after(obj)
      if empty?
        @list.add(obj)
        @cursor.reset
      else
        @list.insert_after(@cursor.node, obj)
      end
    end
  end

  class PersistentListListIterator < ListIterator
    def initialize(list:, remote_control:, start:)
      super(list: list, remote_control: remote_control)
      @list = list
      @cursor = @remote_control.press(:head_node)
      @index = 0
      @history = PersistentStack.new

      #
      #    Have to take different approach than CLOS??
      #    
      start.times do
        @history = @history.push(@cursor)
        @cursor = @cursor.rest
        @index += 1
      end
    end

    def has_next?
      !@cursor.rest.nil?
    end

    def has_previous?
      !@history.empty?
    end

    protected
    def initialize_iterator(index, cursor, history)
      iterator = PersistentListListIterator.new(list: @list, remote_control: @remote_control, start: 0) #??
      iterator.cursor = cursor
      iterator.index = index
      iterator.history = history
      iterator
    end

    def cursor=(cursor)
      @cursor = cursor
    end

    def index=(index)
      @index = index
    end

    def history=(history)
      @history = history
    end

    private
    def do_current
      @cursor.first
    end

    def do_current_index
      @index
    end

    def do_set_current(obj)
      @list.set(@index, obj).list_iterator(@index)
    end
    
    def do_next
      if has_next?
        initialize_iterator(@index+1, @cursor.rest, @history.push(@cursor))
      else
        nil
      end
    end

    def do_previous
      if has_previous?
        initialize_iterator(@index-1, @history.peek, @history.pop)
      else
        nil
      end
    end

    def do_remove
      list = @list.delete(@index)
      list.list_iterator([@index, list.size-1].min)
    end
    
    def do_add_before(obj)
      if empty?
        @list.add(obj).list_iterator
      else
        @list.insert(@index, obj).list_iterator(@index + 1)
      end
    end

    def do_add_after(obj)
      if empty?
        @list.add(obj).list_iterator
      else
        @list.insert(@index + 1, obj).list_iterator(@index)
      end
    end
  end
end
