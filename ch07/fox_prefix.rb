#!/snap/bin/ruby -w

#    File:
#       fox_prefix.rb
#
#    Synopsis:
#       Fox's Recursive Algorithm to Evaluate Prefix Expressions (Fig. 3 pg. 69)
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210519 Original.

#
#    No whitespace!!!
#    recursive_eval_prefix("*+28%73")
#    
def recursive_eval_prefix(string)
  source = StringEnumerator.new(string)
  result = eval_prefix(source)
  raise "Too many arguments" unless source.empty?
  result
end

def eval_prefix(source)
  raise "Missing argument" if source.empty?
  ch = source.current
  source.next
  if ch =~ /\d/
    return ch.to_i
  else
    left_arg = eval_prefix(source)
    right_arg = eval_prefix(source)
    return evaluate(ch,left_arg, right_arg)
  end
end

def evaluate(op, left_arg, right_arg)
  case
  when op == '+' then return left_arg + right_arg
  when op == '-' then return left_arg - right_arg
  when op == '*' then return left_arg * right_arg
  when op == '/' then return left_arg / right_arg
  when op == '%' then return left_arg % right_arg
  end
end
