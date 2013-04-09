% vim: syntax=prolog :

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%

citizen(x1).
citizen(x2).

default(d1(X), pos(p(X)), [pos(q(X))], []) :- citizen(X).
exception(d1(X), [pos(r(X))], []) :- citizen(X).

holds(pos(q(x1))).
holds(pos(q(x2))).
holds(pos(r(x2))).
		      
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

holds_by_default(L) :- rule(R, L, PositiveBody),
                       default(D, L1, PositiveBody, NegativeBody),
                       hold_by_default(D, []),
		       fail_by_default(D, []).

holds_by_default(pos(L)) :- default(D, pos(L), PositiveBody, NegativeBody), 
			    hold_by_default(D, []),
			    fail_by_default(D, []),
			    not defeated(D),
			    not holds_by_default(neg(L)).

holds_by_default(neg(L)) :- default(D, neg(L), PositiveBody, NegativeBody),
                            hold_by_default(D, []),
			    fail_by_default(D, []),
		            not defeated(D),
		            not holds_by_default(pos(L)).

hold_by_default(D, PositiveBody) :-  default(D, L, PositiveBody, NegativeBody).
				
hold_by_default(D, Tail) :- default(D, L, PositiveBody, NegativeBody),
                            hold_by_default(D, Tail2),
                            #head(Tail2, Head),
                            #tail(Tail2, Tail),
                            holds_by_default(Head).

fail_by_default(D, NegativeBody) :-  default(D, L, PositiveBody, NegativeBody).
				
fail_by_default(D, Tail) :- default(D, L, PositiveBody, NegativeBody),
                            fail_by_default(D, Tail2),
                            #head(Tail2, Head),
                            #tail(Tail2, Tail),
                            not holds_by_default(Head).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%deteating rules
defeated(D) :- detault(D, pos(L), PositiveBody, NegativeBody),
               holds(neg(L)).


defeated(D) :- detault(D, neg(L), PositiveBody, NegativeBody),
               holds(pos(L)).

defeated(D2) :- default(D1, L1, PositiveBody1, NegativeBody1),
                default(D2, L2, PositiveBody2, NegativeBody2),
	        holds(conflict(D1, D2)),
	        holds_by_default(prefer(D1, D2)),
	        hold_by_default(D1, []),
	        fail_by_default(D1, []),
	        not defeated(D1).

defeated(D) :- exception(D, PositiveBody, NegativeBody), %Here is a bug!!!
               hold_by_default(D, []), %This won't work for exceptions
	       fail_by_default(D, []).

holds(conflict(D1, D2)) :- default(D1, pos(L1), PositiveBody1, NegativeBody1), default(D2, neg(L1), PositiveBody2, NegativeBody2), D1 != D2.		      
%If heads of default are contrary, prefer(di, dj), prefer(dj, di) needs to be added to program rules

-holds(conflict(D, D)) :- default(D, L, PositiveBody, NegativeBody).

holds(conflict(D1, D2)) :- holds(conflict(D2, D1)).

-holds(prefer(D1, D2)) :- holds(prefer(D2, D1)), D1 != D2.			   

-holds_by_default(prefer(D1, D2)) :- holds_by_default(prefer(D2, D1)), D1 != D2.	



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Uniquenes
-rule(R, F1, PB1) :- rule(R, F1, PB1), default(R, F2, PB2, NB2).
-rule(R, F1, B1) :- rule(R, F1, B1), rule(R, F2, B2), F1 != F2, B1 != B2. 
-default(D, F1, PB1, NB1) :- default(D, F1, PB1, NB1), default(D, F2, PB2, NB2), F1 != F2, PB1 != PB2, NB1 != NB2.




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Auxilary
-holds(L) :- holds(neg(L)).
-holds_by_default(L) :- holds_by_default(neg(L)).


