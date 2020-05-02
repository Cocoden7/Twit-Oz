declare
fun {Max L I IMax Maxi}
   case L of H|T then
      if H > Maxi then
	 {Max T I+1 I H}
      else
	 {Max T I+1 IMax Maxi}
      end
   else
      IMax
   end
end

local Dico Dico2 X Entries Keys Items I  in
   I = {Max [10 15 4 20 40 8 80 100 10 20 30] 1 1 0}
   {Browse I}
   
   {Dictionary.new Dico}
   {Dictionary.new Dico2}
   {Dictionary.put Dico2 caca 10}
   {Dictionary.put Dico pipi Dico2}
   {Dictionary.put Dico 3 10}
   {Dictionary.put Dico bjr 10}
   {Dictionary.get Dico bjr X}
   
   Entries = {Dictionary.entries Dico}
   Items = {Dictionary.items Dico}
   Keys = {Dictionary.keys Dico}
   {Browse Entries}
   {Browse Keys}
   {Browse Items}
   {Browse X}
   {Browse Dico}
end