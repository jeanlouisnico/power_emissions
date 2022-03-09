
function minval = CF_tech(countryin)

alphadigit = countrycode(countryin) ;
nrgyear         = loadEUnrgprod('country',{alphadigit}) ;
installedcap    = loadEUnrgcap('country',{alphadigit}) ;

predictedcap      = fuelmixEU_lpredict(installedcap.(alphadigit),'resolution','year') ;
predictednrgyear  = fuelmixEU_lpredict(nrgyear.(alphadigit),'resolution','year') ;

biogaslist = {'R5210P' 'R5220P' 'R5290' 'R5300'} ;
CF.W6100  = (predictednrgyear(end,'W6100').Variables*1000/predictedcap(end,'W6100').Variables)/8760 ; % waste industry
CF.W6200  = (sum(predictednrgyear(end,{'W6210' 'W6220'}).Variables)*1000/predictedcap(end,'W6200').Variables)/8760 ;  % waste municipal
CF.R5100  = (predictednrgyear(end,'R5100').Variables*1000/predictedcap(end,'R5100').Variables)/8760 ;  % biomass
CF.R5200  = (sum(predictednrgyear(end,biogaslist).Variables,'omitnan') *1000/sum(predictedcap(end,biogaslist).Variables,'omitnan'))/8760 ;  % other_biogas

CF.W6100 = fillmissing(CF.W6100,'constant',0) ;
CF.W6200 = fillmissing(CF.W6200,'constant',0) ;
CF.R5100 = fillmissing(CF.R5100,'constant',0) ;
CF.R5200 = fillmissing(CF.R5200,'constant',0) ;

minval.waste        = predictedcap(end,'W6200').Variables * CF.W6200 + predictedcap(end,'W6100').Variables*CF.W6100 ;
minval.biomass      = predictedcap(end,'R5100').Variables * CF.R5100 ;
minval.otherbiogas  = sum(predictedcap(end,biogaslist).Variables,'omitnan') * CF.R5200 ;
minval.solar        = predictedcap(end,{'RA410' 'RA420'}) ;
minval.hydro        = predictedcap(end,{'RA110' 'RA120' 'RA130'}) ;