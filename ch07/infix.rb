#!/snap/bin/ruby -w

#    File:
#       infix.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210628 Original.

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

#
#    Sedgewick Algorithms 4e pg. 129
#    Must be fully parenthesized.
#    
def stack_eval_infix(s)
#  tokens = s.scan(/\-?\d+\.?\d*|\W/)
  tokens = s.scan(/\-?\d+\.?\d*|[-+*\/%()]/)

  raise "Missing expression" if tokens.empty?
  
  operator_stack = Collections::LinkedStack.new(Symbol)
  operand_stack = Collections::LinkedStack.new(Numeric)

  until tokens.empty?
    token = tokens.shift

    next if token =~ /\s+/

    if token == "(" # Ignore
    elsif token == ")"
      op = operator_stack.pop
      op2 = operand_stack.pop
      op1 = operand_stack.pop
      operand_stack.push(evaluate(op, op1, op2))
    elsif operator?(token)
      operator_stack.push(token.to_sym)
    else
      operand_stack.push(token.to_f)
    end
  end

  operand_stack.pop
end

#
#    Art of Java recursive descent parser. Relaxes requirement for parenthesization.
#    Precedence hard-wired into structure of recursive function calls.
#

#
#    Need list of tokens since we might need to pushback misinterpreted token.
#    Harder to do with stream...
#    
#    This is slightly different than Lisp version. It filters out unrecognized chars:
#    tokenize("2 $ 3") => ["2", "3"]
#    vs.
#    (tokenize "2 $ 3") => (2 $ 3)
#    
def tokenize(s)
  s.scan(/\-?\d+\.?\d*|[-+*\/%()]/)
end

def eval_infix(s)
  result, tokens = eval_expression(tokenize(s))
  raise "Malformed expression. Remaining tokens: #{tokens}" unless tokens.empty?
  result
end

def eval_expression(tokens)
  raise "Missing expression" if tokens.empty?
  eval_term(tokens.shift, tokens)
end

def eval_term(token, tokens)
  op1, more = eval_factor(token, tokens)

  if more.empty?
    [op1, []]
  else
    eval_additive(op1, more.shift, more)
  end
end

def eval_additive(op1, operator, tokens)
  case operator
  when "+", "-"
    raise "Missing argument to #{operator}" if tokens.empty?
    op2, more = eval_factor(tokens.shift, tokens)
    
    if more.empty?
      [evaluate(operator, op1, op2), []]
    else
      eval_additive(evaluate(operator, op1, op2), more.shift, more) # Sensitive to evaluation order?!
    end
  else
    tokens.unshift(operator)
    [op1, tokens]
  end
end

def eval_factor(token, tokens)
  op1, more = eval_parenthesized(token, tokens)

  if more.empty?
    [op1, []]
  else
    eval_multiplicative(op1, more.shift, more)
  end
end

def eval_multiplicative(op1, operator, tokens)
  case operator
  when "*", "/", "%"
    raise "Missing argument to #{operator}" if tokens.empty?
    op2, more = eval_parenthesized(tokens.shift, tokens)
    
    if more.empty?
      [evaluate(operator, op1, op2), []]
    else
      eval_multiplicative(evaluate(operator, op1, op2), more.shift, more) # Sensitive to evaluation order?!
    end
  else
    tokens.unshift(operator)
    [op1, tokens]
  end
end

def eval_parenthesized(token, tokens)
  case token
  when "("
    result, more = eval_expression(tokens)
    raise "Missing delimiter" if (more.empty? || more.shift != ")")
    [result, more]
  else
    [eval_atom(token), tokens]
  end
end

def eval_atom(token)
  begin
    Float(token)
  rescue ArgumentError, TypeError
    raise "Malformed atom #{token}"
  end
end
