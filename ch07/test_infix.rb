#!/snap/bin/ruby -w

#    File:
#       test_infix.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210628 Original.


require './infix.rb'
require 'test/unit'

class TestInfix < Test::Unit::TestCase
  def test_infix(f)
    tests = [["9", 9],
             ["(9)", 9],
             ["    9    ", 9],
             ["(2 + 3)", 5],
             ["(3 * -6)", -18],
             ["(10 / 5)", 2],
             ["(10 / -5)", -2],
             ["10 / 5", 2],
             ["10 / -5", -2],
             ["9 * 8", 72],
             ["(4 + 5) * 9", 81],
             ["(2 + 8) * (7 % 3)", 10],
             ["(2 * 3 + 5) % 4", 3],
             ["2 * 5 % (6 / 4) + (2 * 3)", 7], # Correct with floats!
             ["1 + 2 + 3 + 4", 10],
             ["(1 + (2 + (3 + 4)))", 10],
             ["(((1 + 2) + 3) + 4)", 10],
             ["99 - 7 * 13", 8]]

    tests.each do |test|
      expression, expected = test
      assert_equal(expected, f.call(expression))
    end

    ["2 + 3", "1 + 1 + 3", "8 / 8 + 1 + 3", "4 * 2 / 8 + 1 + 3"].each do |expression|
      assert_equal(5, f.call(expression))
    end

    ["2 + 3", "2 + 2 + 1", "2 + 2 + 8 / 8", "2 + 2 + 8 / (4 * 2)"].each do |expression|
      assert_equal(5, f.call(expression))
    end
  end
end

class TestRecursive < TestInfix
  def test_it
    test_infix(method(:eval_infix))
  end
end

class TestStack < TestInfix
  def test_infix
    tests = [["9", 9],
             ["    9    ", 9],
             ["(2 + 3)", 5],
             ["(3 * -6)", -18],
             ["(10 / 5)", 2],
             ["(10 / -5)", -2],
             ["(9 * 8)", 72],
             ["((4 + 5) * 9)", 81],
             ["((2 + 8) * (7 % 3))", 10],
             ["(((2 * 3) + 5) % 4)", 3],
             ["(((2 * 5) % (6 / 4)) + (2 * 3))", 7], # Correct with floats!
             ["(1 + (2 + (3 + 4)))", 10],
             ["(((1 + 2) + 3) + 4)", 10],
             ["(99 - (7 * 13))", 8]]
    tests.each do |test|
      expression, expected = test
      assert_equal(expected, stack_eval_infix(expression))
    end
    
    ["(2 + 3)", "((1 + 1) + 3)", "(((8 / 8) + 1) + 3)", "((((4 * 2) / 8) + 1) + 3)"].each do |expression|
      assert_equal(5, stack_eval_infix(expression))
    end

    ["(2 + 3)", "(2 + (2 + 1))", "(2 + (2 + (8 / 8)))", "(2 + (2 + (8 / (4 * 2))))"].each do |expression|
      assert_equal(5, stack_eval_infix(expression))
    end
  end
end

# (deftest test-infix (f)
#   (check
#    (= (funcall f "9") 9)
#    (= (funcall f "(9)") 9) ; Superfluous ()
#    (= (funcall f "    9    ") 9)
#    (= (funcall f "(10 / 5)") 2)
#    (= (funcall f "10 / 5") 2)
#    (= (funcall f "(10 / -5)") -2)
#    (= (funcall f "10 / -5") -2)
#    (= (funcall f "(9 * 8)") 72)
#    (= (funcall f "9 * 8") 72)
#    (= (funcall f "2 + 3") 5)
#    (= (funcall f "3 * -6") -18)
#    (= (funcall f "(4 + 5) * 9") 81)
#    (= (funcall f "((2 + 8) * (7 % 3))") 10)
#    (= (funcall f "(2 + 8) * (7 % 3)") 10)
#    (= (funcall f "(((2 * 3) + 5) % 4)") 3)
#    (= (funcall f "(2 * 3 + 5) % 4") 3)
#    ;;
#    ;;    The following test is iffy. It makes perfect sense in Lisp,
#    ;;    but it is probably not the same result as in Ruby/Java.
#    ;;    The result of evaluating the first 3 operators (mod (* 2 5) (/ 6 4)) is:
#    ;;    (mod 10 6/4) => 1
#    ;;    Since
#    ;;    (floor 10 6/4) => 6; 1
#    ;;    But in Ruby/Java, 6/4 => 1
#    ;;    Equivalently:
#    ;;    (mod 10 (truncate 6 4)) => 0
#    ;;    Since
#    ;;    (truncate 6 4) => 1; 2
#    ;;    
#    (= (funcall f "(((2 * 5) % (6 / 4)) + (2 * 3))") 7)
#    (= (funcall f "(2 * 5 % (6 / 4)) + 2 * 3") 7)
#    (apply #'= 10 (mapcar f '("(1 + (2 + (3 + 4)))" "(((1 + 2) + 3) + 4)" "1 + (2 + (3 + 4))" "((1 + 2) + 3) + 4" "1 + 2 + 3 + 4")))
#    (= (funcall f "(((1 + 2) + 3))") 6) ; Extra ()
#    (= (funcall f "99 - 7 * 13") (- 99 (* 7 13))) ; Fox only handles single-digit numerals!
#    (apply #'= (mapcar f '("2 + 3" "(1 + 1) + 3" "(8 / 8 + 1) + 3" "4 * 2 / 8 + 1 + 3")))
#    (apply #'= (mapcar f '("2 + 3" "2 + (2 + 1)" "2 + (2 + 8 / 8)" "2 + (2 + 8 / (4 * 2))")))) )
