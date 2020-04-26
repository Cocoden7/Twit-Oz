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
   fun {GetFirstLine IN_NAME}
      {Reader.scan {New Reader.textfile init(name:IN_NAME)} 1}
   end

%%% Stock each lines of the file in a list and returns it
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

 %%% Returns : List of all the lines with only points  
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

   fun {FilterEmpty GetWords}
      case GetWords of H|T then
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
   % Returns : a list of phrases from the file splitted phrase by phrase
   fun {CorrectInput File}
      {FileToPhrase {MakePointFromFile {ReadFile File 1}}}
   end

%%%%%%%%%%%%%%%%%%%% Dictionary part %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% WordsList : a list of words.
%%% Returns : Dic(word1:word2 word2:word3 word3:word4 ...)
   proc {CreateRec WordsList Dico}
      case WordsList of H|T then
	 case T of nil then
	    skip
	 else
	    %{Dictionary.put Dico {ToLower {StringToAtom H}} {ToLower {StringToAtom T.1}}}  fonctionne pas car on peut pas faire to lower sur un atom
	    %{Browse {IsString {StringToAtom H}}} un atom n'est pas un string 
	    {Dictionary.put Dico {StringToAtom {ToLower {Filter H}}} {StringToAtom {ToLower {Filter T.1}}}}
	    {CreateRec T Dico}
	 end
      [] nil then
	 skip
      end
   end
%%% ListFile : List of lines
%%% Returns : Dic(word1:word2 word2:word3 word3:word4 ...) with all the words 
   proc {DicoFromFile ListFile Dico}
      case ListFile of H|T then
	 {CreateRec {FilterEmpty {GetWords H 32}} Dico} % ici que je dois mettre filterempty ?
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
   
   {Text1 tk(insert 'end' {GetFirstLine "tweets/part_1.txt"})}
   {Text1 bind(event:"<Control-s>" action:Press)} % You can also bind events



   
   local Dico Phrases Tweet Point Points PointsFile I X in
      Point = 46
      Tweet = {ReadFile 'tweets/part_1.txt' 1}
      Points =  {MakePoint "Salut. Je m'appelle Arthur! Comment tu vas ? PD."}
      PointsFile = {MakePointFromFile Tweet}
      Phrases = {FileToPhrase PointsFile}
      %{Browse Phrases}
      I = {CorrectInput 'tweets/part_1.txt'} % départ pour créer notre dictionnaire
      %{Browse {StringToAtom I.2.2.1}}
      
%%%% partie dico
      {Dictionary.new Dico}
      {DicoFromFile I Dico}
      Entries = {Dictionary.entries Dico}
      {Browse Entries}
      X = {Dictionary.get Dico '@oann'} == '' % vient du fait que ce couillon met deux espaces de temps en temps
      {Browse X}
   end   
end

