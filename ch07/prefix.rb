#!/snap/bin/ruby -w

#    File:
#       prefix.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210521 Original.

require 'set'
require '/home/slytobias/ruby/books/Concise/containers'

#
#    Recursive implementation
#    
def eval_prefix(s)
#  tokens = s.scan(/[-0-9+*\/%]/)
  tokens = s.scan(/\S+/) # Simpler for prefix vs. infix
#  tokens = s.scan(/\-?\d+\.?\d*|[-+*\/%()]/)
  value = eval_expression(tokens)
  raise "Too many arguments" unless tokens.empty?
  value
end

def eval_expression(tokens)
  raise "Missing argument" if tokens.empty?
  
  token = tokens.shift

  if operator?(token)
    evaluate(token, eval_expression(tokens), eval_expression(tokens))
  else
    token.to_i
  end
end

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

def process(operand, operator_stack, operand_stack)
  if !marked?(operator_stack)
    process_left_operand(operand, operator_stack, operand_stack)
  else
    process_right_operand(operand, operator_stack, operand_stack)
  end
end

def process_left_operand(op, operator_stack, operand_stack)
  mark(operator_stack)
  operand_stack.push(op)
end

def process_right_operand(op, operator_stack, operand_stack)
  operator_stack.pop
  raise "Missing operator" if operator_stack.empty?
  process(evaluate(operator_stack.pop, operand_stack.pop, op), operator_stack, operand_stack)
end

MARKER = :v

def marked?(stack)
  !stack.empty?  &&  stack.top == MARKER
end

def mark(stack)
  stack.push(MARKER)
end

#
#    Stack-based implementation
#    
def stack_eval_prefix(s)
  tokens = s.scan(/\S+/) # Simpler for prefix vs. infix
#  tokens = s.scan(/\-?\d+\.?\d*|[-+*\/%]/)
  raise "Missing expression" if tokens.empty?
  
  operator_stack = Collections::LinkedStack.new(Symbol)
  operand_stack = Collections::LinkedStack.new(Numeric)

  until tokens.empty?
    token = tokens.shift

    if operator?(token)
      operator_stack.push(token.to_sym)
    else
      process(token.to_i, operator_stack, operand_stack)
    end
  end

  raise "Missing argument" if operator_stack.empty?
  raise "Illegal state" unless marked?(operator_stack)
  raise "Missing expression" if operand_stack.empty?

  result = operand_stack.pop
  operator_stack.pop

  raise "Too many arguments" unless operand_stack.empty?
  raise "Missing argument" unless operator_stack.empty?
  
  result
end
