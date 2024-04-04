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
  class List < Collection
    attr_reader :fill_elt
    
    def initialize(type: Object, fill_elt: nil)
      raise ArgumentError.new("Incompatible fill_elt type") unless fill_elt.is_a?(type)

      super(type: type)
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

    #
    #    `list` is a list? Problem with other collection types??
    #    
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
      if objs.empty?
        self
      elsif objs.all? {|obj| obj.is_a?(type)}
        do_add(objs)
      else
        raise ArgumentError.new("Type mismatch with objs")
      end
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

    def reverse
      reversed = []
      each {|elt| reversed.unshift(elt)}
      make_empty_list.add(*reversed)
    end
    
    def append(list)
      make_empty_list.add(*(collect_elements + list.collect_elements))
    end
    
    def fill(count: 1000, generator: ->(x) { x })
      add(*((1..count).map {|x| generator.call(x)}))
    end

    def elements
      collect_elements
    end

    protected
    def collect_elements
      elements = []
      each {|elt| elements.push(elt)}
      
      elements
      # elts = []
      # i = iterator

      # until i.done?
      #   elts.push(i.current)
      #   i.next
      # end

      # elts
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
      iter = iterator
      i = 0

      until iter.done?
        elt = iter.current
        return i if test.call(obj, elt)
        iter.next
        i += 1
      end

      return nil
    end

    def do_slice(i, n)
      list = make_empty_list
      list.add(*sublist([i, size].min, [i+n, size].min))

      list
    end

    # def sublist(m, n)
    #   result = []
    #   m.upto(n-1) do |i|
    #     result << get(i)
    #   end

    #   result
    # end
    
    def sublist(m, n)
      if m == n
        []
      else
        list_iterator = list_iterator(m)
        result = []

        (n-m).times do
          result << list_iterator.current
          list_iterator.next
        end

        result
      end
    end
  end

  class MutableList < List
    attr_reader :modification_count # Must be visible for testing??

    def initialize(type: Object, fill_elt: nil)
      super(type: type, fill_elt: fill_elt)
      @modification_count = 0
    end

    def do_clear
      do_do_clear
      count_modification
    end

    def elements
      elts = collect_elements
      clear

      elts
    end

    private
    def count_modification
      @modification_count += 1
    end

    def do_do_clear
      raise NoMethodError, "#{self.class} does not implement do_clear()"
    end

    def do_add(objs)
      do_do_add(objs)
      count_modification

      self
    end

    def do_insert(i, obj)
      do_do_insert(i, obj)
      count_modification
    end

    def do_delete(i)
      doomed = do_do_delete(i)
      count_modification

      doomed
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
    def initialize(type: Object, fill_elt: nil)
      super(type: type, fill_elt: fill_elt)
    end

    ##########################################Structural modification############################
    def insert_before(node, obj)
      if !obj.is_a?(type)
        raise ArgumentError.new("#{obj} is not of type #{type}")
      elsif empty?
        raise ArgumentError.new("List is empty")
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

    def delete_node(doomed)
      raise ArgumentError.new("Invalid node") if doomed.nil?
      result = do_delete_node(doomed)
      count_modification

      result
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
    def initialize(type: Object, fill_elt: nil)
      super(type: type, fill_elt: fill_elt)
      @store = []
    end

    def size
      @store.size
    end

    def empty?
      @store.empty?
    end

    # def iterator
    #   cursor = 0
    #   MutableCollectionIterator.new(modification_count: ->() {@modification_count},
    #                                 done: ->() {cursor == size},
    #                                 current: ->() {get(cursor)},
    #                                 advance: ->() {cursor += 1})
    # end
    # def iterator
    #   cursor = 0
    #   MutableCollectionIterator.new(modification_count: ->() {@modification_count},
    #                                 cursor: Cursor.new(done: ->() {cursor == size},
    #                                                    current: ->() {get(cursor)},
    #                                                    advance: ->() {cursor += 1}))
    # end
    def iterator
      MutableCollectionIterator.new(modification_count: ->() {@modification_count},
                                    cursor: Cursor.make_random_access_list_cursor(self))
    end
    
    def list_iterator(start=0)
      RandomAccessListListIterator.new(list: self,
                                       start: start,
                                       modification_count: ->() {@modification_count})
    end

    def reverse
      make_empty_list.add(*@store.reverse)
    end

    private
    def do_do_clear
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
    # def do_slice(i, n)
    #   list = ArrayList.new(type: type, fill_elt: fill_elt)
    #   list.add(*(@store[i, n])) # Compare Common Lisp version to calculate what to add!
    #   list
    # end

    def make_empty_list
      ArrayList.new(type: type, fill_elt: fill_elt)
    end

    def sublist(m, n)
      @store[m, n - m]
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
  #   def do_do_clear
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
    attr_reader :store # Must be visible for testing??

    def initialize(type: Object, fill_elt: nil)
      super(type: type, fill_elt: fill_elt)
      @store = nil
      @count = 0
    end
    
    def size
      @count
    end

    def empty?
      @store.nil?
    end

    # def iterator
    #   cursor = @store
    #   MutableCollectionIterator.new(modification_count: ->() {@modification_count},
    #                                 done: ->() {cursor.nil?},
    #                                 current: ->() {cursor.first},
    #                                 advance: ->() {cursor = cursor.rest})
    # end

    def iterator
      MutableCollectionIterator.new(modification_count: ->() {@modification_count},
                                    cursor: Cursor.make_singly_linked_list_cursor(@store))
    end

    def list_iterator(start=0)
      SinglyLinkedListListIterator.new(list: self,
                                       start: start,
                                       modification_count: ->() {@modification_count},
                                       head: ->() {@store})
    end

    private
    def do_do_clear
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
    # def do_slice(i, n)
    #   list = SinglyLinkedList.new(type: type, fill_elt: fill_elt)
    #   start = [i, @count].min
    #   m = [i+n, @count].min - start
    #   slice = Node.slice(@store, start, m)

    #   list.add(*slice)
    #   list
    # end

    def make_empty_list
      SinglyLinkedList.new(type: type, fill_elt: fill_elt)
    end

    def sublist(m, n)
      Node.slice(@store, m, n - m)
    end
  end    

  class SinglyLinkedListX < MutableLinkedList
    attr_reader :front # Must be visible for testing??

    def initialize(type: Object, fill_elt: nil)
      super(type: type, fill_elt: fill_elt)
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

    # def iterator
    #   cursor = @front
    #   MutableCollectionIterator.new(modification_count: ->() {@modification_count},
    #                                 done: ->() {cursor.nil?},
    #                                 current: ->() {cursor.first},
    #                                 advance: ->() {cursor = cursor.rest})
    # end
    
    def iterator
      MutableCollectionIterator.new(modification_count: ->() {@modification_count},
                                    cursor: Cursor.make_singly_linked_list_cursor(@front))
    end

    def list_iterator(start=0)
      SinglyLinkedListListIterator.new(list: self,
                                       start: start,
                                       modification_count: ->() {@modification_count},
                                       head: ->() {@store})
    end

    private
    def do_do_clear
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
      Node.index(@front, obj, test: test)
    end

    #
    #    Returns empty SinglyLinkedListX if negative i is too far
    #    vs. Array#slice => nil
    #    
    # def do_slice(i, n)
    #   list = SinglyLinkedListX.new(type: type, fill_elt: fill_elt)
    #   start = [i, @count].min
    #   m = [i+n, @count].min - start
    #   slice = Node.slice(@front, start, m)

    #   list.add(*slice)
    #   list
    # end

    def make_empty_list
      SinglyLinkedListX.new(type: type, fill_elt: fill_elt)
    end

    def sublist(m, n)
      Node.slice(@front, m, n - m)
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

    def unlink
      @succ = nil
      @pred = nil
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

    def initialize(head:, size:, pred:, succ:)
      @head = head
      @size = size
      @node = @head.call
      @index = 0
      @succ = succ
      @pred = pred
    end

    def initialized?
      !@node.nil?
    end

    def reset
      @index = 0
      @node = @head.call
    end
      
    def start?
      !initialized?  ||  @index.zero?
    end

    def end?
      !initialized?  ||  @index == @size.call - 1
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
        @node = @succ.call(@node)
      end

      @index = @index % @size.call
    end

    def do_rewind(step)
      raise ArgumentError.new("Step must be a positive value: #{step}") if step <= 0
      step.times do
        @index -= 1
        @node = @pred.call(@node)
      end

      @index = @index % @size.call
    end

    def do_bump
      @node = @succ.call(@node)
    end

    def do_nudge
      @index += 1
    end
  end

  class DcursorB < Dcursor
    private
    def do_advance(step)
      raise ArgumentError.new("Step must be a positive value: #{step}") if step <= 0
      step.times do
        @index += 1
        @node = @pred.call(@node)
      end

      @index = @index % @size.call
    end

    def do_rewind(step)
      raise ArgumentError.new("Step must be a positive value: #{step}") if step <= 0
      step.times do
        @index -= 1
        @node = @succ.call(@node)
      end

      @index = @index % @size.call
    end

    def do_bump
      @node = @pred.call(@node)
    end
  end

  #
  #    Circular doubly-linked list w/ cursor to preserve recently accessed position
  #    
  class DcursorList < MutableLinkedList
    def initialize(type: Object, fill_elt: nil)
      super(type: type, fill_elt: fill_elt)
      @cursor = setup_cursor
    end

    protected
    attr_reader :cursor

    def setup_cursor
      raise NoMethodError, "#{self.class} does not implement setup_cursor()"
    end
      
    def nth_dll_node(n)
      if empty?
        raise ArgumentError.new("List is empty.")
      else
        raise ArgumentError.new("Invalid index: #{n}") if (n < 0  ||  n >= size)
        
        reposition_cursor(@cursor, n, size)

        @cursor.node
      end
    end

    private
    def reposition_cursor(cursor, i, count)
        index = cursor.index
        
        if i.zero?
          cursor.reset
        elsif i < index
          index_delta = index - i
          start_delta = i

          if start_delta < index_delta
            cursor.reset
            cursor.advance(start_delta)
          else
            cursor.rewind(index_delta)
          end
        elsif i > index
          index_delta = i - index
          end_delta = count - i

          if index_delta <= end_delta
            cursor.advance(index_delta)
          else
            cursor.reset
            cursor.rewind(end_delta)
          end
        end
    end

    def do_get(i)
      nth_dll_node(i).content
    end

    def do_set(i, obj)
      nth_dll_node(i).content = obj
    end

    def do_do_add(objs)
      add_elements(objs)

      @cursor.reset unless @cursor.initialized?
    end

    def add_elements(objs)
      raise NoMethodError, "#{self.class} does not implement add_elements()"
    end

    def do_do_insert(i, obj)
      insert_elt(i, obj) # Have to design ahead of time!!

      if !@cursor.initialized?  ||
         i.between?(0, @cursor.index)  ||
         (i.negative? && (i + @count).between?(0, @cursor.index))
        @cursor.reset
      end
    end

    def insert_elt(i, obj)
      raise NoMethodError, "#{self.class} does not implement insert_elt()"
    end

    def do_insert_before(node, obj)
      insert_elt_before(node, obj)
      
      @cursor.reset
    end

    def insert_elt_before(node, obj)
      raise NoMethodError, "#{self.class} does not implement insert_elt_before()"
    end

    def do_insert_after(node, obj)
      insert_elt_after(node, obj)
      
      @cursor.reset
    end
    
    def insert_elt_after(node, obj)
      raise NoMethodError, "#{self.class} does not implement insert_elt_after()"
    end

    def do_do_delete(i)
      doomed = delete_elt(i)
      @cursor.reset
      
      doomed
    end

    def delete_elt(i)
      raise NoMethodError, "#{self.class} does not implement delete_elt()"
    end

    def do_delete_node(doomed)
      result = do_do_delete_node(doomed)
      @cursor.reset
      
      result
    end

    def do_do_delete_node(doomed)
      raise NoMethodError, "#{self.class} does not implement do_do_delete_node()"
    end

    def do_delete_child(parent)
      result = do_do_delete_child(parent)
      @cursor.reset
      
      result
    end

    def do_do_delete_child(parent)
      raise NoMethodError, "#{self.class} does not implement do_do_delete_child()"
    end
  end
  
  class DoublyLinkedList < DcursorList
    attr_reader :store # Must be visible for testing??

    def initialize(type: Object, fill_elt: nil)
      super(type: type, fill_elt: fill_elt)
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
      MutableCollectionIterator.new(modification_count: ->() {@modification_count},
                                    cursor: Cursor.make_doubly_linked_list_cursor(setup_cursor))
    end

    def list_iterator(start=0)
      DoublyLinkedListListIterator.new(list: self,
                                       start: start,
                                       modification_count: ->() {@modification_count},
                                       init: ->() {setup_cursor})
    end

    private
    def setup_cursor
      Dcursor.new(head: ->() {@store},
                  size: ->() {@count},
                  pred: ->(node) {node.pred}, # Can't send method itself?? #'pred
                  succ: ->(node) {node.succ})
    end

    # def clear
    #   @store = nil # Memory leak?!
    #   @count = 0
    #   @head.reset
    #   @cursor.reset
    # end

    def do_do_clear
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

    # def do_contains?(obj)
    #   @count.times do |i|
    #     return true if self[i] == obj # This is reasonable due to cursor... Oops! Nope.
    #   end

    #   return false
    # end

    # def do_contains?(obj, test)
    #   dcons = @store
    #   @count.times do
    #     return dcons.content if test.call(obj, dcons.content)
    #     dcons = dcons.succ
    #   end

    #   return nil
    # end

    def add_elements(objs)
      elt, *elts = objs
      dcons = Dcons.new(elt)
      if empty?
        @store = dcons
      else
        tail = @store.pred
        tail.link(dcons)
      end
      
      add_nodes(dcons, elts)
    end

    def add_nodes(start, elts)
      dcons = start
      i = 1
      elts.each do |elt|
        dcons.link(Dcons.new(elt))
        dcons = dcons.succ
        i += 1
      end

      dcons.link(@store)
      @count += i
    end

    def insert_elt(i, obj)
      nth_dll_node(i).splice_before(obj)

      if i.zero?
        @store = @store.pred
      end

      @count += 1
    end

    def insert_elt_before(node, obj)
      do_insert_elt_before(node, obj)
      
      @count += 1
    end

    def do_insert_elt_before(node, obj)
      node.splice_before(obj)

      if node == @store
        @store = @store.pred
      end
    end      

    def insert_elt_after(node, obj)
      do_insert_elt_after(node, obj)
      
      @count += 1
    end
    
    def do_insert_elt_after(node, obj)
      node.splice_after(obj)
    end
    
    def delete_elt(i)
      doomed = delete_dcons(nth_dll_node(i))

      @count -= 1
      
      doomed
    end

    def do_do_delete_node(doomed)
      result = delete_dcons(doomed)

      @count -= 1
      
      result
    end

    #
    #    This is not really needed for DoublyLinkedList.
    #    
    def do_do_delete_child(parent)
      result = delete_child_node(parent)

      @count -= 1
      
      result
    end

    def delete_child_node(parent)
      child = parent.succ

      if child == @store
        raise StandardError.new("Parent must have child node")
      else
        parent.excise_child
      end
    end

    def delete_dcons(doomed, reset_store = ->(node) {node.succ})
      if doomed == doomed.succ
        doomed.succ = nil # Release for GC
        @store = nil
        doomed.content
      else
        result = doomed.excise_node
        if doomed == @store
          @store = reset_store.call(doomed)
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

    # def do_index(obj, test)
    #   dcons = @store
    #   @count.times do |i|
    #     return i if test.call(obj, dcons.content)
    #     dcons = dcons.succ
    #   end

    #   return nil
    # end

    #
    #    Inclusive `i`, exclusive `j`
    #    
#    def subseq(i, j)
    # def sublist(i, j)
    #   result = []
      
    #   if i < j
    #     dcons = nth_dll_node(i)
    #     (i...j).each do
    #       result << dcons.content
    #       dcons = dcons.succ
    #     end
    #   end

    #   result
    # end

    #
    #    Returns empty DoublyLinkedList if negative i is too far
    #    vs. Array#slice => nil
    #    
    # def do_slice(i, n)
    #   list = make_empty_list
    #   slice = subseq([i, @count].min, [i+n, @count].min)

    #   list.add(*slice)
    #   list
    # end

    def make_empty_list
      DoublyLinkedList.new(type: type, fill_elt: fill_elt)
    end
  end

  class DoublyLinkedListRatchet < DoublyLinkedList
    def initialize(type: Object, fill_elt: nil, direction: :forward)
      @direction = direction
      super(type: type, fill_elt: fill_elt) # super() call out of order?!?
    end

    def reverse
      count_modification
      do_reverse
    end

    private
    def setup_cursor
      case @direction
      when :forward
        Dcursor.new(head: ->() {@store},
                    size: ->() {@count},
                    pred: ->(node) {node.pred},
                    succ: ->(node) {node.succ})
      when :backward
        DcursorB.new(head: ->() {@store},
                     size: ->() {@count},
                     pred: ->(node) {node.pred},
                     succ: ->(node) {node.succ})
      end
    end

    def ratchet_forward(node)
      case @direction
      when :forward then node.succ
      when :backward then node.pred
      end
    end

#    def ratchet_forward=(node, obj)
    def set_ratchet_forward(node, obj)
      case @direction
      when :forward then node.succ = obj
      when :backward then node.pred = obj
      end
    end

    def ratchet_backward(node)
      case @direction
      when :forward then node.pred
      when :backward then node.succ
      end
    end

#    def ratchet_backward=(node, obj)
    def set_ratchet_backward(node, obj)
      case @direction
      when :forward then node.pred = obj
      when :backward then node.succ = obj
      end
    end

    def ratchet_dlink(node1, node2)
      case @direction
      when :forward then node1.link(node2)
      when :backward then node2.link(node1)
      end
    end

    def do_do_clear
      unless empty?
        dcons = @store
        @count.times do
          set_ratchet_backward(dcons, nil)
          dcons = ratchet_forward(dcons)
        end

        set_ratchet_forward(@store, nil)
        @store = nil
        @count = 0
        @cursor.reset
      end
    end

    def add_elements(objs)
      elt, *elts = objs
      dcons = Dcons.new(elt)
      if empty?
        @store = dcons
      else
        add_node_to_end(ratchet_backward(@store), dcons)
      end
      
      add_nodes(dcons, elts)
    end

    def add_node_to_end(previous_end, new_end)
      ratchet_dlink(previous_end, new_end)
    end
    
    def add_nodes(start, elts)
      dcons = start
      i = 1
      elts.each do |elt|
        add_node_to_end(dcons, Dcons.new(elt))
        dcons = ratchet_forward(dcons)
        i += 1
      end

      ratchet_dlink(dcons, @store)
      @count += i
    end

    def insert_elt(i, obj)
      case @direction
      when :forward then nth_dll_node(i).splice_before(obj)
      when :backward then nth_dll_node(i).splice_after(obj)
      end

      if i.zero?
        @store = ratchet_backward(@store)
      end

      @count += 1
    end

    def do_insert_elt_before(node, obj)
      case @direction
      when :forward then node.splice_before(obj)
      when :backward then node.splice_after(obj)
      end

      if node == @store
        @store = ratchet_backward(@store)
      end
    end

    def do_insert_elt_after(node, obj)
      case @direction
      when :forward then node.splice_after(obj)
      when :backward then node.splice_before(obj)
      end
    end
    
    def delete_elt(i)
      doomed = delete_ratchet_node(nth_dll_node(i))

      @count -= 1
      
      doomed
    end

    def do_do_delete_node(doomed)
      result = delete_ratchet_node(doomed)

      @count -= 1
      
      result
    end

    def delete_ratchet_node(doomed)
      case @direction
      when :forward then delete_dcons(doomed, ->(node) {node.succ})
      when :backward then delete_dcons(doomed, ->(node) {node.pred})
      end
    end

    #
    #    This is not really needed for DoublyLinkedList.
    #    
    def delete_child_node(parent)
      child = ratchet_forward(parent)

      if child == @store
        raise StandardError.new("Parent must have child node")
      else
        result = child.content
        ratchet_dlink(parent, ratchet_forward(child))

        result
      end
    end

    #
    #    Inclusive `i`, exclusive `j`
    #    
#    def subseq(i, j)
    # def sublist(i, j)
    #   result = []
      
    #   if i < j
    #     dcons = nth_dll_node(i)
    #     (i...j).each do
    #       result << dcons.content
    #       dcons = ratchet_forward(dcons)
    #     end
    #   end

    #   result
    # end

    def make_empty_list
      DoublyLinkedListRatchet.new(type: type, fill_elt: fill_elt, direction: @direction)
    end

    def do_reverse
      case @direction
      when :forward then @direction = :backward
      when :backward then @direction = :forward
      end

      unless empty?
        @store = ratchet_forward(@store)
      end

      @cursor = setup_cursor

      self
    end
  end

  class Dnode
    attr_accessor :content

    def initialize(content)
      @content = content
    end

    def to_s
      "<#{@content}>"
    end
  end

  #
  #    Circular "doubly-linked list" w/ cursor to preserve recently accessed position
  #    Links are stored in two hash tables.
  #    
  class DoublyLinkedListHash < DcursorList
    attr_reader :head # Must be visible for testing??

    def initialize(type: Object, fill_elt: nil)
      super(type: type, fill_elt: fill_elt)
      @head = nil
      @forward = {}
      @backward = {}
    end
      
    def size
      @forward.size
    end
    
    def empty?
      @head.nil?
    end
    
    def iterator
      MutableCollectionIterator.new(modification_count: ->() {@modification_count},
                                    cursor: Cursor.make_doubly_linked_list_cursor(setup_cursor))
    end

    def list_iterator(start=0)
      DoublyLinkedListListIterator.new(list: self,
                                       start: start,
                                       modification_count: ->() {@modification_count},
                                       init: ->() {setup_cursor})
    end

    def reverse
      count_modification
      do_reverse
    end

#    protected
    def next_dnode(node) # Must be visible for testing??
      @forward[node]
    end

    def previous_dnode(node)
      @backward[node]
    end

    private
    def setup_cursor
        Dcursor.new(head: ->() {@head},
                    size: ->() {size},
                    pred: ->(node) {previous_dnode(node)},
                    succ: ->(node) {next_dnode(node)})
    end

    def set_next_dnode(node, obj)
      @forward[node] = obj
    end

    def set_previous_dnode(node, obj)
      @backward[node] = obj
    end

    def link_dnodes(pred, succ)
      set_next_dnode(pred, succ)
      set_previous_dnode(succ, pred)
    end

    def splice_dnode_before(node, obj)
      new_dnode = Dnode.new(obj)
      link_dnodes(previous_dnode(node), new_dnode)
      link_dnodes(new_dnode, node)
    end

    def splice_dnode_after(node, obj)
      new_dnode = Dnode.new(obj)
      link_dnodes(new_dnode, next_dnode(node))
      link_dnodes(node, new_dnode)
    end

    def excise_dnode(doomed)
      if doomed == next_dnode(doomed)
        raise StandardError.new("Cannot delete sole node.")
      else
        link_dnodes(previous_dnode(doomed), next_dnode(doomed))
        doomed.content
      end
    end
    
    def excise_child_dnode(parent)
      child = next_dnode(parent)

      if @head == child
        raise StandardError.new("Parent must have child node")
      else
        link_dnodes(parent, next_dnode(child))
        child.content
      end
    end

    def do_do_clear
        @head = nil
        @forward.clear
        @backward.clear
        @cursor.reset
    end

    def add_elements(objs)
      elt, *elts = objs
      dnode = Dnode.new(elt)
      if empty?
        @head = dnode
      else
        link_dnodes(previous_dnode(@head), dnode)
      end
      
      add_nodes(dnode, elts)
    end

    def add_nodes(start, elts)
      dnode = start
      i = 1
      elts.each do |elt|
        link_dnodes(dnode, Dnode.new(elt))
        dnode = next_dnode(dnode)
        i += 1
      end

      link_dnodes(dnode, @head)
    end

    def insert_elt(i, obj)
      splice_dnode_before(nth_dll_node(i), obj)

      if i.zero?
        @head = previous_dnode(@head)
      end
    end

    def insert_elt_before(node, obj)
      splice_dnode_before(node, obj)

      if node == @head
        @head = previous_dnode(@head)
      end
    end      

    def insert_elt_after(node, obj)
      splice_dnode_after(node, obj)
    end
    
    def delete_elt(i)
      delete_dnode(nth_dll_node(i))
    end

    def do_delete_node(doomed)
      delete_dnode(doomed)
    end

    #
    #    This is not really needed for DoublyLinkedList.
    #    
    def do_do_delete_child(parent)
      child = next_dnode(parent)

      if child == @head
        raise StandardError.new("Parent must have child node")
      else
        result = excise_child_dnode(parent)
        @forward.delete(child)
        @backward.delete(child)

        result
      end
    end

    def delete_dnode(doomed)
      result = doomed.content
      if doomed == next_dnode(doomed)
        set_next_dnode(doomed, nil) # Release for GC
        @head = nil
      else
        excise_dnode(doomed)
        if doomed == @head
          @head = next_dnode(doomed)
        end
      end

      @forward.delete(doomed)
      @backward.delete(doomed)
      result
    end

    # def do_index(obj)
    #   @count.times do |i|
    #     return i if self[i] == obj # This is reasonable due to cursor D'oh!
    #   end

    #   return nil
    # end

    # def do_index(obj, test)
    #   dcons = @store
    #   @count.times do |i|
    #     return i if test.call(obj, dcons.content)
    #     dcons = dcons.succ
    #   end

    #   return nil
    # end

    #
    #    Inclusive `i`, exclusive `j`
    #    
#    def subseq(i, j)
    # def sublist(i, j)
    #   result = []
      
    #   if i < j
    #     dnode = nth_dll_node(i)
    #     (i...j).each do
    #       result << dnode.content
    #       dnode = next_dnode(dnode)
    #     end
    #   end

    #   result
    # end
    
    #
    #    Returns empty DoublyLinkedList if negative i is too far
    #    vs. Array#slice => nil
    #    
    # def do_slice(i, n)
    #   list = make_empty_list
    #   slice = subseq([i, @count].min, [i+n, @count].min)

    #   list.add(*slice)
    #   list
    # end

    def make_empty_list
      DoublyLinkedListHash.new(type: type, fill_elt: fill_elt)
    end

    def do_reverse
      @head = previous_dnode(@head)
      @forward, @backward = @backward, @forward
      @cursor.reset

      self
    end
  end

  class HashList < MutableList
    def initialize(type: Object, fill_elt: nil)
      super(type: type, fill_elt: fill_elt)
      @store = {}
    end

    def size
      @store.size
    end

    def empty?
      @store.empty?
    end

    # def iterator
    #   cursor = 0
    #   MutableCollectionIterator.new(modification_count: ->() {@modification_count},
    #                                 done: ->() {cursor == size},
    #                                 current: ->() {get(cursor)},
    #                                 advance: ->() {cursor += 1})
    # end
    
    def iterator
      MutableCollectionIterator.new(modification_count: ->() {@modification_count},
                                    cursor: Cursor.make_random_access_list_cursor(self))
    end

    def list_iterator(start=0)
      RandomAccessListListIterator.new(list: self,
                                       start: start,
                                       modification_count: ->() {@modification_count})
    end
    
    private
    def do_do_clear
      @store = {}
    end

    # def do_contains?(obj, test)
    #   size.times do |i|
    #     elt = get(i)
    #     if test.call(obj, elt)
    #       return elt
    #     end
    #   end

    #   return nil
    # end

    def do_do_add(objs)
      i = size
      objs.each do |obj|
        @store[i] = obj
        i += 1
      end
    end

    def shift_up(low, high)
      (high-1).downto(low) do |i|
        @store[i+1] = @store[i]
      end
    end

    def shift_down(low, high)
      low.upto(high-1) do |i|
        @store[i-1] = @store[i]
      end
    end

    def do_do_insert(i, obj)
      shift_up(i, size)
      set(i, obj)
    end

    def do_do_delete(i)
      doomed = @store[i]
      shift_down(i+1, size)
      @store.delete(size-1)

      doomed
    end
    
    def do_get(i)
      @store[i]
    end

    def do_set(i, obj)
      @store[i] = obj
    end
    
    # def do_index(obj, test)
    #   size.times do |i|
    #     if test.call(obj, get(i))
    #       return i
    #     end
    #   end

    #   return nil
    # end

    # def do_slice(i, n)
    #   list = HashList.new(type: type, fill_elt: fill_elt)

    #   low = [i, size].min
    #   high = [i+n, size].min
    #   slice = []

    #   low.upto(high-1) do |j|
    #     slice << get(j)
    #   end

    #   list.add(*slice)
    #   list
    # end

    def make_empty_list
      HashList.new(type: type, fill_elt: fill_elt)
    end
  end

  class HashListX < HashList
    def initialize(type: Object, fill_elt: nil)
      super(type: type, fill_elt: fill_elt)
      @offset = 0
    end

    private
    def do_do_clear
      super
      @offset = 0
    end

    def do_do_add(objs)
      i = size + @offset
      objs.each do |obj|
        @store[i] = obj
        i += 1
      end
    end

    def shift_up(low, high)
      super(low + @offset, high + @offset)
    end

    def shift_down(low, high)
      super(low + @offset, high + @offset)
    end

    def do_do_insert(i, obj)
      if i > (size / 2).floor
        shift_up(i, size)
      else
        unless i.zero?
          shift_down(0, i)
        end

        @offset -= 1
      end

      set(i, obj)
    end

    def do_do_delete(i)
      doomed = get(i)
      
      if i > (size / 2).floor
        shift_down(i + 1, size)
        @store.delete(size - 1 + @offset)
      else
        unless i.zero?
          shift_up(0, i)
        end
        
        @store.delete(@offset)
        @offset += 1
      end
      
      doomed
    end

    def do_get(i)
      @store[i + @offset]
    end

    def do_set(i, obj)
      @store[i + @offset] = obj
    end
    
    def make_empty_list
      HashListX.new(type: type, fill_elt: fill_elt)
    end
  end

  class PersistentList < List
    attr_reader :store

    def initialize(type: Object, fill_elt: nil)
      super(type: type, fill_elt: fill_elt)
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
      PersistentList.new(type: @type, fill_elt: @fill_elt)
    end

    # def elements
    #   elts = []
    #   i = iterator

    #   until i.done?
    #     elts.push(i.current)
    #     i = i.next
    #   end

    #   elts
    # end

    # def iterator
    #   PersistentCollectionIterator.new(done: ->() {empty?},
    #                                    current: ->() {get(0)},
    #                                    advance: ->() {delete(0).iterator})
    # end

    def iterator
      PersistentCollectionIterator.new(Cursor.make_persistent_list_cursor(self))
    end
    
    def list_iterator(start=0)
      PersistentListListIterator.new(list: self, start: start, head: @store)
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
      list = make_empty_list
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
      node = nil
      objs.reverse_each do |elt|
        node = Node.new(elt, node)
      end

      initialize_list(Node.append(@store, node), @count + objs.size)
    end

    def adjust_node(store, i, adjustment)
      front = nil
      rear = nil
      node = store
      
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

    def do_slice(i, n)
      first = [i, size].min
      last = [i+n, size].min
      initialize_list(adjust_node(Node.nthcdr(@store, first), last-first, ->(node) {nil}), last-first)
    end

    def make_empty_list
      PersistentList.new(type: type, fill_elt: fill_elt)
    end
  end

  class ListIterator
    def initialize(list)
      @list = list
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
    def initialize(list, modification_count)
      super(list)
      @modification_count = modification_count
      @expected_modification_count = modification_count.call
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
      @expected_modification_count != @modification_count.call
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
    def initialize(list:, modification_count:, start: 0)
      super(list, modification_count)

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
    def initialize(list:, start: 0, modification_count:, head:)
      super(list, modification_count)
      @head = head
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
      @cursor = @head.call
    end

    def do_has_next?
      !(@cursor.nil?  ||  @cursor.rest.nil?)
    end

    def do_has_previous?
      !(@cursor.nil?  ||  @cursor == @head.call)
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
    def initialize(list:, start: 0, modification_count:, init:)
      super(list, modification_count)
      raise ArgumentError.new("Invalid index: #{start}") if start < 0 

      @init = init
      @cursor = @init.call
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
    def initialize(list:, start: 0, head:)
      super(list)
      @cursor = head
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
      iterator = PersistentListListIterator.new(list: @list, start: 0, head: cursor)
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
