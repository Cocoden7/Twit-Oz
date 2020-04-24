local Rec Carte X Y S in
   Rec = tree(caca:merde pipi:pisse zizi:bite)
   {Browse Rec}
   {Browse Rec.zizi}
   {AdjoinList Rec [arthur#arlithyr zz#zzz] S}
   {Browse S}
   Carte = carte(menu(entree: 'salade verte aux lardons'
		   plat: 'steak frites'
		   prix: 10)
	      menu(entree: 'salade de crevettes grises'
		   plat: 'saumon fume et pommes de terre'
		   prix: 12)
	      menu(plat: 'choucroute garnie'
		   prix: 9))
   {Browse Carte.2}
   {Browse Carte.2.plat}
   {Browse Carte.1.entree}
   {Arity Carte X}
   {Arity Carte.1 Y}
   {Browse X}
   {Browse Y}
end