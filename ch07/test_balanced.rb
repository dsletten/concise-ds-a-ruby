#!/snap/bin/ruby -w

#    File:
#       test_balanced.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210510 Original.

require '../containers'
require './string_enumerator.rb'
require './balanced.rb'
require 'test/unit'

class TestBalanced < Test::Unit::TestCase
  def test_balanced?(f)
    balanced = ["", "[]", "[[]]", "[[[]]]", "[][]", "[[][]]", "[[]][[]]", "[[[][]][]]", "[][][[][[]]]", 
                "[[[[[[[[[[[][[[[]][]]]]]][[][]][][[[][]]][[][][]]]]][][[]][[][[[[]]]][[][]]][[]][[][[]][]][[]][[[[][][[[][][[[[[]][[[]][][[][[[[[[][][[]]][[[[][[][]][]][]]][][[[]]]]][][[[[]]]][]]][][[][][[[]]]][[[[[]][[[]]][[][]][]]][][]][[]]][]][[]][]][[[][][[][][]]][[][[[][]]][[[[][][][[[[[[]][[][[[[[[[[][[]][]][][[[]][[[][[][[]][[]][[][[]][]]][][]]]]][[][[][]]][]][[[][[]]][][]][]][]][[[[]]][[[]]]][][][[[][[][][[[][[][[][]]]][][]][[]]]]]][[[[]][][[]]][]][][][][[][]][]][]][[]]][[][][[]][[][[][[]][[[]][[[[[[]][]]][[][[[]]]][][][[[][]]][]]][[[[]]]]]]][][]]][][[[][]]][[][[][[[[[]][]][[[[[]]]][[][]]][[]]]]][]][]][][[][[][[]]][]][]]]][[]][[]]][[[][][][][[]][][[[[]][]]][]]][][[[][[[[[[[]][][]]][[[][][[]]]][][][[[[][]][]]]][]]]]][]]]]][]]][]]][][[[[][][]]][]]]]]]]"]

    balanced.each do |test|
      assert(f.call(test))
    end
  end

  def test_unbalanced?(f)
    unbalanced = ["[", "]", "[[]", "[]]", "[]]fads", "[]fads", "[a[]]", "[[]a]", "[[a]]", "[[]]a", "[[]a[]]", "[[[]][]][]]", 
                  "[[[[[[[[[[][[[[]][]]]]]][[][]][][[[][]]][[][][]]]]][][[]][[][[[[]]]][[][]]][[]][[][[]][]][[]][[[[][][[[][][[[[[]][[[]][][[][[[[[[][][[]]][[[[][[][]][]][]]][][[[]]]]][][[[[]]]][]]][][[][][[[]]]][[[[[]][[[]]][[][]][]]][][]][[]]][]][[]][]][[[][][[][][]]][[][[[][]]][[[[][][][[[[[[]][[][[[[[[[[][[]][]][][[[]][[[][[][[]][[]][[][[]][]]][][]]]]][[][[][]]][]][[[][[]]][][]][]][]][[[[]]][[[]]]][][][[[][[][][[[][[][[][]]]][][]][[]]]]]][[[[]][][[]]][]][][][][[][]][]][]][[]]][[][][[]][[][[][[]][[[]][[[[[[]][]]][[][[[]]]][][][[[][]]][]]][[[[]]]]]]][][]]][][[[][]]][[][[][[[[[]][]][[[[[]]]][[][]]][[]]]]][]][]][][[][[][[]]][]][]]]][[]][[]]][[[][][][][[]][][[[[]][]]][]]][][[[][[[[[[[]][][]]][[[][][[]]]][][][[[[][]][]]]][]]]]][]]]]][]]][]]][][[[[][][]]][]]]]]]]",
                  "[[[[[[[[[[[][[[[]][]]]]]][[][]][][[[][]]][[][][]]]]][][[]][[][[[[]]]][[][]]][[]][[][[]][]][[]][[[[][][[[][][[[[[]][[[]][][[][[[[[[][][[]]][[[[][[][]][]][]]][][[[]]]]][][[[[]]]][]]][][[][][[[]]]][[[[[]][[[]]][[][]][]]][][]][[]]][]][[]][]][[[][][[][][]]][[][[[][]]][[[[][][][[[[[[]][[][[[[[[[[][[]][]][][[[]][[[][[][[]][[]][[][[]][]]][][]]]]][[][[][]]][]][[[][[]]][][]][]][]][[[[]]][[[]]]][][][[[][[][][[[][[][[][]]]][][]][[]]]]]][[[[]][][[]]][]][][][][[][]][]][]][[]]][[][][[]][[][[][[]][[[]][[[[[[]][]]][[][[[]]]][][][[[][]]][]]][[[[]]]]]]][][]]][][[[][]]][[][[][[[[[]][]][[[[[]]]][[][]]][[]]]]][]][]][][[][[][[]]][]][]]]][[]][[]]][[[][][][][[]][][[[[]][]]][]]][][[[][[[[[[[]][][]]][[[][][[]]]][][][[[[][]][]]]][]]]]][]]]]][]]][]]][][[[[][][]]][]]]]]]",
                  "[[[[[[[[[[[][[[[]][]]]]]][[][]][][[[][]]][[][][]]]]][][[]][[][[[[]]]][[][]]][[]][[][[]][]][[]][[[[][][[[][][[[[[]][[[]][][[][[[[[[][][[]]][[[[][[][]][]][]]][][[[]]]]][][[[[]]]][]]][][[][][[[]]]][[[[[]][[[]]][[][]][]]][][]][[]]][]][[]][]][[[][][[][][]]][[][[[][]]][[[[][][][[[[[[]][[][[[[[[[[][[]][]][][[[]][[[][[][[]][[]][[][[]][]][][]]]]][[][[][]]][]][[[][[]]][][]][]][]][[[[]]][[[]]]][][][[[][[][][[[][[][[][]]]][][]][[]]]]]][[[[]][][[]]][]][][][][[][]][]][]][[]]][[][][[]][[][[][[]][[[]][[[[[[]][]]][[][[[]]]][][][[[][]]][]]][[[[]]]]]]][][]]][][[[][]]][[][[][[[[[]][]][[[[[]]]][[][]]][[]]]]][]][]][][[][[][[]]][]][]]]][[]][[]]][[[][][][][[]][][[[[]][]]][]]][][[[][[[[[[[]][][]]][[[][][[]]]][][][[[[][]][]]]][]]]]][]]]]][]]][]]][][[[[][][]]][]]]]]]]"]

    unbalanced.each do |test|
      assert(!f.call(test))
    end
  end
end

class TestRecursiveBalanced < TestBalanced
  def test_it
    test_balanced?(method(:recursive_balanced?))
    test_unbalanced?(method(:recursive_balanced?))
  end
end

class TestIterativeStringEnumerator < TestBalanced
  def test_it
    test_balanced?(method(:check_balanced_iterative_string_enumerator?))
    test_unbalanced?(method(:check_balanced_iterative_string_enumerator?))
  end
end

class TestIterativeString < TestBalanced
  def test_it
    test_balanced?(method(:check_balanced_iterative_string?))
    test_unbalanced?(method(:check_balanced_iterative_string?))
  end
end

class TestStackStringEnumerator < TestBalanced
  def test_it
    test_balanced?(method(:check_balanced_stack_string_enumerator?))
    test_unbalanced?(method(:check_balanced_stack_string_enumerator?))
  end
end

class TestStackString < TestBalanced
  def test_it
    test_balanced?(method(:check_balanced_stack_string?))
    test_unbalanced?(method(:check_balanced_stack_string?))
  end
end

