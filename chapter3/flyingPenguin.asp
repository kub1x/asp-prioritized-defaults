% vim: syntax=prolog :

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Flying penguin problem

bird.
holds(pos(bird)).

swims.
holds(pos(swims)).

default(d1,  neg(flies),   [pos(penguin)]).
default(d2,  pos(flies),   [pos(bird)]).
default(d3,  pos(penguin), [pos(bird), pos(swims)]).

prefer(d1, d2).								   
holds_by_default(prefer(d1, d2)).

prefer(d2, d3).								   
holds_by_default(prefer(d2, d3)).
holds(conflict(d2, d3)).

prefer(d1, d3).								   
holds_by_default(prefer(d1, d3)).


		      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Non-defeseable interence
holds(L) :- rule(R, L, Body),
            hold(R, []).

hold(R, Body) :- rule(R, L, Body).

hold(R, Tail) :- rule(R, L, Body),
                 hold(R, Tail2),
                 #head(Tail2, Head),
                 #tail(Tail2, Tail),
                 holds(Head).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%defesiable inference	       
holds_by_default(L) :- holds(L).

holds_by_default(L) :- rule(R, L, Body),
                       default(D, L1, Body),
                       hold_by_default(D, []). 

holds_by_default(pos(L)) :- default(D, pos(L), Body), 
                       hold_by_default(D, []),
		       not defeated(D),
		       not holds_by_default(neg(L)).

holds_by_default(neg(L)) :- default(D, neg(L), Body),
                            hold_by_default(D, []),
		            not defeated(D),
		            not holds_by_default(pos(L)).

hold_by_default(D, Body) :-  default(D, L, Body).
				
hold_by_default(D, Tail) :- default(D, L, Body),
                            hold_by_default(D, Tail2),
                            #head(Tail2, Head),
                            #tail(Tail2, Tail),
                            holds_by_default(Head).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%deteating rules
defeated(D) :- detault(D, pos(L), Body),
               holds(neg(L)).


defeated(D) :- detault(D, neg(L), Body),
               holds(pos(L)).

defeated(D2) :- default(D1, L1, Body1),
                default(D2, L2, Body2),
	        holds(conflict(D1, D2)),
	        holds_by_default(prefer(D1, D2)),
	        hold_by_default(D1, []),
	        not defeated(D1).


holds(conflict(D1, D2)) :- default(D1, pos(L1), Body1), default(D2, neg(L1), Body2), D1 != D2.		      
%If heads of default are contrary, prefer(di, dj), prefer(dj, di) needs to be added to program rules

-holds(conflict(D, D)) :- default(D, L, Body).

holds(conflict(D1, D2)) :- holds(conflict(D2, D1)).

-holds(prefer(D1, D2)) :- holds(prefer(D2, D1)), D1 != D2.			   

-holds_by_default(prefer(D1, D2)) :- holds_by_default(prefer(D2, D1)), D1 != D2.	



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Uniquenes
-rule(R, F1, B1) :- rule(R, F1, B1), default(R, F2, B2).
-rule(R, F1, B1) :- rule(R, F1, B1), rule(R, F2, B2), F1 != F2, B1 != B2. 
-default(D, F1, B1) :- default(D, F1, B1), default(D, F2, B2), F1 != F2, B1 != B2.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Auxilary
-holds(L) :- holds(neg(L)).
-holds_by_default(L) :- holds_by_default(neg(L)).

