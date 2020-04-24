declare
Y = functor % ligne 3
import
   Dictionary 
   Browser
define
   Browse = Browser.browse
   %IsEmpty = Dictionary.isEmpty
   local D in
      {Browse 3}
      D = 1
      {Browse D}
   end
end % 15

local Dico X in
{Dictionary.new Dico}
{Dictionary.put Dico 3 2}
   
{Dictionary.get Dico 3 X}
{Browse X}
end