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

   %%% Split the line by Char
   fun {GetWords Line Char}
      {String.tokens Line Char}
   end

   %["salut iohef. duzgfzn eofn.foehiuh." "jizfioi. ziofhoifhnz. ofehiufh."] -> [["salut iohef" "duzgfzn eofn" "..."] [...]]
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

   fun {CorrectInput File}
      {FileToPhrase {MakePointFromFile {ReadFile File 1}}}
   end

%%%%%%%%%%%%%%%%%%%% parite dictionnaire %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   proc {CreateRec WordsList Dico} % faut pouvoir mettre les lsites en string
      case WordsList of H|T then
	 case T of nil then
	    skip
	 else
	    {Dictionary.put Dico {StringToAtom H} {StringToAtom T.1}}
	    {CreateRec T Dico}
	 end
      [] nil then
	 skip
      end
   end

   proc {DicoFromFile ListFile Dico}
      case ListFile of H|T then
	 {CreateRec {GetWords H 32} Dico}
	 {DicoFromFile T Dico}
      else
	 skip
      end
      
   end
   

   %proc {CreateRec PhraseList Dico} 
    %  case PhraseList of H|T then
%	 case H of H2|T2 then
%	    skip
%	 [] nil then
%	    skip
%	 end
 %     end
  % end

   %local Words in
    %  Words = {GetWords Phrase 32}
   proc {PutInDicoFromPhrase Words Dico}
      case Words of Word|T then
	 {Dictionary.put Dico {StringToAtom Word} {StringToAtom T.1}}
	 {PutInDicoFromPhrase T Dico}
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

   local Dico X Dico1 Phrases Tweet Point Points PointsFile I in
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
      %{CreateRec I Dico}
      %{Dictionary.get Dico 'must' X}
      %{Browse X}
      {DicoFromFile I Dico}
      {Browse Dico}
      {Browse {Dictionary.get Dico 'must'}}
   end   
end

