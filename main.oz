functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   Application
   Browser
   Open
   System
define
%%% Easier macros for imported functions
   Browse = Browser.browse
   Show = System.show

%%% File is a string. 
%%% Returns : The String with only points instead of ',' ';' '?' '!' ...
   fun {MakePointFromFile File}
      %local
	 %fun {MakePoint Line}
      case File of H|T then
	 if H == 46 then
	    46|{MakePointFromFile T}   
	 elseif H == 46 andthen T.1 == 46 then
	    46|{MakePointFromFile T}
	 elseif H == 46 andthen T.1 == 46 andthen T.2.1 == 46 then
	    46|{MakePointFromFile T}
	 elseif H == 46 andthen T.1 == 46 andthen T.2.1 == 46 andthen T.2.2.1 == 46 then
	    46|{MakePointFromFile T}
	 elseif H == 46 andthen T.1 == 46 andthen T.2.1 == 46 andthen T.2.2.1 == 46 andthen T.2.2.2.1 == 46 then
	    46|{MakePointFromFile T}
	 elseif H == 33 then
	    46|{MakePointFromFile T}
	 elseif H == 33 andthen T.1 == 33 then
	    46|{MakePointFromFile T}
	 elseif H == 33 andthen T.1 == 33 andthen T.2.1 == 33 then
	    46|{MakePointFromFile T}
	 elseif H == 33 andthen T.1 == 33 andthen T.2.1 == 33 andthen T.2.2.1 == 33 then
	    46|{MakePointFromFile T}
	 elseif H == 33 andthen T.1 == 33 andthen T.2.1 == 33 andthen T.2.2.1 == 33 andthen T.2.2.2.1 == 33 then
	    46|{MakePointFromFile T}
	 elseif H == 63 orelse H == 34 orelse H == 35 orelse H == 40 orelse H == 41 orelse H == 42 orelse H == 58
	    orelse H == 59 orelse H == 64 orelse H == 91 orelse H == 123 orelse H == 125 then
	    46|{MakePointFromFile T}
	 else
	    H|{MakePointFromFile T}
	 end
      else
	 nil
      end
   end

   
%%% Returns : the String without capital letters
   fun {ToLower String}
      case String of H|T then
	 if {Char.isUpper H} then
	    {Char.toLower H}|{ToLower T}
	 else
	    H|{ToLower T}
	 end
      else 
	 nil
      end
   end
   
   % File : Name of the file 
   % Returns : Splits the file by '.' and returns it as a list
   fun {CorrectInput File}
      local F Str in
	 F={New Open.file init(name:File flags:[read])}
	 {F read(list:Str size:all)}
	 {F close}
	 {String.tokens {MakePointFromFile {ToLower Str}} 46}
      end
   end

   %%% Producer : Take the tweet files between Count and Val, apply CorrectInput to each one and merge them together in a list
   fun {Prod Count Val}
      if Count < Val+1 then
	  {CorrectInput {VirtualString.toString 'tweets/part_'#Count#'.txt'}}|{Prod Count+1 Val}
      else
	 nil
      end
   end

   
%%%%%%%%%%%%%%%%%%%% Dictionary part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%% WordsList : a list of words.
%%% Returns : Dic(word1:Dic(word2:1, word57:2...) word2:Dic(word3:2, word45:3...)...) (example)
   proc {CreateRec WordsList Dico}
      case WordsList of H|T then
	 case T of nil then
	    skip
	 else
	    if {Dictionary.member Dico {StringToAtom H}} then
	       local ValueDico Freq in
		  {Dictionary.get Dico {StringToAtom H} ValueDico}
		  if {Dictionary.member ValueDico {StringToAtom T.1}} then % regarde si T.1 (le mot juste apres )H est deja associe a H
		     {Dictionary.get ValueDico {StringToAtom T.1} Freq}
		     {Dictionary.put ValueDico {StringToAtom T.1} Freq+1} % On ajoute 1 a la freq
		  else % si T n'a encore jamais été vu après H 
		     {Dictionary.put ValueDico {StringToAtom T.1} 1}
		  end
	       end
	    else
	       local ValueDico in
		  {Dictionary.new ValueDico}
		  {Dictionary.put ValueDico {StringToAtom T.1} 1}
		  {Dictionary.put Dico {StringToAtom H} ValueDico}
	       end
	    end
	    {CreateRec T Dico}	    
	 end
      [] nil then
	 skip
      end
   end


%%% Files : List of files formated by CorrectInput
%%% Returns : Dic(word1:Dic1(word2:2 word19:4...) word2:Dic2(word3:2 word78:5...) word3:Dic3(word4:3 word8:1...) ...) with all the words of all files 
   proc {DicoFromFiles Files Dico Lock}
      local
	 proc {DicoFromFile ListFile Dico Lock}
	    case ListFile of H|T then
	       lock Lock then
		  {CreateRec {String.tokens H 32} Dico}
		  {DicoFromFile T Dico Lock}
	       end	 
	    else
	       skip
	    end
	 end
      in
	 case Files of S1|S2 then
	    {DicoFromFile S1 Dico Lock} {DicoFromFiles S2 Dico Lock}
	 else
	    skip
	 end
      end
   end

%%% Get Key in Dico and stock it in R, deals with the case where the key doesn't exist
   proc {DicoGetter Dico Key R}
      local B in
	 {Dictionary.member Dico Key B}
	 if B then
	    {Dictionary.get Dico Key R}
	 else
	    R = "Can't find this word"
	 end
      end
   end

	 
%%%%%%%%%% Get best word part %%%%%%%%%%%%%%%%

%%% Returns the index of the max of a list L (I = 1, Maxi = 0)
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

%%% Returns the Key with the highest Value in Dic 
   fun {GetHighestFreq Dic}
      local Keys Items Index in
	 Keys = {Dictionary.keys Dic}
	 Items = {Dictionary.items Dic}
	 Index = {Max Items 1 1 0}
	 {Nth Keys Index}
      end
   end
      
   local L1 L2 D1 A Lock T1 T2
         
%%% GUI
    % Make the window description, all the parameters are explained here:
    % http://mozart2.org/mozart-v1/doc-1.4.0/mozart-stdlib/wp/qtk/html/node7.html)
   
    % Build the layout from the description
      Text1 Text2 E Description=td(
				  title: "Twit-Oz"
				  entry(init:"Type a sentence here."
					handle:E
					background:black
					action:proc{$} {Text1 set(1:{String.toAtom {E get($)}})} end )
				  lr(
				     text(handle:Text1 width:28 height:5 background:white foreground:black wrap:word)
				     button(text:"Match" action:Press)
				     button(text:"Clean" action:Restart)
				     )
				  text(handle:Text2 width:28 height:5 background:black foreground:white glue:w wrap:word)
				  action:proc{$}{Application.exit 0} end % quit app gracefully on window closing
				     )
%%% Executed when the button match is hit
      proc {Press}
	 Inserted D5 ByteS in
	 Inserted = {Text1 getText(p(1 0) 'end' $)} % example using coordinates to get text
	 {DicoGetter D1 {StringToAtom  {ToLower {GetLastWordOfPhrase {String.tokens Inserted 32}}}} D5}
	 if {IsDictionary D5} then
	    {Text2 set(1:{GetHighestFreq D5})}
	 else
	    {Text2 set(1:D5)}
	 end
      end
      
%%% Executed when the button restart is hit
      proc {Restart}
	 {E set(1:"Type a sentence here.")}
	 {Text1 set(1:"")}
	 {Text2 set(1:"...")} % you can get/set text this way too
      end

%%% Returns : the last word of ListOfWord, useful when the user writes a sentence
      fun {GetLastWordOfPhrase ListOfWord}
	 case ListOfWord of H|T then
	    if T == nil then {GetWithoutBackSlash H}
	    else
	       {GetLastWordOfPhrase T}
	    end
	 end
      end

%%% Removes occurences of '\n' in Word
      fun {GetWithoutBackSlash Word}
	 case Word of H|T then
	    if H == 10 then {GetWithoutBackSlash T}
	    else
	       H|{GetWithoutBackSlash T}
	    end
	 else
	    nil
	 end
      end
      
   in
      
%%% Threads for reading %%%
      {NewLock Lock}
      {Show 'Starts reading and parsing tweets...'}
      thread
	 L1 = {Prod 1 70}
	 {Show 'Thread 1 has ended reading.'}
	 T1 = 1
      end
      thread
	 L2 = {Prod 71 208}
	 {Show 'Thread 2 has ended reading.'}
	 T2 = 2
      end
      
%%% Threads for parsing %%%
      {Dictionary.new D1}
      thread
	 {DicoFromFiles L1 D1 Lock}
	 A = 1
      end
      {DicoFromFiles L2 D1 Lock}
      {Wait T1}
      {Wait T2}
      {Show 'End of reading.'}
      {Wait A}
      {Show 'Dictionary done.'}

%%% Launch GUI %%%
      W={QTk.build Description}
      {W show}
      {Text1 tk(insert 'end' "...")}
      {Text1 bind(event:"<Control-s>" action:Press)} % You can also bind events
   end   
end

