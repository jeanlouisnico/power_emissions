function newlimit = solver_rod(A, init, limit)
syms b c g o w p
% A = 2150 ;

bio     = b * A ;
coal    = c * A ;
gas     = g * A ;
oil     = o * A ;
waste   = w * A ;
other   = p * A ;

f = (bio + coal + oil + gas + waste + other - A == 0) ;

assume(bio >= 0) ; 
assumeAlso(bio<=limit.biomass) ; 
assumeAlso(b>=0) ; 
assumeAlso(b<=1) ;
assumeAlso(coal == limit.coal) ; 
assumeAlso(c>=0)  ;
assumeAlso(gas >= 0) ; 
assumeAlso(gas<=limit.gas) ; 
assumeAlso(g>=0) ;
assumeAlso(g<=1) ;
assumeAlso(oil >= 0) ; 
assumeAlso(oil<=limit.oil) ; 
assumeAlso(o>=0) ;
assumeAlso(waste >= 0) ; 
assumeAlso(waste<=limit.waste) ; 
assumeAlso(w>=0) ;
assumeAlso(other >= 0) ; 
assumeAlso(other<=limit.other) ; 
assumeAlso(p>=0) ;

distri = vpasolve(f, [g,c,o,p,w,b], init) ; 
newlimit = array2table(struct2array(distri) * A, 'VariableNames',limit.Properties.VariableNames)  ;
