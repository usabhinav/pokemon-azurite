#===============================================================================
# Provides the utility of notifying other objects of changes in the state of the
# object of a class that includes this mixin.
# - Baustein
#===============================================================================
module Observable
  
  def initialize
    @observers = []
  end
  
  def attach(observer)
    @observers << observer
  end
  
  def detach(observer)
    @observers.delete(observer)
  end
  
  def notify(event=nil)
    for observer in @observers
      observer.update(self, event)
    end
  end

end

#===============================================================================
# Serves as an attachable to an observer, the latter arbitrarily executing the
# given Proc of an Updater instance.
# - Baustein
#===============================================================================
class Updater
  
  def initialize(updateproc)
    @updateproc = updateproc
    update(self)
  end
    
  def update(observer, event=nil)
    @updateproc.call(event)
  end
  
end

=begin
class Comparator
  
  def initialize(proc
    @proc = proc
  end
  
  def compare(val1, val2)
    return @proc.call(val1, val2)
  end
  
end
=end

class PriorityList
  
  def initialize(comparator)
    # A proc with arguments val1 and val2 which is supposed to have 
    # 3 possible returns
    # -1 - Meaning that val1 is lesser than val2
    # 0 - Meaning that val1 is equal to val2
    # 1 - Meaning that val1 is greater than val2
    # The returns do not have to correspond to how the values actually
    # are in relation to each other, they are only being treated as such.
    @comparator = comparator
    @head = nil
    @tail = nil
  end
  
  def add(value)
    push(value)
  end
  
  def push(value)
    
    if @head == nil
      @head = value
      @tail = head
    else
      
      currelem = @head
      
      if comparator.call(@head.value, value) < 1
      end
        
      # Todo: complete if needed
      
    end
    
  end
  
end

class LinkedElement
  
  attr_accessor :nextelem
  attr_accessor :value
  
  def initialize(value)
    @value = value
  end
    
end
