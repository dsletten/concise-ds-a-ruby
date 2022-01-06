#!/snap/bin/ruby -w

#    File:
#       string_enumerator.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       210427 Original.

class StringEnumerator
  def initialize(source)
    @s = source
    @index = 0
  end

  def empty?
    @index == @s.length
  end

  def current
    raise StandardError.new("String enumerator is empty.") if empty?
    do_current
  end
    
  def advance
    raise StandardError.new("String enumerator is empty.") if empty?
    do_advance
  end
  
  def reset
    @index = 0
  end

  def duplicate
    se = StringEnumerator.new(@s)
    se.index = @index
    se
  end

  private
  
  def do_current
    @s[@index]
  end

  def do_advance
    ch = current
    @index += 1
    ch
  end

  def index=(i)
    raise ArgumentError.new("Index out of bounds.") unless (0..@s.length).include?(i)
    @index = i
  end
end
