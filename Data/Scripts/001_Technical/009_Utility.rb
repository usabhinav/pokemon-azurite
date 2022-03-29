# Creates a deep copy of any object. Probably not very efficient! Further inspection required.
# Consider defining "initialize_copy" for any class that needs more efficient copying.
def pbDeepCopy(object)
  return Marshal.load(Marshal.dump(object))
end