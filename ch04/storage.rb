#!/snap/bin/ruby -w

#    File:
#       storage.rb
#
#    Synopsis:
#
#
#    Revision History:
#        Date             Change Description
#       ------ -----------------------------------------
#       201219 Original.

NUM_LOCKERS = 138

#
#    @inv: @rented.length == NUM_LOCKERS
#    @inv: 0 <= @available_lockers <= NUM_LOCKERS
#    
class StorageFacility
  attr_reader :available_lockers
  
  # Set up the locker room data structures
  def initialize
    @rented = Array.new(NUM_LOCKERS, false)
    @available_lockers = NUM_LOCKERS
  end

  # Find an empty locker, mark it rented, return its number
  # @pre: !full?
  # @post: @available_lockers == old.@available_lockers - 1
  def rent_locker
    raise StandardError.new("Storage facility is full.") if full?
    locker_number = @rented.find_index(false)
    @rented[locker_number] = true
    @available_lockers -= 1
    locker_number
  end

  # Mark a locker as no longer rented
  # @pre: valid_locker?(locker_number), !free?(locker_number)
  # @post: free?(locker_number), @available_lockers == old.@available_lockers + 1
  def release_locker(locker_number)
    raise ArgumentError.new("Invalid locker: #{locker_number}") unless valid_locker?(locker_number)
    raise ArgumentError.new("Locker is not in use: #{locker_number}") if free?(locker_number)
    @rented[locker_number] = false
    @available_lockers += 1
  end
  
  # Say whether a locker is for rent
  # @pre: 0 <= locker_number < NUM_LOCKERS
  def free?(locker_number)
    raise ArgumentError.new("Invalid locker: #{locker_number}") unless valid_locker?(locker_number)
    !@rented[locker_number]
  end

  # Say whether any lockers are left to rent
  def full?
    @available_lockers.zero?
  end

  private
  def capacity
    @rented.size
  end

  def valid_locker?(locker)
    (0...capacity).cover?(locker)
  end
end
