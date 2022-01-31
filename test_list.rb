#!/usr/bin/ruby -w

#    File:
#       test_list.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       211114 Original.

require './containers'
require './list'
require 'test/unit'
require 'benchmark'

class TestList < Test::Unit::TestCase
  def test_constructor(constructor)
    list = constructor.call
    assert(list.empty?, "New list should be empty.")
    assert(list.size.zero?, "Size of new list should be zero.")
    assert(list[0].nil?, "Accessing element of empty list returns nil.")
  end

  def test_empty?(constructor)
    list = constructor.call
    assert(list.empty?, "New list should be empty.")
    list.add(:foo)
    assert(!list.empty?, "List with elt should not be empty.")
    list.delete(0)
    assert(list.empty?, "Empty list should be empty.")
  end

  def test_size(constructor)
    #  def test_size(constructor, count=1000)
    count = 1000
    list = constructor.call
    assert(list.size.zero?, "Size of new list should be zero.")
    1.upto(count) do |i|
      list.add(i)
      assert_equal(i, list.size, "Size of list should be #{i}")
    end
  end

  def test_clear(constructor)
    count = 1000
    list = constructor.call
    fill(list, count)
    assert(!list.empty?, "List should have #{count} elements.")
    list.clear
    assert(list.empty?, "List should be empty.")
  end

  def fill(list, count)
    1.upto(count) do |i|
      list.add(i)
    end
  end

  def test_contains?(constructor)
    count = 1000
    list = constructor.call
    fill(list, count)
    1.upto(count) do |i|
      assert(list.contains?(i), "The list should contain the value #{i}")
    end
  end
    
# (defun test-contains-test (list-constructor)
#   (let ((list (funcall list-constructor)))
#     (loop for ch in #[#\a #\z]
#           do (add list ch))
#     (notany #'(lambda (ch) (contains list ch)) #[#\A #\Z])
#     (every #'(lambda (ch) (contains list ch :test #'char-equal)) #[#\A #\Z]))
#   t)

  def test_each(constructor)
    list = constructor.call
    ('a'..'z').each do |ch|
      list.add(ch)
    end

    result = ""
    list.each {|ch| result << ch}

    expected = ('a'..'z').to_a.join

    assert_equal(expected, result, "Concatenating `each` char should produce #{expected}: #{result}")
  end

#  def test_insert(constructor, fill_elt=nil)            # ?????????????????????????????????????????????????????????
  def _test_insert(constructor, fill_elt)
    # fill_elt = nil
    list = constructor.call(Object, fill_elt)
    elt = :bar
    list.insert(5, :foo)
    assert_equal(list.size, 6, "Insert should extend list.")
    assert_equal(list[0], fill_elt, "Empty elements should be filled with #{fill_elt}")
    list.insert(0, elt)
    assert_equal(list.size, 7, "Insert should increase length.")
    assert_equal(list[0], elt, "Inserted element should be #{elt}")
  end

  def test_insert(constructor)
    _test_insert(constructor, nil)
  end

  def test_insert_fill_zero(constructor)
    _test_insert(constructor, 0)
  end

  def test_insert_negative_index(constructor)
    list = constructor.call
    list.add(0)

    1.upto(10) do |i|
      list.insert(-i, i)
    end

    elts = []
    list.size.times do |i|
      elts << list[i]
    end

    expected = []
    10.downto(0) do |i|
      expected << i
    end

    assert_equal(elts, expected, "Inserted elements should be: #{expected} but found: #{elts}")
  end
  
  def test_insert_end(constructor)
    list = constructor.call
    list.add(0, 1, 2)
    list.insert(3, 3)

    assert_equal(list[3], 3, "Element at index 3 should be 3.")
    assert_equal(list.size, 4, "Size of list should be 4")

    list.insert(5, 5)

    assert_equal(list[5], 5, "Element at index 5 should be 5.")
    assert_equal(list.size, 6, "Size of list should be 6")
  end

  def test_delete(constructor)
    count = 1000
    list = constructor.call
    fill(list, count)

    count.downto(1) do |n|
      assert_equal(list.size, n, "List size should reflect deletions")
      list.delete(0)
    end
    
    assert(list.empty?, "Empty list should be empty.")
  end

  def test_delete_negative_index(constructor)
    count = 1000
    list = constructor.call
    fill(list, count)

    count.downto(1) do |n|
      assert_equal(list.delete(-1), n, "Deleted element should be last in list")
    end
    
    assert(list.empty?, "Empty list should be empty.")
  end

  def test_nth(constructor)
    count = 1000
    list = constructor.call
    fill(list, count)

    0.upto(count-1) do |i|
      assert_equal(list[i], i+1, "Element #{i} should be #{i+1}")
    end
  end

  def test_nth_negative_index(constructor)
    count = 1000
    list = constructor.call
    fill(list, count)

    -1.downto(-count) do |i|
      assert_equal(list[i], count+i+1, "Element #{i} should be #{count+i+1} not #{list[i]}")
    end
  end

  def test_set_nth(constructor)
    list = constructor.call
    0.upto(10) do |i|
      list[i] = i
    end

    0.upto(10) do |i|
      assert_equal(list[i], i, "Element #{i} should have value #{i} not #{list[i]}")
    end
  end

  def test_set_nth_negative_index(constructor)
    list = constructor.call
    fill(list, 10)
    -1.downto(-10) do |i|
      list[i] = i
    end

    0.upto(9) do |i|
      assert_equal(list[i], i-10, "Element #{i} should have value #{i-10} not #{list[i]}")
    end
  end

  def test_set_nth_out_of_bounds(constructor)
    list = constructor.call
    list[10] = :foo

    assert_equal(list.size, 10+1, "List should expand to accommodate out-of-bounds index.")
  end

  def test_index(constructor)
    count = 1000
    list = constructor.call
    fill(list, count)
    1.upto(count) do |i|
      assert_equal(list.index(i), i-1, "The value #{i-1} should be located at index #{i}")
    end
  end

# (defun test-index-test (list-constructor)
#   (let ((list (funcall list-constructor)))
#     (loop for ch in #[#\a #\z]
#           do (add list ch))
#     (notany #'(lambda (ch) (index list ch)) #[#\A #\Z])
#     (every #'(lambda (ch) (index list ch :test #'char-equal)) #[#\A #\Z]))
#   t)

  def test_slice(constructor)
    count = 1000
    list = constructor.call
    fill(list, count)

    n = count / 2
    j = count / 10
    slice = list.slice(j, n)
    assert_equal(slice.size, n, "Slice should contain #{n} elements")
    0.upto(n-1) do |i|
      assert_equal(slice[i], i+j+1, "Element #{i} should have value #{i+j+1} not #{slice[i]}")
    end
  end

  def test_slice_corner_cases(constructor)
    count = 1000
    list = constructor.call
    fill(list, count)

    n = 10
    slice = list.slice(list.size, n)
    assert(slice.empty?, "Slice at end of list should be empty")

    slice = list.slice(-n, n)
    assert_equal(slice.size, n, "Slice of last #{n} elements should have #{n} elements: #{slice.size}")

    slice = list.slice(-(count + 1), n)
    assert(slice.empty?, "Slice with invalid negative index should be empty")
  end

  # def test_time(constructor)
  #   list = constructor.call

  #   start_time = Time.now
  #   10.times do
  #     fill(list, 10000)
  #     until list.empty?
  #       list.delete(0)
  #     end
  #   end

  #   10.times do
  #     fill(list, 10000)
  #     until list.empty?
  #       list.delete(-1)
  #     end
  #   end

  #   end_time = Time.now
  #   puts("Elapsed time: #{end_time - start_time}")
  # end

  def test_time(constructor)
    
    list = constructor.call

    Benchmark.bm do |run|
      run.report("delete front") do 
        10.times do
          fill(list, 10000)
          until list.empty?
            list.delete(0)
          end
        end
      end
    end

    Benchmark.bm do |run|
      run.report("delete rear") do
        10.times do
          fill(list, 10000)
          until list.empty?
            list.delete(-1)
          end
        end
      end
    end
  end

  # def test_wave(constructor)
  #   list = constructor.call
  #   fill(list, 5000)
  #   assert_equal(5000, list.size, "Size of list should be 5000")
  #   3000.times { list.pop }
  #   assert_equal(2000, list.size, "Size of list should be 2000")
    
  #   fill(list, 5000)
  #   assert_equal(7000, list.size, "Size of list should be 7000")
  #   3000.times { list.pop }
  #   assert_equal(4000, list.size, "Size of list should be 4000")

  #   fill(list, 5000)
  #   assert_equal(9000, list.size, "Size of list should be 9000")
  #   3000.times { list.pop }
  #   assert_equal(6000, list.size, "Size of list should be 6000")

  #   fill(list, 4000)
  #   assert_equal(10000, list.size, "Size of list should be 10000")
  #   10000.times { list.pop }
  #   assert(list.empty?, "List should be empty.")
  # end

end

class TestArrayList < TestList
  def test_it
    test_constructor(lambda {Collections::ArrayList.new})
    test_empty?(lambda {Collections::ArrayList.new})
    test_size(lambda {Collections::ArrayList.new})
    test_clear(lambda {Collections::ArrayList.new})
    test_each(lambda {Collections::ArrayList.new})
    test_contains?(lambda {Collections::ArrayList.new})
    test_insert(lambda {|type, fill_elt| Collections::ArrayList.new(type, fill_elt)})
    test_insert_fill_zero(lambda {|type, fill_elt| Collections::ArrayList.new(type, fill_elt)})
    test_insert_negative_index(lambda {Collections::ArrayList.new})
    test_insert_end(lambda {Collections::ArrayList.new})
    test_delete(lambda {Collections::ArrayList.new})
    test_delete_negative_index(lambda {Collections::ArrayList.new})
    test_nth(lambda {Collections::ArrayList.new})
    test_nth_negative_index(lambda {Collections::ArrayList.new})
    test_set_nth(lambda {Collections::ArrayList.new})
    test_set_nth_negative_index(lambda {Collections::ArrayList.new})
    test_set_nth_out_of_bounds(lambda {Collections::ArrayList.new})
    test_index(lambda {Collections::ArrayList.new})
    test_slice(lambda {Collections::ArrayList.new})
    test_slice_corner_cases(lambda {Collections::ArrayList.new})
    test_time(lambda {puts("ArrayList"); Collections::ArrayList.new})
  end
end

class TestSinglyLinkedList < TestList
  def test_it
    test_constructor(lambda {Collections::SinglyLinkedList.new})
    test_empty?(lambda {Collections::SinglyLinkedList.new})
    test_size(lambda {Collections::SinglyLinkedList.new})
    test_clear(lambda {Collections::SinglyLinkedList.new})
    test_each(lambda {Collections::SinglyLinkedList.new})
    test_contains?(lambda {Collections::SinglyLinkedList.new})
    test_insert(lambda {|type, fill_elt| Collections::SinglyLinkedList.new(type, fill_elt)})
    test_insert_fill_zero(lambda {|type, fill_elt| Collections::SinglyLinkedList.new(type, fill_elt)})
    test_insert_negative_index(lambda {Collections::SinglyLinkedList.new})
    test_insert_end(lambda {Collections::SinglyLinkedList.new})
    test_delete(lambda {Collections::SinglyLinkedList.new})
    test_delete_negative_index(lambda {Collections::SinglyLinkedList.new})
    test_nth(lambda {Collections::SinglyLinkedList.new})
    test_nth_negative_index(lambda {Collections::SinglyLinkedList.new})
    test_set_nth(lambda {Collections::SinglyLinkedList.new})
    test_set_nth_negative_index(lambda {Collections::SinglyLinkedList.new})
    test_set_nth_out_of_bounds(lambda {Collections::SinglyLinkedList.new})
    test_index(lambda {Collections::SinglyLinkedList.new})
    test_slice(lambda {Collections::SinglyLinkedList.new})
    test_slice_corner_cases(lambda {Collections::SinglyLinkedList.new})
    test_time(lambda {puts("SinglyLinkedList"); Collections::SinglyLinkedList.new})
  end
end

class TestDoublyLinkedList < TestList
  def test_it
    test_constructor(lambda {Collections::DoublyLinkedList.new})
    test_empty?(lambda {Collections::DoublyLinkedList.new})
    test_size(lambda {Collections::DoublyLinkedList.new})
    test_clear(lambda {Collections::DoublyLinkedList.new})
    test_each(lambda {Collections::DoublyLinkedList.new})
    test_contains?(lambda {Collections::DoublyLinkedList.new})
    test_insert(lambda {|type, fill_elt| Collections::DoublyLinkedList.new(type, fill_elt)})
    test_insert_fill_zero(lambda {|type, fill_elt| Collections::DoublyLinkedList.new(type, fill_elt)})
    test_insert_negative_index(lambda {Collections::DoublyLinkedList.new})
    test_insert_end(lambda {Collections::DoublyLinkedList.new})
    test_delete(lambda {Collections::DoublyLinkedList.new})
    test_delete_negative_index(lambda {Collections::DoublyLinkedList.new})
    test_nth(lambda {Collections::DoublyLinkedList.new})
    test_nth_negative_index(lambda {Collections::DoublyLinkedList.new})
    test_set_nth(lambda {Collections::DoublyLinkedList.new})
    test_set_nth_negative_index(lambda {Collections::DoublyLinkedList.new})
    test_set_nth_out_of_bounds(lambda {Collections::DoublyLinkedList.new})
    test_index(lambda {Collections::DoublyLinkedList.new})
    test_slice(lambda {Collections::DoublyLinkedList.new})
    test_slice_corner_cases(lambda {Collections::DoublyLinkedList.new})
    test_time(lambda {puts("DoublyLinkedList"); Collections::DoublyLinkedList.new})
  end
end

class TestHashList < TestList
  def test_it
    test_constructor(lambda {Collections::HashList.new})
    test_empty?(lambda {Collections::HashList.new})
    test_size(lambda {Collections::HashList.new})
    test_clear(lambda {Collections::HashList.new})
    test_each(lambda {Collections::HashList.new})
    test_contains?(lambda {Collections::HashList.new})
    test_insert(lambda {|type, fill_elt| Collections::HashList.new(type, fill_elt)})
    test_insert_fill_zero(lambda {|type, fill_elt| Collections::HashList.new(type, fill_elt)})
    test_insert_negative_index(lambda {Collections::HashList.new})
    test_insert_end(lambda {Collections::HashList.new})
    test_delete(lambda {Collections::HashList.new})
    test_delete_negative_index(lambda {Collections::HashList.new})
    test_nth(lambda {Collections::HashList.new})
    test_nth_negative_index(lambda {Collections::HashList.new})
    test_set_nth(lambda {Collections::HashList.new})
    test_set_nth_negative_index(lambda {Collections::HashList.new})
    test_set_nth_out_of_bounds(lambda {Collections::HashList.new})
    test_index(lambda {Collections::HashList.new})
    test_slice(lambda {Collections::HashList.new})
    test_slice_corner_cases(lambda {Collections::HashList.new})
    test_time(lambda {puts("HashList"); Collections::HashList.new})
  end
end

# Benchmark.measure { list = Collections::ArrayList.new; fill(list, 100000)}
# => #<Benchmark::Tms:0x000055edc060fb68 @cstime=0.0, @cutime=0.0, @label="", @real=3.5190064888447523, @stime=0.219943, @total=3.5186339999999996, @utime=3.298691>
# Benchmark.measure { list = Collections::SinglyLinkedList.new; fill(list, 100000)}
# => #<Benchmark::Tms:0x000055edc0a1e768 @cstime=0.0, @cutime=0.0, @label="", @real=100.8402192199137, @stime=0.01640999999999998, @total=100.788832, @utime=100.772422>
# Benchmark.measure { list = Collections::DoublyLinkedList.new; fill(list, 100000)}
# => #<Benchmark::Tms:0x000055edc08c44d0 @cstime=0.0, @cutime=0.0, @label="", @real=0.06819757912307978, @stime=0.0, @total=0.06819500000000289, @utime=0.06819500000000289>
# Benchmark.measure { list = Collections::HashList.new; fill(list, 100000)}
# => #<Benchmark::Tms:0x000055edc0f7d0b0 @cstime=0.0, @cutime=0.0, @label="", @real=0.039861492812633514, @stime=0.0, @total=0.039857999999995286, @utime=0.039857999999995286>

#
#    Tests not executed in order!!
#    
# ArrayList
#        user     system      total        real
# delete front  0.437838   0.028134   0.465972 (  0.465986)        <-- Only case where Ruby is competitive with Lisp (SBCL)
#        user     system      total        real
# delete rear  0.371017   0.000000   0.371017 (  0.371043)

# DoublyLinkedList
#        user     system      total        real
# delete front  0.117630   0.007853   0.125483 (  0.125487)
#        user     system      total        real
# delete rear  0.219415   0.000000   0.219415 (  0.219420)

# HashList
#        user     system      total        real
# delete front 89.918431   0.000000  89.918431 ( 89.922602)
#        user     system      total        real
# delete rear  0.138053   0.000000   0.138053 (  0.138066)

# SinglyLinkedList
#        user     system      total        real
# delete front  9.987988   0.000000   9.987988 (  9.988117)
#        user     system      total        real
# delete rear 47.436063   0.000000  47.436063 ( 47.443081)


# al.contains?(3, test: ->(item, elt) {elt == item + 1})
# => 4
# al.contains?(2, test: ->(item, elt) {elt > item * 2})
# => 5
#sll.add(1, 2, 3, 4, 5)
# sll.contains?(2, test: ->(item, elt) {elt > item * 2})
# => 5
# sll.contains?(3, test: ->(item, elt) {elt == item + 1})
# => 4

# dll.contains?(2.0)
# => 2
# irb(main):200:0> dll.contains?(2, test: ->(item, elt) {elt > item * 2})
# => 5
# irb(main):201:0> dll.contains?(3, test: ->(item, elt) {elt == item + 1})
# => 4

# hl.contains?(3, test: ->(item, elt) {elt % item == 0})
# => 3

# al.add(:a, :b, :c, :d)
# sll.add(?a, ?b, ?c, ?d)
# dll.add(?A, ?B, ?C, ?D)
# al == sll
# => false
# al.==(sll, test: ->(x, y) {x.to_s == y.to_s})
# => true
# sll.==(al, test: ->(x, y) {x.to_s == y.to_s})
# sll.==(dll, test: ->(x, y) {x.to_s.downcase == y.to_s.downcase})
# => true

# al.add(2, 3, 4, 5)
# => [2, 3, 4, 5]
# al.index(3, test: ->(item, elt) {elt % item == 0})
# => 1
