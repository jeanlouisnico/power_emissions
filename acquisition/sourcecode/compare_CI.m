function compare_CI

url = 'http://128.214.253.150/api/v1/resources/emissions/latest?EmDB=IPCC' ;
p = webread(url) ;
datain = jsondecode(p) ;

emissions.country = {datain.results(:).country}' ;
emissions.cons = [datain.results(:).em_cons]' ;
emissions.prod = [datain.results(:).em_prod]' ;

emissionsv2 = struct2table(emissions) ;

X = categorical(emissionsv2.country);

compareJRC = readtable('CI_JRC.csv') ; 
JRC_coutrny = countrycode(compareJRC.country);

for icountry = 1:length(X)
    switch char(X(icountry))
        case 'GR'
            code = 'EL' ;
        otherwise
            code = char(X(icountry)) ;
    end
    locatecountry = ismember(JRC_coutrny.alpha2, code) ;
    JRC(icountry,1) = compareJRC.cons(locatecountry) ;
    JRC_prod(icountry,1) = compareJRC.prod_net(locatecountry) ;
end
emissionsv2 = addvars(emissionsv2,JRC) ;
emissionsv2 = addvars(emissionsv2,JRC_prod) ;
bar(X, [emissionsv2.cons emissionsv2.JRC emissionsv2.prod  emissionsv2.JRC_prod]) ;
legend({'CI-cons EK' 'JRC-cons' 'CI-prod EK' 'JRC-prod'}) ;