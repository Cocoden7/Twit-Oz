declare
proc {Prod Count L}
   if Count > 100 then
      skip
   else
      local Count2 in
	 lock L then	    
	    Count2 = Count+1
	 end
	 {Browse Count}{Prod Count2 L}
      end
   end
end

proc{Cons S}
   case S of X|S2 then
      {Browse X} {Cons S2}
   end
end

local Count L in
   {NewLock L}
   Count = 1
   thread {Prod Count L} end 
   thread {Prod Count L} end 
end

      
   