#!/usr/bin/ruby -w

#    File:
#       test_mutable_linked_list.rb
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
  def test_mutable_linked_list_insert_before(constructor, get_node, next_node)
    list = constructor.call(type: Integer, fill_elt: 0)
    assert_raises(ArgumentError, "Can't call insert_before with wrong type.") { list.insert_before(nil, :foo) }
    assert_raises(ArgumentError, "Can't call insert_before on empty list.") { list.insert_before(nil, 8) }

    list.fill(count: 20)
    assert_raises(ArgumentError, "Can't insert_before nil node.") { list.insert_before(nil, 8) }

    start = get_node.call(list)
    child = next_node.call(list, start)
    grand_child = next_node.call(list, child)
    list.insert_before(grand_child, -99)
    assert_equal(-99, list.get(2), "Element after child should be -99")
  end

  def test_mutable_linked_list_insert_after(constructor, get_node, next_node)
    list = constructor.call(type: Integer, fill_elt: 0)
    assert_raises(ArgumentError, "Can't call insert_after with wrong type.") { list.insert_after(nil, :foo) }
    assert_raises(ArgumentError, "Can't call insert_after on empty list.") { list.insert_after(nil, 8) }

    list.fill(count: 20)
    assert_raises(ArgumentError, "Can't insert_after nil node.") { list.insert_after(nil, 8) }

    start = get_node.call(list)
    child = next_node.call(list, start)
    list.insert_after(child, -99)
    assert_equal(-99, list.get(2), "Element after child should be -99")
  end

  def test_mutable_linked_list_delete_node(constructor, get_node, next_node)
    list = constructor.call(type: Integer, fill_elt: 0)
    assert_raises(ArgumentError, "Can't call delete_node on empty list.") { list.delete_node(nil) }

    list.fill(count: 20)
    assert_raises(ArgumentError, "Can't delete_node nil node.") { list.delete_node(nil) }

    start = get_node.call(list)
    child = next_node.call(list, start)
    grand_child = next_node.call(list, child)
    list.delete_node(grand_child)
    assert_equal(4, list.get(2), "Element after child should be 4")
  end

  def test_mutable_linked_list_delete_child(constructor, get_node, next_node)
    list = constructor.call(type: Integer, fill_elt: 0)
    assert_raises(ArgumentError, "Can't call delete_child on empty list.") { list.delete_child(nil) }

    list.fill(count: 20)
    assert_raises(ArgumentError, "Can't delete_child nil node.") { list.delete_child(nil) }

    start = get_node.call(list)
    child = next_node.call(list, start)
    list.delete_child(child)
    assert_equal(4, list.get(2), "Element child child should be 4")
  end
end

def mutable_linked_list_test_suite(tester, constructor, get_node, next_node)
  puts("Testing #{constructor.call.class}")
  tester.test_mutable_linked_list_insert_before(constructor, get_node, next_node)
  tester.test_mutable_linked_list_insert_after(constructor, get_node, next_node)
  tester.test_mutable_linked_list_delete_node(constructor, get_node, next_node)
  tester.test_mutable_linked_list_delete_child(constructor, get_node, next_node)
end
  
class TestSinglyLinkedList < TestList
  def test_it
    mutable_linked_list_test_suite(self,
                                   lambda {|type: Object, fill_elt: nil| Containers::SinglyLinkedList.new(type: type, fill_elt: fill_elt)},
                                   ->(list) { list.store },
                                   ->(list, node) { node.rest })
  end
end

class TestSinglyLinkedListX < TestList
  def test_it
    mutable_linked_list_test_suite(self,
                                   lambda {|type: Object, fill_elt: nil| Containers::SinglyLinkedListX.new(type: type, fill_elt: fill_elt)},
                                   ->(list) { list.front },
                                   ->(list, node) { node.rest })
  end
end

class TestDoublyLinkedList < TestList
  def test_it
    mutable_linked_list_test_suite(self,
                                   lambda {|type: Object, fill_elt: nil| Containers::DoublyLinkedList.new(type: type, fill_elt: fill_elt)},
                                   ->(list) { list.store },
                                   ->(list, node) { node.succ })
  end
end

class TestDoublyLinkedListRatchet < TestList
  def test_it
    mutable_linked_list_test_suite(self,
                                   lambda {|type: Object, fill_elt: nil| Containers::DoublyLinkedListRatchet.new(type: type, fill_elt: fill_elt)},
                                   ->(list) { list.store },
                                   ->(list, node) { node.succ })
  end
end

class TestDoublyLinkedListHash < TestList
  def test_it
    mutable_linked_list_test_suite(self,
                                   lambda {|type: Object, fill_elt: nil| Containers::DoublyLinkedListHash.new(type: type, fill_elt: fill_elt)},
                                   ->(list) { list.head },
                                   ->(list, node) { list.next_dnode(node) })
  end
end
