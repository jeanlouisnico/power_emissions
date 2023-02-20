function price2 = UK_price(datestart, dateend)

% datestart   = datetime(2015,1,1) ;
% dateend     = datetime(2015,12,31) ;
 
p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-2), filesep) ;
setup = jsondecode(fileread([fparts{1} filesep 'setup' filesep 'ini.json']));

securitytoken = setup.bmreports.securityToken ;

opts = weboptions("Timeout",60) ;

datesplit = [datestart:calmonths(1):dateend dateend];

for idate = 1:numel(datesplit)-1
    date1 = datestr(datesplit(idate),'yyyy-mm-dd') ;
    date2 = datestr(datesplit(idate + 1),'yyyy-mm-dd') ;
    data = webread(['https://api.bmreports.com/BMRS/DERSYSDATA/v1?APIKey=' securitytoken ...
                    '&FromSettlementDate=' date1 ...
                    '&ToSettlementDate=' date2  ...
                    '&SettlementPeriod=*&ServiceType=CSV'],opts);
   
    datearray = datetime(num2str(data.Var2(1:end-1)),'Format','uuuuMMdd')+ hours(data.Var3(1:end-1)) ;
    datearray = datetime(datearray,'Format','yyyy-MM-dd HH:mm') ;

    pricetemp = array2timetable(data.Var4(1:end-1),"RowTimes",datearray) ;
    if idate == 1
        priceout = pricetemp ;
    else
        priceout = [priceout; pricetemp] ;
    end
end

%% Clean the timetable by ordering the fields and remov the duplicates.


priceout.Properties.VariableNames = {'Var1'} ;
priceout.Properties.DimensionNames{1} = 'pricetime' ;
try
    price1.gb = priceout ;
catch
    x = 1 ;
end
natRowTimes = ismissing(price1.gb.pricetime) ;
goodRowTimesTT = price1.gb(~natRowTimes,:) ;
goodValuesTT = rmmissing(price1.gb) ;
tf = issorted(goodValuesTT) ;
sortedTT = sortrows(goodValuesTT) ;
tf = isregular(sortedTT) ;
uniqueRowsTT = unique(sortedTT) ;
dupTimes = sort(uniqueRowsTT.pricetime);
tf = (diff(dupTimes) == 0);
dupTimes = dupTimes(tf);
dupTimes = unique(dupTimes) ;
dupTimes = unique(dupTimes) ;
uniqueRowsTT(dupTimes,:) ;
uniqueTimes = unique(uniqueRowsTT.pricetime) ;
lastUniqueRowsTT = retime(uniqueRowsTT,uniqueTimes,'lastvalue') ;
meanTT = retime(uniqueRowsTT,uniqueTimes,'mean') ;

conver = [2022	1.18281	1.139147	1.213769
2021	1.163581	1.103327	1.191568
2020	1.12476	1.075442	1.205037
2019	1.139879	1.077238	1.198825
2018	1.130435	1.102779	1.159017
2017	1.141274	1.075674	1.19861
2016	1.223881	1.105156	1.365467
2015	1.3785	1.275185	1.436163] ;

findyear = (conver(:,1) == datestart.Year) ;

rate = conver(findyear,2) ;
price2.gb = meanTT ;
price2.gb.Variables = price2.gb.Variables / 10 / rate ; % Convert from £/Mwh to cts/kWh and convert £ to euros