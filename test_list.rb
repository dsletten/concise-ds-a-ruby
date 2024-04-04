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
    assert_raises(ArgumentError, "Type of fill_elt must match list type.") { constructor.call(type: String) }

    list = constructor.call
    assert(list.empty?, "New list should be empty.")
    assert(list.size.zero?, "Size of new list should be zero.")
    # assert(list[0].nil?, "Accessing element of empty list returns nil.")
    assert(list.get(0).nil?, "Accessing element of empty list returns nil.")
    assert_raises(StandardError, "Can't call delete() on empty list.") { list.delete(0) }
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

    (count-1).downto(0) do |i|
      list.delete(-1)
      assert_equal(i, list.size, "Size of list should be #{i}")
    end

    assert(list.size.zero?, "Size of empty list should be zero.")

    1.upto(count) do |i|
      list.insert(0, i)
      assert_equal(i, list.size, "Size of list should be #{i}")
    end

    (count-1).downto(0) do |i|
      list.delete(0)
      assert_equal(i, list.size, "Size of list should be #{i}")
    end

    assert(list.size.zero?, "Size of empty list should be zero.")
  end

  def test_clear(constructor)
    count = 1000
    list = constructor.call.fill(count: count)
    assert(!list.empty?, "List should have #{count} elements.")

    list.clear
    assert(list.empty?, "List should be empty.")
    assert(list.size.zero?, "Size of empty list should be zero.")
  end

  def test_elements(constructor)
    count = 1000
    list = constructor.call.fill(count: count)
    expected = (1..count).to_a
    elts = list.elements

    assert(expected == elts, "FIFO elements should be #{expected[0, 10]} not #{elts[0, 10]}")
    assert(list.empty?, "Mutable list should be empty after elements are extracted.")
  end

  def test_contains?(constructor)
    count = 1000
    list = constructor.call.fill(count: count)

    1.upto(count) do |i|
      assert_equal(i, list.contains?(i), "The list should contain the value #{i}")
    end
  end

  def test_contains_wrong_type(constructor)
    count = 1000
    list = constructor.call(type: Integer, fill_elt: 0).fill(count: count)

    assert_raises(ArgumentError, "List can't contain value of wrong type.") { list.contains?(:foo) }
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
    array_list = Containers::ArrayList.new.fill(count: count)
    doubly_linked_list = Containers::DoublyLinkedList.new.fill(count: count)

    assert(list.equals(list), "Equality should be reflexive.")

    assert(list.equals(array_list), "Lists with same content should be equal.")
    assert(array_list.equals(list), "Equality should be symmetric.")

    assert(list.equals(doubly_linked_list), "Lists with same content should be equal.")
    assert(doubly_linked_list.equals(list), "Equality should be symmetric.")
  end

  def test_equals_predicate(constructor)
    list = constructor.call.add(*("a".."z").to_a)
    array_list = Containers::ArrayList.new.add(*("A".."Z").to_a)
    doubly_linked_list = Containers::DoublyLinkedList.new.add(*("A".."Z").to_a)
    
    assert(!list.equals(array_list), "Default test should fail.")
    assert(!list.equals(doubly_linked_list), "Default test should fail.")

    char_equal = ->(item, elt) { item.casecmp(elt).zero? }
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
    list = constructor.call.add(*('a'..'z').to_a)

    result = ""
    list.each {|ch| result << ch}

    expected = ('a'..'z').to_a.join

    assert_equal(expected, result, "Concatenating `each` char should produce #{expected}: #{result}")
  end

  def test_add(constructor)
    count = 1000
    list = constructor.call

    1.upto(count) do |i|
      list.add(i)
      assert_equal(i, list.get(-1), "Last element of list should be #{i} not #{list.get(-1)}")
    end
  end

  def test_add_wrong_type(constructor)
    count = 1000
    list = constructor.call(type: Integer, fill_elt: 0)
    assert_raises(ArgumentError, "Can't ADD value of wrong type to list.") { list.add(1.0) }    

    list = constructor.call(type: Integer, fill_elt: 0)
    assert_raises(ArgumentError, "Can't ADD value of wrong type to list.") { list.add(1, 2, :k) }    
  
    list = constructor.call(type: Integer, fill_elt: 0).fill(count: count)
    assert_raises(ArgumentError, "Can't ADD value of wrong type to list.") { list.add(1.0) }    
  end    

#  def test_insert(constructor, fill_elt=nil)            # ?????????????????????????????????????????????????????????
  def _test_insert(constructor, fill_elt)
    list = constructor.call(fill_elt: fill_elt)
    count = 6
    elt1 = :foo
    elt2 = :bar

    list.insert(count-1, elt1)

    assert_equal(list.size, count, "Insert should extend list.")
    assert_equal(list.get(count-1), elt1, "Inserted element should be #{elt1}")
#    assert_equal(list[0], fill_elt, "Empty elements should be filled with #{fill_elt}")
    assert(list.slice(0, count-1).elements.all? {|elt| elt == fill_elt}, "Empty elements should be filled with #{fill_elt}")

    list.insert(0, elt2)

    assert_equal(list.size, count+1, "Insert should increase length.")
#    assert_equal(list[0], elt, "Inserted element should be #{elt}")
    assert_equal(list.get(0), elt2, "Inserted element should be #{elt2}")
  end

  def test_insert(constructor)
    _test_insert(constructor, nil)
  end

  def test_insert_fill_zero(constructor)
    _test_insert(constructor, 0)
  end

  def test_insert_wrong_type(constructor)
    count = 1000
    list = constructor.call(type: Integer, fill_elt: 0)
    assert_raises(ArgumentError, "Can't insert value of wrong type into list.") { list.insert(0, 1.0) }    
    
    list = constructor.call(type: Integer, fill_elt: 0).fill(count: count)
    assert_raises(ArgumentError, "Can't insert value of wrong type into list.") { list.insert(0, 1.0) }    
  end

  def test_insert_negative_index(constructor)
    list = constructor.call.add(0)

    1.upto(10) do |i|
      list.insert(-i, i)
    end

    iterator = list.iterator
    10.downto(0) do |i|
      assert_equal(i, iterator.current, "Inserted element should be: #{i} but found: #{iterator.current}")
      iterator.next
    end
  end
  
  def test_insert_end(constructor)
    list = constructor.call.add(0, 1, 2)
    x = 3
    y = 10

    list.insert(x, x)

#    assert_equal(list[x], x, "Element at index x should be x.")
    assert_equal(list.get(x), x, "Element at index #{x} should be #{x}.")
    assert_equal(list.size, x+1, "Size of list should be #{x+1} not #{list.size}")

    list.insert(y, y)

#    assert_equal(list[y], y, "Element at index y should be y.")
    assert_equal(list.get(y), y, "Element at index #{y} should be #{y}.")
    assert_equal(list.size, y+1, "Size of list should be #{y+1} not #{list.size}")
  end

  def test_insert_offset(constructor)
    count = 1000
    low_index = 1
    high_index = (3.0/4.0 * count).to_i
    elt = 88

    list = constructor.call.fill(count: count)
    list.delete(0)
    assert_equal(2, list.get(0), "First element should be 2 not #{list.get(0)}")
    list.insert(0, elt)
    assert_equal(elt, list.get(0), "First element should be #{elt} not #{list.get(0)}")

    list = constructor.call.fill(count: count)
    list.delete(0)
    list.insert(low_index, elt)
    assert_equal(2, list.get(0), "First element should be 2 not #{list.get(0)}")
    assert_equal(elt, list.get(low_index), "Element #{low_index} should be #{elt} not #{list.get(low_index)}")

    list = constructor.call.fill(count: count)
    list.delete(0)
    list.insert(high_index, elt)
    assert_equal(2, list.get(0), "First element should be 2 not #{list.get(0)}")
    assert_equal(elt, list.get(high_index), "Element #{high_index} should be #{elt} not #{list.get(high_index)}")
  end

  def test_delete(constructor)
    count = 1000
    list = constructor.call.fill(count: count)

    list.size.times do
      expected = list.get(0)
      doomed = list.delete(0)
      assert_equal(expected, doomed, "Incorrect deleted value returned: #{doomed} rather than #{expected}")
    end
    
    assert(list.empty?, "Empty list should be empty.")

    list = constructor.call.fill(count: count)

    (count-1).downto(0) do |i|
      expected = list.get(i)
      doomed = list.delete(i)
      assert_equal(expected, doomed, "Incorrect deleted value returned: #{doomed} rather than #{expected}")
    end
    
    assert(list.empty?, "Empty list should be empty.")

    list = constructor.call.fill(count: count)

    list.size.times do
      expected = list.get(-1)
      doomed = list.delete(-1)
      assert_equal(expected, doomed, "Incorrect deleted value returned: #{doomed} rather than #{expected}")
    end
    
    assert(list.empty?, "Empty list should be empty.")
  end

  def test_delete_offset(constructor)
    count = 1000
    low_index = 1
    high_index = (3.0/4.0 * count).to_i

    list = constructor.call.fill(count: count)
    list.delete(0)
    assert_equal(2, list.get(0), "First element should be 2 not #{list.get(0)}")

    list.delete(low_index)
    assert_equal(2, list.get(0), "First element should be 2 not #{list.get(0)}")
    assert_equal(low_index + 3, list.get(low_index), "Element #{low_index} should be #{low_index + 3} not #{list.get(low_index)}")

    list.delete(high_index)
    assert_equal(2, list.get(0), "First element should be 2 not #{list.get(0)}")
    assert_equal(high_index + 4, list.get(high_index), "Element #{high_index} should be #{high_index + 4} not #{list.get(high_index)}")
  end

  def test_delete_random(constructor)
    count = 1000
    list = constructor.call.fill(count: count)
#    random = Random.new

    count.times do
#      i = random.rand(list.size)
      i = rand(list.size)
      expected = list.get(i)
      doomed = list.delete(i)

      assert_equal(expected, doomed, "Incorrect deleted value returned: #{doomed} rather than #{expected}")
    end
    
    assert(list.empty?, "Empty list should be empty.")
  end
    
  def test_get(constructor)
    count = 1000
    list = constructor.call.fill(count: count)

    count.times do |i|
#      assert_equal(list[i], i+1, "Element #{i} should be #{i+1}")
      assert_equal(i+1, list.get(i), "Element #{i} should be #{i+1}")
    end
  end

  def test_get_negative_index(constructor)
    count = 1000
    list = constructor.call.fill(count: count)

    -1.downto(-count) do |i|
#      assert_equal(list[i], count+i+1, "Element #{i} should be #{count+i+1} not #{list[i]}")
      assert_equal(count+i+1, list.get(i), "Element #{i} should be #{count+i+1} not #{list.get(i)}")
    end
  end

  def test_set(constructor)
    count = 1000
    list = constructor.call
    0.upto(count) do |i|
      assert_equal(i, list.size, "Prior to set() size should be #{i} not #{list.size}")
#      list[i] = i
      list.set(i, i)
      assert_equal(i+1, list.size, "After set() size should be #{i+1} not #{list.size}")
    end

    0.upto(count) do |i|
#      assert_equal(list[i], i, "Element #{i} should have value #{i} not #{list[i]}")
      assert_equal(i, list.get(i), "Element #{i} should have value #{i} not #{list.get(i)}")
    end

  end

  def test_set_wrong_type(constructor)
    count = 1000
    list = constructor.call(type: Integer, fill_elt: 0)
    assert_raises(ArgumentError, "Can't set value of wrong type in list.") { list.set(0, 1.0) }    
    
    list = constructor.call(type: Integer, fill_elt: 0).fill(count: count)
    assert_raises(ArgumentError, "Can't set value of wrong type in list.") { list.set(0, 1.0) }    
  end

  def test_set_negative_index(constructor)
    count = 1000
    list = constructor.call.fill(count: count)
    -1.downto(-count) do |i|
#      list[i] = i
      list.set(i, i)
    end

    count.times do |i|
#      assert_equal(list[i], i-10, "Element #{i} should have value #{i-10} not #{list[i]}")
      assert_equal(i-count, list.get(i), "Element #{i} should have value #{i-count} not #{list.get(i)}")
    end
  end

  def test_set_out_of_bounds(constructor)
    list = constructor.call
    index = 10
    elt = :foo
#    list[10] = :foo
    list.set(index, elt)

    assert(list.slice(0, index).elements.all? {|elt| elt == list.fill_elt}, "Empty elements should be filled with #{list.fill_elt}")
    assert_equal(index+1, list.size, "List should expand to accommodate out-of-bounds index.")
    assert_equal(elt, list.get(index), "Element #{index} should be #{elt}")
  end

  def test_index(constructor)
    count = 1000
    list = constructor.call.fill(count: count)

    1.upto(count) do |i|
      assert_equal(i-1, list.index(i), "The value #{i-1} should be located at index #{i}")
    end
  end

  def test_index_wrong_type(constructor)
    count = 1000
    list = constructor.call(type: Integer, fill_elt: 0).fill(count: count)

    assert_raises(ArgumentError, "Value of wrong type does not exist at any index.") { list.index(:foo) }
  end

  def test_index_predicate(constructor)
    list = constructor.call.add(*("a".."z").to_a)
    assert(("A".."Z").to_a.none? {|ch| list.index(ch)}, "Default test should fail.")
    assert(("A".."Z").to_a.all? {|ch| list.index(ch, test: ->(item, elt) { item.casecmp(elt).zero? })},
           "Specific test should succeed.")
  end

  def test_index_arithmetic(constructor)
    list = constructor.call.fill(count: 20)

    assert_equal(2, list.index(3), "Literal 3 should be at index 2.")
    assert_equal(2, list.index(3.0), "Integer equal to 3.0 should be present in list at index 2.") # ???
    assert_equal(3, list.index(3, test: ->(item, elt) { elt == item + 1 }),
                 "List contains the element one larger than 3 at index 3.")
    assert_equal(4, list.index(2, test: ->(item, elt) { elt > item * 2 }),
                 "First element in list larger than 2 doubled is 5 at index 4.")
    assert_equal(2, list.index(3, test: ->(item, elt) { elt % item == 0}),
                 "First multiple of 3 should be at index 2..")
  end
  
  def test_slice(constructor)
    count = 1000
    list = constructor.call.fill(count: count)

    j = count / 10
    n = count / 2
    slice = list.slice(j, n)

    assert_equal(n, slice.size, "Slice should contain #{n} elements")
    n.times do |i|
#      assert_equal(slice[i], i+j+1, "Element #{i} should have value #{i+j+1} not #{slice[i]}")
      assert_equal(list.get(i+j), slice.get(i), "Element #{i} should have value #{list.get(i+j)} not #{slice.get(i)}")
    end
  end

  def test_slice_negative_index(constructor)
    count = 1000
    list = constructor.call.fill(count: count)

    j = count / 2
    n = count / 2
    slice = list.slice(-j)

    assert_equal(n, slice.size, "Slice should contain #{n} elements")
    n.times do |i|
#      assert_equal(slice[i], i+j+1, "Element #{i} should have value #{i+j+1} not #{slice[i]}")
      assert_equal(list.get(i+j), slice.get(i), "Element #{i} should have value #{list.get(i+j)} not #{slice.get(i)}")
    end
  end

  def test_slice_corner_cases(constructor)
    count = 1000
    list = constructor.call.fill(count: count)

    n = 10

    slice = list.slice(list.size, n)
    assert(slice.empty?, "Slice at end of list should be empty")

    slice = list.slice(-n, n)
    assert_equal(slice.size, n, "Slice of last #{n} elements should have #{n} elements: #{slice.size}")

    slice = list.slice(-(count + 1), n)
    assert(slice.empty?, "Slice with invalid negative index should be empty")
  end

  def test_reverse(constructor)
    count = 1000
    original = constructor.call.fill(count: count)
    backward = original.reverse
    expected = constructor.call

    count.downto(1) do |i|
      expected.add(i)
    end

    assert_equal(expected, backward, "Reversed list should be: #{expected.slice(0, 20)} instead of: #{backward.slice(0, 20)}")

    forward = backward.reverse
    assert_equal(original, forward, "Reversed reversed list should be: #{original.slice(0, 20)} instead of: #{forward.slice(0, 20)}")
  end

  def test_append(constructor)
    count = 1000
    list1 = constructor.call.fill(count: count)
    list2 = constructor.call(type: Numeric, fill_elt: 0).fill(count: count, generator: ->(x) { x.to_f })
    list3 = list1.append(list2)
    list4 = list2.append(list1)
    list_x = constructor.call

    assert_equal(list1.type, list3.type, "Type of result list should be #{list1.class} not #{list3.class}")
    assert_equal(list2.type, list4.type, "Type of result list should be #{list2.class} not #{list4.class}")
    assert_equal(list3.size, list1.size + list2.size, "Result list should have same size as sum of input sizes")
    assert_equal(list4.size, list1.size + list2.size, "Result list should have same size as sum of input sizes")
    assert(list1.equals(list3.slice(0, count)), "Front of list3 should match list1")
    assert(list2.equals(list4.slice(0, count)), "Front of list4 should match list2")
    assert(list2.equals(list3.slice(count, count)), "Rear of list3 should match list2")
    assert(list1.equals(list4.slice(count, count)), "Rear of list4 should match list1")

    assert(list1.equals(list1.append(list_x)), "Appending empty list yields equal list")
    assert(list1.equals(list_x.append(list1)), "Appending empty list yields equal list")
  end
  
  def test_append_different_class(constructor)
    count = 1000
    list = constructor.call.fill(count: count)
    array_list = Containers::ArrayList.new.fill(count: count)
    doubly_linked_list = Containers::DoublyLinkedList.new.fill(count: count)

    assert_equal(list.class, list.append(array_list).class, "Appending list yields instance of same class as first list.")
    assert_equal(list.class, list.append(doubly_linked_list).class, "Appending list yields instance of same class as first list.")
    assert_equal(list.class, list.append(array_list.append(doubly_linked_list)).class, "Appending list yields instance of same class as first list.")
  end

  def test_append_type_compatibility(constructor)
    list1 = constructor.call.fill(count: 20)
    list2 = constructor.call(type: String, fill_elt: "").add(*("a".."z").to_a)

    assert_equal(list1.type, list1.append(list2).type, "Appending specialized list to more general list succeeds.")
    assert_raises(ArgumentError, "Cannot append more general list to specialized list.") { list2.append(list1) }
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
return

    Benchmark.bm do |run|
      run.report("add to front\n") do 
        10.times do
          10000.times do |j|
            list.insert(0, j)
          end
          list.clear
        end
      end
    end

    list.clear

    Benchmark.bm do |run|
      run.report("add to rear\n") do 
        10.times do
          10000.times do |j|
            list.add(j)
          end
          list.clear
        end
      end
    end

    list.clear

    Benchmark.bm do |run|
      run.report("delete front\n") do 
        10.times do
          list.fill(count: 10000)
          until list.empty?
            list.delete(0)
          end
        end
      end
    end

    Benchmark.bm do |run|
      run.report("delete rear\n") do
        10.times do
          list.fill(count: 10000)
          until list.empty?
            list.delete(-1)
          end
        end
      end
    end

    list.fill(count: 10000)
    Benchmark.bm do |run|
      run.report("sequential access\n") do
        10.times do
          list.size.times do |j|
            assert(list.get(j) == j + 1, "Element #{j} should be: #{j + 1}.")
          end
        end
      end
    end

    Benchmark.bm do |run|
      run.report("random access\n") do
        10.times do
          list.size.times do
            index = rand(list.size)
            assert(list.get(index) == index + 1, "Element #{index} should be: #{index + 1}.")
          end
        end
      end
    end
      
    puts
  end

  def test_wave(constructor)
    list = constructor.call

    Benchmark.bm do |run|
      run.report("Test wave\n") do
        list.fill(count: 5000)
        assert_equal(5000, list.size, "Size of list should be 5000")

        3000.times { list.delete(0) }
        assert_equal(2000, list.size, "Size of list should be 2000")
        
        list.fill(count: 5000)
        assert_equal(7000, list.size, "Size of list should be 7000")

        3000.times { list.delete(0) }
        assert_equal(4000, list.size, "Size of list should be 4000")

        list.fill(count: 5000)
        assert_equal(9000, list.size, "Size of list should be 9000")

        3000.times { list.delete(0) }
        assert_equal(6000, list.size, "Size of list should be 6000")

        list.fill(count: 4000)
        assert_equal(10000, list.size, "Size of list should be 10000")

        10000.times { list.delete(0) }
        assert(list.empty?, "List should be empty.")
      end
    end
  end
end

def list_test_suite(tester, constructor)
  puts("Testing #{constructor.call.class}")
  tester.test_constructor(constructor)
  tester.test_empty?(constructor)
  tester.test_size(constructor)
  tester.test_clear(constructor)
  tester.test_elements(constructor)
  tester.test_contains?(constructor)
  tester.test_contains_wrong_type(constructor)
  tester.test_contains_predicate(constructor)
  tester.test_contains_arithmetic(constructor)
  tester.test_equals(constructor)
  tester.test_equals_predicate(constructor)
  tester.test_equals_transform(constructor)
  tester.test_each(constructor)
  tester.test_add(constructor)
  tester.test_add_wrong_type(constructor)
  tester.test_insert(constructor)
  tester.test_insert_fill_zero(constructor)
  tester.test_insert_wrong_type(constructor)
  tester.test_insert_negative_index(constructor)
  tester.test_insert_end(constructor)
  tester.test_insert_offset(constructor)
  tester.test_delete(constructor)
  tester.test_delete_offset(constructor)
  tester.test_delete_random(constructor)
  tester.test_get(constructor)
  tester.test_get_negative_index(constructor)
  tester.test_set(constructor)
  tester.test_set_wrong_type(constructor)
  tester.test_set_negative_index(constructor)
  tester.test_set_out_of_bounds(constructor)
  tester.test_index(constructor)
  tester.test_index_wrong_type(constructor)
  tester.test_index_predicate(constructor)
  tester.test_index_arithmetic(constructor)
  tester.test_slice(constructor)
  tester.test_slice_negative_index(constructor)
  tester.test_slice_corner_cases(constructor)
  tester.test_reverse(constructor)
  tester.test_append(constructor)
  tester.test_append_different_class(constructor)
  tester.test_append_type_compatibility(constructor)
  tester.test_time(constructor)
  tester.test_wave(constructor)
end
  
class TestArrayList < TestList
  def test_it
    list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::ArrayList.new(type: type, fill_elt: fill_elt)})
  end
end

class TestSinglyLinkedList < TestList
  def test_it
    list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::SinglyLinkedList.new(type: type, fill_elt: fill_elt)})
  end
end

class TestSinglyLinkedListX < TestList
  def test_it
    list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::SinglyLinkedListX.new(type: type, fill_elt: fill_elt)})
  end
end

class TestDoublyLinkedList < TestList
  def test_it
    list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::DoublyLinkedList.new(type: type, fill_elt: fill_elt)})
  end
end

class TestDoublyLinkedListRatchet < TestList
  def test_it
    list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::DoublyLinkedListRatchet.new(type: type, fill_elt: fill_elt)})
  end
end

class TestDoublyLinkedListHash < TestList
  def test_it
    list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::DoublyLinkedListHash.new(type: type, fill_elt: fill_elt)})
  end
end

class TestHashList < TestList
  def test_it
    list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::HashList.new(type: type, fill_elt: fill_elt)})
  end
end

class TestHashListX < TestList
  def test_it
    list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::HashListX.new(type: type, fill_elt: fill_elt)})
  end
end

# Benchmark.measure { list = Containers::ArrayList.new; fill(list, 100000)}
# => #<Benchmark::Tms:0x000055edc060fb68 @cstime=0.0, @cutime=0.0, @label="", @real=3.5190064888447523, @stime=0.219943, @total=3.5186339999999996, @utime=3.298691>
# Benchmark.measure { list = Containers::SinglyLinkedList.new; fill(list, 100000)}
# => #<Benchmark::Tms:0x000055edc0a1e768 @cstime=0.0, @cutime=0.0, @label="", @real=100.8402192199137, @stime=0.01640999999999998, @total=100.788832, @utime=100.772422>
# Benchmark.measure { list = Containers::DoublyLinkedList.new; fill(list, 100000)}
# => #<Benchmark::Tms:0x000055edc08c44d0 @cstime=0.0, @cutime=0.0, @label="", @real=0.06819757912307978, @stime=0.0, @total=0.06819500000000289, @utime=0.06819500000000289>
# Benchmark.measure { list = Containers::HashList.new; fill(list, 100000)}
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
