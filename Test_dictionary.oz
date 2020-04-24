functor
import
   WeakDictionary 
   Browser
define
   Browse = Browser.browse
   %IsEmpty = Dictionary.isEmpty
   local D in
      {Browse 3}
      D = 1
      {Browse D}
   end
end

   