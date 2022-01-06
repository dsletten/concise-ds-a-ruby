#!/snap/bin/ruby -w

#    File:
#       postfix.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210614 Original.

require 'set'
require '/home/slytobias/ruby/books/Concise/containers'

OPERATORS = Set.new(["+", "-", "*", "/", "%"])
def operator?(token)
  OPERATORS.member?(token)
end

def evaluate(operator, op1, op2)
#puts("Evaluating #{op1} #{operator} #{op2}")
  case operator.to_s
  when "+" then op1 + op2
  when "-" then op1 - op2
  when "*" then op1 * op2
  when "/" then op1 / op2
  when "%" then op1 % op2
  else raise ArgumentError.new("Unrecognized operator: #{operator}")
  end
end

def eval_expression_2(op1, op2, tokens)
  raise "Missing argument" if tokens.empty?

  token = tokens.shift

  if operator?(token)
    evaluate(token, op1, op2)
  else
    begin
      eval_expression_2(op1, eval_expression_2(op2, Integer(token), tokens), tokens)
    rescue ArgumentError
      raise "Malformed postfix expression."
    end
  end
end

def eval_expression_1(op1, tokens)
  if tokens.empty?
    op1
  else
    begin
      token = Integer(tokens.shift)
      eval_expression_1(eval_expression_2(op1, token, tokens), tokens)
    rescue ArgumentError
      raise "Malformed postfix expression."
    end
  end
end

def eval_expression_start(tokens)
  raise "Missing argument" if tokens.empty?
  
  begin
    token = Integer(tokens.shift)
    eval_expression_1(token, tokens)
  rescue ArgumentError
    raise "Malformed postfix expression."
  end
end

#
#    Recursive implementation
#    
def eval_postfix(s)
  tokens = s.scan(/\S+/)
  value = eval_expression_start(tokens)
#  raise "Too many arguments" unless tokens.empty?
  value
end

#
#    Stack-based implementation
#    
def stack_eval_postfix(s)
  tokens = s.scan(/\S+/)
#  raise "Missing expression" if tokens.empty?
  
  stack = Collections::LinkedStack.new

  until tokens.empty?
    token = tokens.shift

    if operator?(token)
      raise "Missing argument" if stack.empty?
      right = stack.pop
      raise "Missing argument" if stack.empty?
      left = stack.pop
      stack.push(evaluate(token, left, right))
    else
      begin
        stack.push(Integer(token))
      rescue ArgumentError
        raise "Malformed postfix expression."
      end
    end
  end

  raise "Missing expression" if stack.empty?

  result = stack.pop

  raise "Too many arguments" unless stack.empty?
  
  result
end
  
