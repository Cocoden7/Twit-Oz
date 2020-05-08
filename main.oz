functor
import
   QTk at 'x-oz://system/wp/QTk.ozf'
   System
   Application
   OS
   Browser
   Reader
define
%%% Easier macros for imported functions
   Browse = Browser.browse
   Show = System.show
   
%%% Read Ith line (un peu useless)
   fun {GetLine IN_NAME I}
      {Reader.scan {New Reader.textfile init(name:IN_NAME)} I}
   end


%%% Stock each lines of the file in a list and returns it, N = 1
   fun {ReadFile IN_NAME N}
      if {Reader.scan {New Reader.textfile init(name:IN_NAME)} N} == none then
	 nil
      else
	 {Reader.scan {New Reader.textfile init(name:IN_NAME)} N}|{ReadFile IN_NAME N+1}
      end
   end


%%% File is a list of lines. 
%%% Returns : List of all the lines with only points (no ',' ';' '?' '!' ...)
   fun {MakePointFromFile File}
      local
	 fun {MakePoint Line}
	    case Line of H|T then
	       if H == 46 then
		  46|{MakePoint T}   
	       elseif H == 46 andthen T.1 == 46 then
		  46|{MakePoint T}
	       elseif H == 46 andthen T.1 == 46 andthen T.2.1 == 46 then
		  46|{MakePoint T}
	       elseif H == 46 andthen T.1 == 46 andthen T.2.1 == 46 andthen T.2.2.1 == 46 then
		  46|{MakePoint T}
	       elseif H == 46 andthen T.1 == 46 andthen T.2.1 == 46 andthen T.2.2.1 == 46 andthen T.2.2.2.1 == 46 then
		  46|{MakePoint T}
	       elseif H == 33 then
		  46|{MakePoint T}
	       elseif H == 33 andthen T.1 == 33 then
		  46|{MakePoint T}
	       elseif H == 33 andthen T.1 == 33 andthen T.2.1 == 33 then
		  46|{MakePoint T}
	       elseif H == 33 andthen T.1 == 33 andthen T.2.1 == 33 andthen T.2.2.1 == 33 then
		  46|{MakePoint T}
	       elseif H == 33 andthen T.1 == 33 andthen T.2.1 == 33 andthen T.2.2.1 == 33 andthen T.2.2.2.1 == 33 then
		  46|{MakePoint T}
	    % ?
	       elseif H == 63 orelse H == 34 orelse H == 35 orelse H == 40 orelse H == 41 orelse H == 42 orelse H == 58
		  orelse H == 59 orelse H == 64 orelse H == 91 orelse H == 123 orelse H == 125 then
		  46|{MakePoint T}
	       else
		  H|{MakePoint T}
	       end
	    else
	       nil
	    end
	 end
      in
	 case File of L1|L2 then
	    {MakePoint L1}|{MakePointFromFile L2}	 
	 else
	    nil
	 end
      end
   end

%%% File : list of lines with only points (output of MakePointFromFile)
%%% Returns : Split each lines by '.' and returns each phrases in a list
   % example : ["salut iohef. duzgfzn eofn.foehiuh." "jizfioi. ziofhoifhnz. ofehiufh."] -> ["salut iohef" "duzgfzn eofn" "..."]
   fun {FileToPhrase File}
      case File of H|T then
	 {Append {String.tokens H 46} {FileToPhrase T}}
      [] nil then
	 nil
      end
   end
   
%%% Split the phrase by Char (point = 46)
   fun {GetWords Line Char}
      {String.tokens Line Char}
   end

%%% Returns : Str without more than one space
   fun {FilterEmpty Str}
      case Str of H|T then
	 if {StringToAtom H} == '' then
	    {FilterEmpty T}
	 else
	    H|{FilterEmpty T}
	 end
      else
	 nil
      end
   end
   
   
%%% File : list of lines
%%% Returns : the list of lines without capital letters
   fun {FilterMaj File}
      local
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
      in
	 case File of H|T then
	    {Map H ToLower}|{FilterMaj T}
	 else
	    nil
	 end
      end
   end
   
   % Faire un ToLower !
   % File : name of the file 
   % Returns : a list of phrases from the file
   fun {CorrectInput File}
       {FileToPhrase {MakePointFromFile {ReadFile File 1}}}
   end

%%%%%%%%%%%%%%%%%%%% Dictionary part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      %%% Returns : True if Dico contains the key Word
   fun {Contains Dico Word}
      local B in
	 {Dictionary.member Dico Word B}
	 B
      end
   end


%%% WordsList : a list of words.
%%% Returns : Dic(word1:Dic(word2:1, word57:2...) word2:Dic(word3:2, word45:3...)...) 
   proc {CreateRec WordsList Dico}
      case WordsList of H|T then
	 case T of nil then
	    skip
	 else
	    if {Contains Dico {StringToAtom H}} then
	       local ValueDico Freq in
		  {Dictionary.get Dico {StringToAtom H} ValueDico}
		  if {Contains ValueDico {StringToAtom T.1}} then % regarde si T.1 (le mot juste apres )H est deja associe a H
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
   
   
%%% Producer : Take the tweet files between Count and Val, apply CorrectInput and merge them together in a list
   fun {Prod Count Val}
      if Count < Val+1 then
	  {CorrectInput {VirtualString.toString 'tweets/part_'#Count#'.txt'}}|{Prod Count+1 Val}
      else
	 nil
      end
   end


%%% ListFile : List of phrases
%%% Returns : Dic(word1:Dic1(word2:2 word19:4...) word2:Dic2(word3:2 word78:5...) word3:Dic3(word4:3 word8:1...) ...) with all the words 
   proc {DicoFromFile ListFile Dico Lock}
      case ListFile of H|T then
	 lock Lock then
	    {CreateRec {GetWords H 32} Dico}
	    {DicoFromFile T Dico Lock}
	 end	 
      else
	 skip
      end
   end
   
   proc {DicoFromFiles Files Dico Lock}
      local
	 proc {DicoFromFile ListFile Dico Lock}
	    case ListFile of H|T then
	       lock Lock then
		  {CreateRec {GetWords H 32} Dico}
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

   %%% Get keys in Dico and stock it in R
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


%%% Returns the Word with the highest freq in Dic 
   fun {GetHighestFreq Dic}
      local Keys Items Index in
	 Keys = {Dictionary.keys Dic}
	 Items = {Dictionary.items Dic}
	 Index = {Max Items 1 1 0}
	 {Nth Keys Index}
      end
   end
   
   
%%% Returns the index of the max of a list L (I = 1, Max = 0)
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
      
   local Dico Dico2 Phrases Tweet Point Points PointsFile I I2 X Count S TweetNames L1 L2 L3 L4 D1 D2 D3 D4 A B C D BestWord Lock
         
%%% GUI
    % Make the window description, all the parameters are explained here:
    % http://mozart2.org/mozart-v1/doc-1.4.0/mozart-stdlib/wp/qtk/html/node7.html)
   
    % Build the layout from the description
      Text1 Text2 E R Description=td(
				  title: "Frequency count"
				  entry(init:"type a word here"
					handle:E
					return:R
					background:black
					action:proc{$} {Show {String.toAtom {E get($)}}} {Text1 set(1:{String.toAtom {E get($)}})} end )
				  lr(
				     text(handle:Text1 width:28 height:5 background:white foreground:black wrap:word)
				     button(text:"Match" action:Press)
				     button(text:"Clean" action:Restart)
				     )
				  text(handle:Text2 width:28 height:5 background:black foreground:white glue:w wrap:word)
				  action:proc{$}{Application.exit 0} end % quit app gracefully on window closing
				     )
      proc {Press}
	 Inserted D5 in
	 Inserted = {Text1 getText(p(1 0) 'end' $)} % example using coordinates to get text
	 %{Dictionary.get D1 {StringToAtom {GetLastWordOfPhrase {String.tokens Inserted 32}}} D5}
	 {DicoGetter D1 {StringToAtom {GetLastWordOfPhrase {String.tokens Inserted 32}}} D5}
	 if {IsDictionary D5} then
	    {Text2 set(1:{GetHighestFreq D5})} % you can get/set text this way too
	 else
	    {Text2 set(1:D5)}
	 end
      end

      fun {GetLastWordOfPhrase ListOfWord}
	 case ListOfWord of H|T then
	    if T == nil then {GetWithoutBackSlash H}
	    else
	       {GetLastWordOfPhrase T}
	    end
	 end
      end

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
      
      
      
      proc {Restart}
	 Inserted in
	 Inserted = {Text1 getText(p(1 0) 'end' $)} % example using coordinates to get text
	 {Text1 set(1:"")}
	 {Text2 set(1:"...")} % you can get/set text this way too
      end
   in
      X = 1
      %I = {CorrectInput {VirtualString.toString 'tweets/part_'#X#'.txt'}}
%%%% partie dico
      %{Dictionary.new Dico}
      %{DicoFromFile I Dico}
      %Entries = {Dictionary.entries Dico}
      %{Dictionary.get Dico 'and' Dico2}
      %BestWord = {GetHighestFreq Dico2}
      %{Browse BestWord}
      
      %{Browse {Dictionary.entries Dico2}}
      {Dictionary.new D1}
      %{Dictionary.new D2}
      {Dictionary.new D3}
      {Dictionary.new D4}
      
%%% Threads for reading %%%
      thread
	 L1 = {Prod 1 2}
	 % {Browser1 L1}
      end
      thread
	 L2 = {Prod 3 4}
      end
      thread
	 L3 = {Prod 5 6}
       end
      thread
	 L4 = {Prod 7 8}
      end

%%% Threads for parsing %%%
      {NewLock Lock}
      thread
	 % {Browser1 L1}
	 {DicoFromFiles L1 D1 Lock}
	 A = 1
	 {Browse 1}
	 %{Browse {Dictionary.entries D1}}
	 %{Dictionary.get Dico 'and' Dico2}
	 %{Browse {Dictionary.entries Dico2}}
      end
      thread
	 {DicoFromFiles L2 D1 Lock}
	 B = 1
	 {Browse 2}
      end
      thread
	 {DicoFromFiles L3 D1 Lock}
	 C = 1
	 {Browse 3}
      end
      thread
	 {DicoFromFiles L4 D1 Lock}
	 D = 1
	 {Browse 4}
      end
      {Wait A}
      {Wait B}
      {Wait C}
      {Wait D}
      {Browse {Dictionary.entries D1}}
      %{Dictionary.get D1 'Africa' D2}
      %{Browse {Dictionary.entries D2}}
      %{Browse {GetHighestFreq D2}}

      W={QTk.build Description}
      {W show}
   % {Text1 tk(insert 'end' {GetLine "tweets/part_1.txt" 1})}
      {Text1 tk(insert 'end' {GetLine "tweets/part_1.txt" 1})}
      {Text1 bind(event:"<Control-s>" action:Press)} % You can also bind events
   end   
end

