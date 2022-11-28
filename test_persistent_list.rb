#!/usr/bin/ruby -w

#    File:
#       test_persistent_list.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       221123 Original.

require './containers'
require './list'
require 'test/unit'
require 'benchmark'

class TestList < Test::Unit::TestCase
  def test_constructor(constructor)
    list = constructor.call
    assert(list.empty?, "New list should be empty.")
    assert(list.size.zero?, "Size of new list should be zero.")
    assert(list.get(0).nil?, "Accessing element of empty list returns nil.")
    assert_raises(StandardError, "Can't call delete() on empty list.") { list.delete(0) }
  end

  def test_empty?(constructor)
    list = constructor.call
    assert(list.empty?, "New list should be empty.")
    assert(!list.add(:foo).empty?, "List with elt should not be empty.")
    assert(list.add(:foo).delete(0).empty?, "Empty list should be empty.")
  end

  def test_size(constructor)
    count = 1000
    list = constructor.call
    assert(list.size.zero?, "Size of new list should be zero.")
    1.upto(count) do |i|
      list = list.add(i)
      assert_equal(i, list.size, "Size of list should be #{i}")
    end

    (count-1).downto(0) do |i|
      list = list.delete(0)
      assert_equal(i, list.size, "Size of list should be #{i}")
    end

    assert(list.size.zero?, "Size of empty list should be zero.")
  end

  def test_clear(constructor)
    count = 1000
    list = constructor.call.fill(count: count)

    assert(!list.empty?, "List should have #{count} elements.")
    list = list.clear
    assert(list.empty?, "List should be empty.")
    assert(list.size.zero?, "Size of empty list should be zero.")
  end

  def test_contains?(constructor)
    count = 1000
    list = constructor.call.fill(count: count)

    1.upto(count) do |i|
      assert_equal(i, list.contains?(i), "The list should contain the value #{i}")
    end
  end

  def test_contains_predicate(constructor)
    list = constructor.call.add(*("a".."z").to_a)

    assert(("a".."z").to_a.all? {|ch| list.contains?(ch)}, "Should be matchy matchy.")
    assert(("A".."Z").to_a.none? {|ch| list.contains?(ch)}, "Default test should fail.")
    assert(("A".."Z").to_a.all? {|ch| list.contains?(ch, test: ->(item, elt) { item.casecmp(elt).zero? })},
           "Specific test should succeed.")
  end
    
  def test_contains_arithmetic(constructor)
    list = constructor.call.fill(count: 20)

    assert_equal(3, list.contains?(3), "Literal 3 should be present in list.")
    assert_equal(3, list.contains?(3.0), "Integer equal to 3.0 should be present in list.") # ???
    assert_equal(4, list.contains?(3, test: ->(item, elt) { elt == item + 1 }),
                 "List contains the element one larger than 3.")
    assert_equal(5, list.contains?(2, test: ->(item, elt) { elt > item * 2 }),
                 "First element in list larger than 2 doubled is 5.")
    assert_equal(3, list.contains?(3, test: ->(item, elt) { elt % item == 0}),
                 "First multiple of 3 should be present in list.")
  end

  def test_equals(constructor)
    count = 1000
    list = constructor.call.fill(count: count)
    persistent_list = Containers::PersistentList.new.fill(count: count)
    array_list = Containers::ArrayList.new.fill(count: count)
    doubly_linked_list = Containers::DoublyLinkedList.new.fill(count: count)

    assert(list.equals(list), "Equality should be reflexive.")

    assert(list.equals(persistent_list), "Lists with same content should be equal.")
    assert(persistent_list.equals(list), "Equality should be symmetric.")

    assert(list.equals(array_list), "Lists with same content should be equal.")
    assert(array_list.equals(list), "Equality should be symmetric.")

    assert(list.equals(doubly_linked_list), "Lists with same content should be equal.")
    assert(doubly_linked_list.equals(list), "Equality should be symmetric.")
  end

  def test_equals_predicate(constructor)
    list = constructor.call.add(*("a".."z").to_a)
    persistent_list = Containers::PersistentList.new.add(*("A".."Z").to_a)
    array_list = Containers::ArrayList.new.add(*("A".."Z").to_a)
    doubly_linked_list = Containers::DoublyLinkedList.new.add(*("A".."Z").to_a)
    
    assert(!list.equals(persistent_list), "Default test should fail.")
    assert(!list.equals(array_list), "Default test should fail.")
    assert(!list.equals(doubly_linked_list), "Default test should fail.")

    char_equal = ->(item, elt) { item.casecmp(elt).zero? }

    assert(list.equals(persistent_list, test: char_equal), "Specific test should succeed.")
    assert(list.equals(array_list, test: char_equal), "Specific test should succeed.")
    assert(list.equals(doubly_linked_list, test: char_equal), "Specific test should succeed.")
  end

  def test_equals_transform(constructor)
    word_list_1 = constructor.call.add("Is", "this", "not", "pung?")
    word_list_2 = constructor.call.add("gg", "mcmc", "uuu", "ixncm")
    word_list_3 = constructor.call.add("Is", "this", "no", "pung?")
    number_list = constructor.call.add(2, 4, 3, 5)

    value = ->(o) {
      if o.is_a?(String)
        o.length
      else
        o
      end
    }
    compare = ->(o1, o2) { value.call(o1) == value.call(o2) }
    
    assert(!word_list_1.equals(word_list_2), "Default test should fail.")
    assert(word_list_1.equals(word_list_2, test: compare), "Specific test should succeed.")
    assert(word_list_2.equals(word_list_1, test: compare), "Equality should be symmetric.")
    assert(word_list_1.equals(number_list, test: compare), "Specific test should succeed.")
    assert(word_list_2.equals(number_list, test: compare), "Specific test should succeed.")
    assert(number_list.equals(word_list_1, test: compare), "Equality should be symmetric.")
    assert(!word_list_1.equals(word_list_3, test: compare), "Unequal lists are not equal.")
    assert(!number_list.equals(word_list_3, test: compare), "Unequal lists are not equal.")
  end    

  def test_each(constructor)
    lowers = ('a'..'z').to_a
    list = constructor.call.add(*lowers)

    result = ""
    list.each {|ch| result << ch}

    expected = lowers.join

    assert_equal(expected, result, "Concatenating `each` char should produce #{expected}: #{result}")
  end

  def test_add(constructor)
    count = 1000
    list = constructor.call

    1.upto(count) do |i|
      list = list.add(i)
      assert_equal(i, list.size, "Size of list should be #{i} not #{list.size}")
      assert_equal(i, list.get(-1), "Last element of list should be #{i} not #{list.get(-1)}")
    end
  end
  
  def _test_insert(constructor, fill_elt)
    list = constructor.call(Object, fill_elt)
    count = 6
    elt1 = :foo
    elt2 = :bar

    list = list.insert(count-1, elt1)

    assert_equal(list.size, count, "Insert should extend list.")
    assert_equal(list.get(count-1), elt1, "Inserted element should be #{elt1}")
    assert_equal(list.get(0), fill_elt, "Empty elements should be filled with #{fill_elt}")

    list = list.insert(0, elt2)

    assert_equal(list.size, count+1, "Insert should increase length.")
    assert_equal(list.get(0), elt2, "Inserted element should be #{elt2}")
  end

  def test_insert(constructor)
    _test_insert(constructor, nil)
  end

  def test_insert_fill_zero(constructor)
    _test_insert(constructor, 0)
  end

  def test_insert_negative_index(constructor)
    list = constructor.call.add(0)

    1.upto(10) do |i|
      list = list.insert(-i, i)
    end

    iterator = list.iterator
    10.downto(0) do |i|
      assert_equal(i, iterator.current, "Inserted element should be: #{i} but found: #{iterator.current}")
      iterator = iterator.next
    end
  end
  
  def test_insert_end(constructor)
    list = constructor.call.add(0, 1, 2)
    x = 3
    y = 10

    list = list.insert(x, x)
    assert_equal(x, list.get(x), "Element at index #{x} should be #{x}.")
    assert_equal(x+1, list.size, "Size of list should be #{x+1} not #{list.size}")

    list = list.insert(y, y)
    assert_equal(y, list.get(y), "Element at index #{y} should be #{y}.")
    assert_equal(y+1, list.size, "Size of list should be #{y+1} not #{list.size}")
  end

#   def test_insert_offset(constructor)
#     count = 1000
#     low_index = 1
#     high_index = (3.0/4.0 * count).to_i
#     elt = 88

#     list = constructor.call.fill(count: count)
#     list.delete(0)
#     assert_equal(2, list.get(0), "First element should be 2 not #{list.get(0)}")
#     list.insert(0, elt)
#     assert_equal(elt, list.get(0), "First element should be #{elt} not #{list.get(0)}")

#     list = constructor.call.fill(count: count)
#     list.delete(0)
#     list.insert(low_index, elt)
#     assert_equal(2, list.get(0), "First element should be 2 not #{list.get(0)}")
#     assert_equal(elt, list.get(low_index), "Element #{low_index} should be #{elt} not #{list.get(low_index)}")

#     list = constructor.call.fill(count: count)
#     list.delete(0)
#     list.insert(high_index, elt)
#     assert_equal(2, list.get(0), "First element should be 2 not #{list.get(0)}")
#     assert_equal(elt, list.get(high_index), "Element #{high_index} should be #{elt} not #{list.get(high_index)}")
#   end

  def test_delete(constructor)
    count = 1000
    list = constructor.call.fill(count: count)

    j = 1
    count.downto(1) do |i|
      doomed = list.delete(0)
      assert_equal(i-1, list.size, "List size should reflect deletions")
      assert_equal(j, doomed, "Incorrect deleted value returned: #{doomed} rather than #{j}")
      j += 1
    end
    
    assert(list.empty?, "Empty list should be empty.")

    list = constructor.call.fill(count: count)

    count.downto(1) do |i|
      doomed = list.delete(i-1)
      assert_equal(doomed, i, "Incorrect deleted value returned: #{doomed} rather than #{i}")
    end
    
    assert(list.empty?, "Empty list should be empty.")
  end

#   def test_delete_negative_index(constructor)
#     count = 1000
#     list = constructor.call.fill(count: count)

#     count.downto(1) do |i|
#       assert_equal(list.delete(-1), i, "Deleted element should be last in list")
#     end
    
#     assert(list.empty?, "Empty list should be empty.")
#   end

#   def test_delete_offset(constructor)
#     count = 1000
#     low_index = 1
#     high_index = (3.0/4.0 * count).to_i

#     list = constructor.call.fill(count: count)
#     list.delete(0)
#     assert_equal(2, list.get(0), "First element should be 2 not #{list.get(0)}")

#     list.delete(low_index)
#     assert_equal(2, list.get(0), "First element should be 2 not #{list.get(0)}")
#     assert_equal(low_index + 3, list.get(low_index), "Element #{low_index} should be #{low_index + 3} not #{list.get(low_index)}")

#     list.delete(high_index)
#     assert_equal(2, list.get(0), "First element should be 2 not #{list.get(0)}")
#     assert_equal(high_index + 4, list.get(high_index), "Element #{high_index} should be #{high_index + 4} not #{list.get(high_index)}")
#   end

#   def test_get(constructor)
#     count = 1000
#     list = constructor.call.fill(count: count)

#     count.times do |i|
# #      assert_equal(list[i], i+1, "Element #{i} should be #{i+1}")
#       assert_equal(i+1, list.get(i), "Element #{i} should be #{i+1}")
#     end
#   end

#   def test_get_negative_index(constructor)
#     count = 1000
#     list = constructor.call.fill(count: count)

#     -1.downto(-count) do |i|
# #      assert_equal(list[i], count+i+1, "Element #{i} should be #{count+i+1} not #{list[i]}")
#       assert_equal(count+i+1, list.get(i), "Element #{i} should be #{count+i+1} not #{list.get(i)}")
#     end
#   end

#   def test_set(constructor)
#     list = constructor.call
#     0.upto(10) do |i|
#       assert_equal(i, list.size, "Prior to set() size should be #{i} not #{list.size}")
# #      list[i] = i
#       list.set(i, i)
#       assert_equal(i+1, list.size, "After set() size should be #{i+1} not #{list.size}")
#     end

#     0.upto(10) do |i|
# #      assert_equal(list[i], i, "Element #{i} should have value #{i} not #{list[i]}")
#       assert_equal(i, list.get(i), "Element #{i} should have value #{i} not #{list.get(i)}")
#     end

#   end

#   def test_set_negative_index(constructor)
#     count = 1000
#     list = constructor.call.fill(count: count)
#     -1.downto(-count) do |i|
# #      list[i] = i
#       list.set(i, i)
#     end

#     count.times do |i|
# #      assert_equal(list[i], i-10, "Element #{i} should have value #{i-10} not #{list[i]}")
#       assert_equal(i-count, list.get(i), "Element #{i} should have value #{i-count} not #{list.get(i)}")
#     end
#   end

#   def test_set_out_of_bounds(constructor)
#     list = constructor.call
#     index = 10
#     elt = :foo
# #    list[10] = :foo
#     list.set(index, elt)

#     assert_equal(list.fill_elt, list.get(0), "Empty elements should be filled with #{list.fill_elt}")
#     assert_equal(index+1, list.size, "List should expand to accommodate out-of-bounds index.")
#     assert_equal(elt, list.get(index), "Element #{index} should be #{elt}")
#   end

#   def test_index(constructor)
#     count = 1000
#     list = constructor.call.fill(count: count)

#     1.upto(count) do |i|
#       assert_equal(i-1, list.index(i), "The value #{i-1} should be located at index #{i}")
#     end
#   end

#   def test_index_predicate(constructor)
#     list = constructor.call.add(*("a".."z").to_a)
#     assert(("A".."Z").to_a.none? {|ch| list.index(ch)}, "Default test should fail.")
#     assert(("A".."Z").to_a.all? {|ch| list.index(ch, test: ->(item, elt) { item.casecmp(elt).zero? })},
#            "Specific test should succeed.")
#   end

#   def test_index_arithmetic(constructor)
#     list = constructor.call.fill(count: 20)

#     assert_equal(2, list.index(3), "Literal 3 should be at index 2.")
#     assert_equal(2, list.index(3.0), "Integer equal to 3.0 should be present in list at index 2.") # ???
#     assert_equal(3, list.index(3, test: ->(item, elt) { elt == item + 1 }),
#                  "List contains the element one larger than 3 at index 3.")
#     assert_equal(4, list.index(2, test: ->(item, elt) { elt > item * 2 }),
#                  "First element in list larger than 2 doubled is 5 at index 4.")
#     assert_equal(2, list.index(3, test: ->(item, elt) { elt % item == 0}),
#                  "First multiple of 3 should be at index 2..")
#   end
  
#   def test_slice(constructor)
#     count = 1000
#     list = constructor.call.fill(count: count)

#     j = count / 10
#     n = count / 2
#     slice = list.slice(j, n)

#     assert_equal(n, slice.size, "Slice should contain #{n} elements")
#     n.times do |i|
# #      assert_equal(slice[i], i+j+1, "Element #{i} should have value #{i+j+1} not #{slice[i]}")
#       assert_equal(list.get(i+j), slice.get(i), "Element #{i} should have value #{list.get(i+j)} not #{slice.get(i)}")
#     end
#   end

#   def test_slice_negative_index(constructor)
#     count = 1000
#     list = constructor.call.fill(count: count)

#     j = count / 2
#     n = count / 2
#     slice = list.slice(-j)

#     assert_equal(n, slice.size, "Slice should contain #{n} elements")
#     n.times do |i|
# #      assert_equal(slice[i], i+j+1, "Element #{i} should have value #{i+j+1} not #{slice[i]}")
#       assert_equal(list.get(i+j), slice.get(i), "Element #{i} should have value #{list.get(i+j)} not #{slice.get(i)}")
#     end
#   end

#   def test_slice_corner_cases(constructor)
#     count = 1000
#     list = constructor.call.fill(count: count)

#     n = 10

#     slice = list.slice(list.size, n)
#     assert(slice.empty?, "Slice at end of list should be empty")

#     slice = list.slice(-n, n)
#     assert_equal(slice.size, n, "Slice of last #{n} elements should have #{n} elements: #{slice.size}")

#     slice = list.slice(-(count + 1), n)
#     assert(slice.empty?, "Slice with invalid negative index should be empty")
#   end

#   def test_reverse(constructor)
#     count = 1000
#     original = constructor.call.fill(count: count)
#     backward = original.reverse
#     expected = constructor.call

#     count.downto(1) do |i|
#       expected.add(i)
#     end

#     assert_equal(expected, backward, "Reversed list should be: #{expected.slice(0, 20)} instead of: #{backward.slice(0, 20)}")

#     forward = backward.reverse
#     assert_equal(original, forward, "Reversed reversed list should be: #{original.slice(0, 20)} instead of: #{forward.slice(0, 20)}")
#   end

#   # def test_time(constructor)
#   #   list = constructor.call

#   #   start_time = Time.now
#   #   10.times do
#   #     fill(list, 10000)
#   #     until list.empty?
#   #       list.delete(0)
#   #     end
#   #   end

#   #   10.times do
#   #     fill(list, 10000)
#   #     until list.empty?
#   #       list.delete(-1)
#   #     end
#   #   end

#   #   end_time = Time.now
#   #   puts("Elapsed time: #{end_time - start_time}")
#   # end

#   def test_time(constructor)
#     list = constructor.call
# return

#     Benchmark.bm do |run|
#       run.report("add to front\n") do 
#         10.times do
#           10000.times do |j|
#             list.insert(0, j)
#           end
#           list.clear
#         end
#       end
#     end

#     list.clear

#     Benchmark.bm do |run|
#       run.report("add to rear\n") do 
#         10.times do
#           10000.times do |j|
#             list.add(j)
#           end
#           list.clear
#         end
#       end
#     end

#     list.clear

#     Benchmark.bm do |run|
#       run.report("delete front\n") do 
#         10.times do
#           list.fill(count: 10000)
#           until list.empty?
#             list.delete(0)
#           end
#         end
#       end
#     end

#     Benchmark.bm do |run|
#       run.report("delete rear\n") do
#         10.times do
#           list.fill(count: 10000)
#           until list.empty?
#             list.delete(-1)
#           end
#         end
#       end
#     end

#     list.fill(count: 10000)
#     Benchmark.bm do |run|
#       run.report("sequential access\n") do
#         10.times do
#           list.size.times do |j|
#             assert(list.get(j) == j + 1, "Element #{j} should be: #{j + 1}.")
#           end
#         end
#       end
#     end

#     Benchmark.bm do |run|
#       run.report("random access\n") do
#         10.times do
#           list.size.times do
#             index = rand(list.size)
#             assert(list.get(index) == index + 1, "Element #{index} should be: #{index + 1}.")
#           end
#         end
#       end
#     end
      
#     puts
#   end

#   # def test_wave(constructor)
#   #   list = constructor.call
#   #   fill(list, 5000)
#   #   assert_equal(5000, list.size, "Size of list should be 5000")
#   #   3000.times { list.pop }
#   #   assert_equal(2000, list.size, "Size of list should be 2000")
    
#   #   fill(list, 5000)
#   #   assert_equal(7000, list.size, "Size of list should be 7000")
#   #   3000.times { list.pop }
#   #   assert_equal(4000, list.size, "Size of list should be 4000")

#   #   fill(list, 5000)
#   #   assert_equal(9000, list.size, "Size of list should be 9000")
#   #   3000.times { list.pop }
#   #   assert_equal(6000, list.size, "Size of list should be 6000")

#   #   fill(list, 4000)
#   #   assert_equal(10000, list.size, "Size of list should be 10000")
#   #   10000.times { list.pop }
#   #   assert(list.empty?, "List should be empty.")
#   # end

end

class TestPersistentList < TestList
  def test_it
    test_constructor(lambda {Containers::PersistentList.new})
    test_empty?(lambda {Containers::PersistentList.new})
    test_size(lambda {Containers::PersistentList.new})
    test_clear(lambda {Containers::PersistentList.new})
    test_contains?(lambda {Containers::PersistentList.new})
    test_contains_predicate(lambda {Containers::PersistentList.new})
    test_contains_arithmetic(lambda {Containers::PersistentList.new})
    test_equals(lambda {Containers::PersistentList.new})
    test_equals_predicate(lambda {Containers::PersistentList.new})
    test_each(lambda {Containers::PersistentList.new})
    test_add(lambda {Containers::PersistentList.new})
    test_insert(lambda {|type, fill_elt| Containers::PersistentList.new(type: type, fill_elt: fill_elt)})
    test_insert_fill_zero(lambda {|type, fill_elt| Containers::PersistentList.new(type: type, fill_elt: fill_elt)})
    test_insert_negative_index(lambda {Containers::PersistentList.new})
    test_insert_end(lambda {Containers::PersistentList.new})
    # test_insert_offset(lambda {Containers::PersistentList.new})
    # test_delete(lambda {Containers::PersistentList.new})
    # test_delete_negative_index(lambda {Containers::PersistentList.new})
    # test_delete_offset(lambda {Containers::PersistentList.new})
    # test_get(lambda {Containers::PersistentList.new})
    # test_get_negative_index(lambda {Containers::PersistentList.new})
    # test_set(lambda {Containers::PersistentList.new})
    # test_set_negative_index(lambda {Containers::PersistentList.new})
    # test_set_out_of_bounds(lambda {Containers::PersistentList.new})
    # test_index(lambda {Containers::PersistentList.new})
    # test_index_predicate(lambda {Containers::PersistentList.new})
    # test_index_arithmetic(lambda {Containers::PersistentList.new})
    # test_slice(lambda {Containers::PersistentList.new})
    # test_slice_negative_index(lambda {Containers::PersistentList.new})
    # test_slice_corner_cases(lambda {Containers::PersistentList.new})
    # test_reverse(lambda {Containers::PersistentList.new})
    # test_time(lambda {puts("PersistentList"); Containers::PersistentList.new})
  end
end