#!/snap/bin/ruby -w

#    File:
#       balanced.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210427 Original.


# def recursive_balanced?(string)
# source = StringEnumerator.new(string)
# check_balanced?(source) && source.empty?
# end

# def check_balanced?(source)
# return true if source.empty?
# return false unless source.current == "["
# source.next
# if source.current == "["
# return false unless check_balanced?(source)
# end
# return false unless source.current == "]"
# source.next
# return check_balanced?(source) if source.current == "["
# true
# end

def recursive_balanced?(s)
  se = StringEnumerator.new(s)
  check_balanced(se)  &&  se.empty?
end

def check_balanced(se)
  if se.empty?
    true
  elsif se.current == "["
    se.advance
    if se.empty?
      false
    elsif se.current == "["
      check_start(se)
    elsif se.current == "]"
      check_end(se)
    else
      false
    end
  else
    false
  end
end

def check_start(se)
  if check_balanced(se)
    if se.empty?
      false
    elsif se.current == "]"
      check_end(se)
    else
      false
    end
  else
    false
  end
end

def check_end(se)
  se.advance
  if se.empty?
    true
  elsif se.current == "["
    check_balanced(se)
  elsif se.current == "]"
    true
  else
    false
  end
end

def recursive_balanced?(s)
  se = StringEnumerator.new(s)
  check_sequential(se)
end

def check_sequential(se)
  if se.empty?
    true
  elsif se.current == "["
    se.advance

    if se.empty?
      false
    elsif check_nested(se)
      if se.empty?
        false
      elsif se.current == "]"
        se.advance
        check_sequential(se)
      else
        false
      end
    else
      false
    end
  else
    false
  end
end

def check_nested(se)
  if se.empty?
    false
  elsif se.current == "["
    se.advance

    if se.empty?
      false
    elsif check_nested(se)
      if se.empty?
        false
      elsif se.current == "]"
        se.advance
        check_nested(se)
      else
        false
      end
    else
      false
    end
  elsif se.current == "]"
    true
  else
    false
  end
end

def check_balanced_iterative_string_enumerator?(s)
  se = StringEnumerator.new(s)
  count = 0

  until se.empty?
    case se.current
    when "[" then count += 1
    when "]" then count -= 1
    else return false
    end

    return false if count < 0
    se.advance
  end

  count.zero?
end

def check_balanced_iterative_string?(s)
  count = 0
  s.each_char do |ch|
    case ch
    when "[" then count += 1
    when "]" then count -= 1
    else return false
    end
    
    return false if count < 0
  end

  count.zero?
end

def check_balanced_stack_string_enumerator?(s)
    se = StringEnumerator.new(s)
    stack = Collections::LinkedStack.new

    until se.empty?
      case se.current
      when "[" then stack.push(se.current)
      when "]" then
        if stack.empty?
          return false
        else
          stack.pop
        end
      else return false
      end

      se.advance
    end

    stack.empty?
end

def check_balanced_stack_string?(s)
    stack = Collections::LinkedStack.new

    s.each_char do |ch|
      case ch
      when "[" then stack.push(ch)
      when "]" then
        if stack.empty?
          return false
        else
          stack.pop
        end
      else return false
      end
    end

    stack.empty?
end
