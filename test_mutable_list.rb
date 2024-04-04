#!/usr/bin/ruby -w

#    File:
#       test_mutable_list.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       221223 Original.

require './containers'
require './list'
require 'test/unit'
require 'benchmark'

class TestList < Test::Unit::TestCase
  def test_mutable_list_clear(constructor)
    list = constructor.call
    assert(list.modification_count.zero?, "New list should not have been modified")

    list.fill(count: 20)
    list.clear
    assert_equal(2, list.modification_count, "Clearing filled list modifies it twice")

    list.clear
    assert_equal(2, list.modification_count, "Clearing empty list does not modify it again")
  end

  def test_mutable_list_add(constructor)
    list = constructor.call.add(2, 4, 6, 8)
    assert_equal(1, list.modification_count, "Adding multiple items is one modification")

    list.add(10)
    assert_equal(2, list.modification_count, "Subsequent addition is another modification")
  end

  def test_mutable_list_insert(constructor)
    list = constructor.call

    list.insert(0, 99)
    assert_equal(1, list.modification_count, "Inserting into empty list causes modification")

    list.insert(-5, 88)
    assert_equal(1, list.modification_count, "Invalid insertion does not cause modification")
  end

  def test_mutable_list_delete(constructor)
    list = constructor.call.fill(count: 20)

    list.delete(0)
    assert_equal(2, list.modification_count, "Deleting from filled list modifies it twice")

    list.delete(-1)
    assert_equal(3, list.modification_count, "Subsequent deletion is another modification")

    list.delete(-20)
    assert_equal(3, list.modification_count, "Invalid deletion does not cause modification")
  end
end

def mutable_list_test_suite(tester, constructor)
  puts("Testing #{constructor.call.class}")
  tester.test_mutable_list_clear(constructor)
  tester.test_mutable_list_add(constructor)
  tester.test_mutable_list_insert(constructor)
  tester.test_mutable_list_delete(constructor)
end
  
class TestArrayList < TestList
  def test_it
    mutable_list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::ArrayList.new(type: type, fill_elt: fill_elt)})
  end
end

class TestSinglyLinkedList < TestList
  def test_it
    mutable_list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::SinglyLinkedList.new(type: type, fill_elt: fill_elt)})
  end
end

class TestSinglyLinkedListX < TestList
  def test_it
    mutable_list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::SinglyLinkedListX.new(type: type, fill_elt: fill_elt)})
  end
end

class TestDoublyLinkedList < TestList
  def test_it
    mutable_list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::DoublyLinkedList.new(type: type, fill_elt: fill_elt)})
  end
end

class TestDoublyLinkedListRatchet < TestList
  def test_it
    mutable_list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::DoublyLinkedListRatchet.new(type: type, fill_elt: fill_elt)})
  end
end

class TestDoublyLinkedListHash < TestList
  def test_it
    mutable_list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::DoublyLinkedListHash.new(type: type, fill_elt: fill_elt)})
  end
end

class TestHashList < TestList
  def test_it
    mutable_list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::HashList.new(type: type, fill_elt: fill_elt)})
  end
end

class TestHashListX < TestList
  def test_it
    mutable_list_test_suite(self, lambda {|type: Object, fill_elt: nil| Containers::HashListX.new(type: type, fill_elt: fill_elt)})
  end
end
