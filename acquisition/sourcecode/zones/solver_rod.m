function newlimit = solver_rod(A, init, limit)
syms b c g o w p
% A = 2150 ;

bio     = b * A ;
coal    = c * A ;
gas     = g * A ;
oil     = o * A ;
waste   = w * A ;
other   = p * A ;

f1 = (bio + coal + oil + gas + waste + other - A == 0) ;

if limit.biomass == 0
    assume(bio == limit.biomass & b==0) ; 
else
    assume(((limit.biomass >= bio) & (bio > 0))) ; 
end

if limit.coal == 0
    assumeAlso(coal == limit.coal & c>=0) ; 
else
    assumeAlso(limit.coal >= coal & coal>0) ; 
end

if limit.gas == 0
    assumeAlso(gas == limit.gas & g>=0) ; 
else
    assumeAlso(limit.gas >= gas & gas>0) ; 
end

if limit.oil == 0
    assumeAlso(oil == limit.oil & o>=0) ; 
else
    assumeAlso(limit.oil >= oil & oil>0) ; 
end

if limit.waste == 0
    assumeAlso(waste == limit.waste & w==0)  ; 
else
    assumeAlso(waste<=limit.waste & waste>0)  ; 
end

if limit.other == 0
    assumeAlso(other == limit.other & p>=0)  ; 
else
    assumeAlso(other<=limit.other & other>0)  ; 
end

%{'biomass' 'coal' 'other' 'gas' 'oil' 'waste'} ;
distri = vpasolve(f1, [p,b,c,g,o,w], init) ; 
newlimit = array2table(struct2array(distri) * A, 'VariableNames',limit.Properties.VariableNames)  ;


