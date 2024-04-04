#!/usr/bin/ruby -w
#    Hey, Emacs, this is a -*- Mode: Ruby -*- file!
#
#    File:
#       cyclic_counter.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       230707 Original.

class Counter
  def index
    raise NoMethodError, "#{self.class} does not implement index()"
  end
  
  def modulus
    raise NoMethodError, "#{self.class} does not implement modulus()"
  end
  
  def advance
    raise NoMethodError, "#{self.class} does not implement advance()"
  end
  
  def init
    raise NoMethodError, "#{self.class} does not implement init()"
  end
  
  def to_s
    "[#{index}/#{modulus}]"
  end
end

class CyclicCounter < Counter
  attr_reader :index, :modulus

  def initialize(modulus)
    raise ArgumentError.new("Modulus must be at least 1.") unless modulus >= 1
    @index = 0
    @modulus = modulus
  end

  def advance(n = 1)
    @index = (@index + n) % @modulus
  end

  def init(n = 0)
    @index = n % @modulus
  end
end

class PersistentCyclicCounter < Counter
  attr_reader :index, :modulus

  def initialize(index: 0, modulus: 1)
    raise ArgumentError.new("Modulus must be at least 1.") unless modulus >= 1
    @index = index % modulus
    @modulus = modulus
  end

  def advance(n = 1)
    PersistentCyclicCounter.new(index: @index + n, modulus: @modulus)
  end

  def init(n = 0)
    PersistentCyclicCounter.new(index: n, modulus: @modulus)
  end
end

      

  
