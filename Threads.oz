functor
import
   Reader
   Browser
define
   Browse = Browser.browse
%%% Easier macros for imported functions
   
%%% Read line
  % fun {GetFirstLine IN_NAME Line}
   %   {Reader.scan {New Reader.textfile init(name:IN_NAME)} Line}
   %end
   
%%% Stock each lines of the file in a list and returns it, N = 1
   %fun {ReadFile IN_NAME N}
   %   if {Reader.scan {New Reader.textfile init(name:IN_NAME)} N} == none then
%	 nil
 %     else
%	 {Reader.scan {New Reader.textfile init(name:IN_NAME)} N}|{ReadFile IN_NAME N+1}
 %     end
  % end
   
%%% Consumer
   proc{Disp S}
      case S of X|S2 then
	 {Browse X} {Disp S2}
      end
   end
   
   
   
%%% Producer
   fun {Prod N} {Delay 1000} N|{Prod N+1} end
   
   local S in
      thread
	 S = {Prod 1}
      end
      
      thread
	 {Disp S}
      end
   end
end






