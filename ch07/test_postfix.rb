#!/snap/bin/ruby -w

#    File:
#       test_postfix.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210628 Original.

require './postfix.rb'
require 'test/unit'

class TestPostfix < Test::Unit::TestCase
  def test_postfix(f)
    tests = [["9", 9],
             ["    9    ", 9],
             ["2 3 -", -1],
             ["3 2 -", 1],
             ["2 3 +", 5],
             ["3 -6 *", -18],
             ["4 5 + 9 *", 81],
             ["2 8 + 7 3 % *", 10],
             ["2 3 * 5 + 4 %", 3],
             ["2 5 * 6 4 / % 2 3 * +", 6], # Should be 7!
             ["1 2 3 4 + + +", 10],
             ["1 2 + 3 + 4 +", 10],
             ["99 7 13 * -", 8]]

    tests.each do |test|
      expression, expected = test
      assert_equal(expected, f.call(expression))
    end

    ["2 3 +", "1 1 + 3 +", "8 8 / 1 + 3 +", "4 2 * 8 / 1 + 3 +"].each do |expression|
      assert_equal(5, f.call(expression))
    end

    ["2 3 +", "2 2 1 + +", "2 2 8 8 / + +", "2 2 8 4 2 * / + +"].each do |expression|
      assert_equal(5, f.call(expression))
    end
  end
end

class TestRecursive < TestPostfix
  def test_it
    test_postfix(method(:eval_postfix))
  end
end

class TestStack < TestPostfix
  def test_it
    test_postfix(method(:stack_eval_postfix))
  end
end
