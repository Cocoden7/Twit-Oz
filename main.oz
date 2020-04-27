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
   
%%% Read line
   fun {GetFirstLine IN_NAME I}
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

%%% Changes each ponctuation used for marking the end of a phrase by a point (46) in a line. Returns the new line.
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
	    
         elseif H == 33 then
	    46|{MakePoint T}
	 elseif H == 33 andthen T.1 == 33 then
	    46|{MakePoint T}
	 elseif H == 33 andthen T.1 == 33 andthen T.2.1 == 33 then
	    46|{MakePoint T}
	 elseif H == 33 andthen T.1 == 33 andthen T.2.1 == 33 andthen T.2.2.1 == 33 then
	    46|{MakePoint T}
	    
	 elseif H == 63 then
	    46|{MakePoint T}
	 elseif H == 58 then
	    46|{MakePoint T}
	 elseif H == 59 then
	    46|{MakePoint T}
	 else
	    H|{MakePoint T}
	 end
      else
	 nil
      end
   end

 %%% Returns : List of all the lines with only points (no ',' ';' '?' '!' ...) 
   fun {MakePointFromFile File}
      case File of L1|L2 then
	 {MakePoint L1}|{MakePointFromFile L2}	 
      else
	 nil
      end
   end
   
%%% Split the phrase by Char
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
   

   %["salut iohef. duzgfzn eofn.foehiuh." "jizfioi. ziofhoifhnz. ofehiufh."] -> ["salut iohef" "duzgfzn eofn" "..."]
   fun {FileToPhrase File}
      case File of H|T then
	 {Append {GetWords H 46} {FileToPhrase T}}
      [] nil then
	 nil
      end
   end
   
	 

   fun {ToLower String}
      case String of H|T then
	 if {Char.isUpper H} then
	    {Char.toLower H}|{ToLower T}
	 else
	    H|{ToLower T}
	 end
      [] nil then
	 nil
      end
   end

   fun {Filter String} % c'est quoi le string qu'on reçoit ?
      case String of H|T then
	 if H == 40 then
	    {Filter T}
	 elseif H == 41 then
	    {Filter T}
	 else
	    H|{Filter T}
	 end
      else
	 nil
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
	    if {Contains Dico {StringToAtom H}} then % regarde si H est déjà une clé dans le gros dico
	       local ValueDico Freq in
		  {Dictionary.get Dico {StringToAtom H} ValueDico}
		  if {Contains ValueDico {StringToAtom T.1}} then % regarde si T est déjà associé à H
		     {Dictionary.get ValueDico {StringToAtom T.1} Freq}
		     {Dictionary.put ValueDico {StringToAtom T.1} Freq+1} % à vérifier que ça ne crée pas de nouvelle clé
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
	    %{Dictionary.put Dico {StringToAtom {ToLower {Filter H}}} {StringToAtom {ToLower {Filter T.1}}}}
	 end
      [] nil then
	 skip
      end
   end
   
   
%%% ListFile : List of phrases
%%% Returns : Dic(word1:word2 word2:word3 word3:word4 ...) with all the words 
   proc {DicoFromFile ListFile Dico}
      case ListFile of H|T then
	 %{CreateRec {FilterEmpty {GetWords H 32}} Dico} % ici que je dois mettre filterempty ?
	 {CreateRec {GetWords H 32} Dico}
	 {DicoFromFile T Dico}
      else
	 skip
      end
      
   end


   
   
%%% GUI
    % Make the window description, all the parameters are explained here:
    % http://mozart2.org/mozart-v1/doc-1.4.0/mozart-stdlib/wp/qtk/html/node7.html)
   Text1 Text2 Description=td(
			      title: "Frequency count"
			      lr(
				 text(handle:Text1 width:28 height:5 background:white foreground:black wrap:word)
				 button(text:"Change" action:Press)
				 )
			      text(handle:Text2 width:28 height:5 background:black foreground:white glue:w wrap:word)
			      action:proc{$}{Application.exit 0} end % quit app gracefully on window closing
			      )
   proc {Press} Inserted in
      Inserted = {Text1 getText(p(1 0) 'end' $)} % example using coordinates to get text
      {Text2 set(1:Inserted)} % you can get/set text this way too
   end
    % Build the layout from the description
   W={QTk.build Description}
   {W show}
   
   {Text1 tk(insert 'end' {GetFirstLine "tweets/part_1.txt" 1})}
   {Text1 bind(event:"<Control-s>" action:Press)} % You can also bind events

   
   proc {Consumer File}
      {Delay 5000}
      case File of H|T then	 
	 {Browse {StringToAtom H}} {Consumer T}
      else
	 skip
      end
   end
   
%%% Producer : Produce the content of FileName
   fun {Prod FileName} {Delay 1000} {ReadFile FileName 1} end
   
   local Dico Dico2 Phrases Tweet Point Points PointsFile I I2 X Count S in
      I = {CorrectInput 'tweets/part_1.txt'}
      I2 = {CorrectInput 'tweets/part_2.txt'}
      %{Browse {StringToAtom I.2.2.2.2.2.2.1}}
      
%%%% partie dico
      {Dictionary.new Dico}
      {DicoFromFile I Dico}
      Entries = {Dictionary.entries Dico}
      {Browse Entries}
      {Dictionary.get Dico 'and' Dico2}
      {Browse {Dictionary.entries Dico2}}

%%% Threads
      thread
	 S = {Prod 'tweets/part_1.txt'}
      end
      thread
	 {Consumer S}
      end
   end   
end

