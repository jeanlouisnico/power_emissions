function fig = clockplot1time_donut()

% Best in fullscreen mode
% VERSION 1.1
% Features:
% 1. ANALOG + DIGITAL displays
% 2. Black dot in the centre indicates 'P.M' and White dot in the centre indicates 'A.M'
% 3. Indicates the year month date and the week numbers also.
% 4. The digital display of the time is shown on the corresponding hand
% 5. Duration of one tick of the second hand can be set
% 6. uses opengl rendering and the hands run more smoothly than in version 1.0
% 7. Display a complete digital display in the form H:M:S:mS... & H --> 0 to 24
% NOTE: CLOCK STARTS AND IS MAITAINED ACCORDING 
% TO TIME INDICATED BY THE INBUILT COMMAND "clock"
% By Sunil Anandatheertha
% !x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!
% !x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!
% IMPORTANT NOTE: USE CTRL+C IN COMMAND LINE or FIGURE WINDOW TO END THE PROGRAM
% !x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!
% !x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!x!
% \.//////////////\.//////////////\.//////////////
% \.//////////////\.//////////////\.//////////////
rs=10; % radius of second hand
n = 1;  hs=[];  hm=[];  hh=[];  digsec=[];  digmin=[];  dighr=[];  
digdate1=[]; digdate2=[]; digdate3=[]; digdate4=[]; digdate5=[]; ampm=[];digtime1=[];
fig=setfigureproperties;
setaxisproperties;
onetick=0.0025;% (set the duration of one tick. NOTE: an approx.)

    time = clock;
    % \.//////////////\.//////////////\.//////////////
    % analog display
    thsec = 90+(time(6)*6);
    thmin = 90+(time(5)*6) + (time(6)/10);
    thhour = 90+(time(4)*30) + (time(5)/2); %thsec-thetasec
    delete(hh);     hh  = plot([0 -0.75*rs*cosd(thhour)],[0 0.75*rs*sind(thhour)],'b','LineWidth',1.75);%hh - figure handle for hour hand
    delete(hm);    hm = plot([0 -0.9*rs*cosd(thmin)],[0 0.9*rs*sind(thmin)],'k','LineWidth',1.5);
    delete(hs);     hs  = plot([0 -rs*cosd(thsec)],[0 rs*sind(thsec)],'Color',[1 0 0],'LineWidth',1);
    % \.//////////////\.//////////////\.//////////////
    % digital display
%     delete(digsec);      digsec = text(-7.5*cosd(5+thsec),7.5*sind(5+thsec),...
%         num2str(time(6)),'FontSize',10);%digsec-digital sec
%     delete(digmin);     digmin = text(-6*cosd(4+thmin),6*sind(4+thmin),...
%         num2str(floor(time(5))+time(6)/60),'FontSize',10);
%     delete(dighr);        dighr = text(-2.5*cosd(1+thhour),2.5*sind(1+thhour),...
%         num2str(floor(time(4))+time(5)/60),'FontSize',10);
    % \.//////////////\.//////////////\.//////////////
    [month] = findmonth(time(2));
    [week]=findweek(time(3));
    [~,day]=weekday(datenum(time(1),time(2),time(3)),'long');
    % \.//////////////\.//////////////\.//////////////
%     delete(digdate1); digdate1 = text(13*cosd(112.5),13*sind(112.5),strcat(num2str(time(1))),...
%         'FontSize',12,'VerticalAlignment','middle','HorizontalAlignment','right');
%     delete(digdate2); digdate2 = text(13*cosd(67.5),  13*sind(67.5),month,...
%         'FontSize',14,'VerticalAlignment','middle','HorizontalAlignment','left');
%     delete(digdate3); digdate3 = text(13*cosd(337.5),13*sind(337.5),strcat(num2str(floor(time(3))),'^{th}'),...
%         'FontSize',14,'VerticalAlignment','middle','HorizontalAlignment','left');
%     delete(digdate4); digdate4 = text(13*cosd(292.5),13*sind(292.5),day,...
%         'FontSize',14,'VerticalAlignment','middle','HorizontalAlignment','left');
%     delete(digdate5); digdate5 = text(13*cosd(22.5),  13*sind(22.5),strcat('Wk.-',num2str(week)),...
%         'FontSize',12,'VerticalAlignment','middle','HorizontalAlignment','left');
    % \.//////////////\.//////////////\.//////////////
    % \.//////////////\.//////////////\.//////////////
    % determine am or pm
    time = clock;     
    x = time(4)+time(6)/3600;
    if x>0&&x<12 
        coloris='w';AM='A.M'; 
    else
        coloris='k';AM='P.M';
    end % Black (k) is for P.M and White (w) is for A.
    delete(ampm);
    ampm = fill(.5*cosd(0:20:360),.5*sind(0:20:360),coloris);
    % \.//////////////\.//////////////\.//////////////
%     delete(digtime1);     
%     digtime1 = text(-2.75,4,strcat(num2str(time(4)),':',...
%                 num2str(time(5)),':',num2str(floor(time(6))),':',...
%                 num2str((1E3*(time(6)-floor(time(6)))))),...
%                 'FontSize',16,'color',[1 .3 0],...
%                 'VerticalAlignment','middle',...
%                 'HorizontalAlignment','left');    
    % \.//////////////\.//////////////\.//////////////
    axis equal
%     set(gcf, 'color', 'none');
    set(gca, 'color', [0 0 0]);
    drawnow


% format short g;
% format compact;
% fontSize = 20;
% 
% % Get the screen size in pixels.
% screenSize = get(0,'ScreenSize') ;
% 
% % Ask user for the radii and number of colors.
% defaultOuterDiameter = round(1 * screenSize(4));
% defaultInnerDiameter = round(0.7 * defaultOuterDiameter);
% % Define the default values.
% defaultValues = {num2str(defaultOuterDiameter), num2str(defaultInnerDiameter), '240', '255'};
% 
% outerRadius = str2double(defaultValues{1}) / 2;		% outer radius of the colour ring
% innerRadius = str2double(defaultValues{2}) / 2;		% inner radius of the colour ring
% numberOfSectors = str2double(defaultValues{3});		% number of colour segments
% grayLevel = str2double(defaultValues{4});		% Gray level outside the wheel.
% 
% [x, y] = meshgrid(-outerRadius : outerRadius);
% [theta, rho] = cart2pol(x, y); % theta is an image here.

% Get the emissions

currentdate = datetime(now, "ConvertFrom", "datenum") ;
currentdatestart = datetime(now, "ConvertFrom", "datenum") - hours(11) ;

datemovingaverage = datetime(now, "ConvertFrom", "datenum") - days(5) ;

datestart = timeURL(currentdatestart,{'-'}) ;
dateend   = timeURL(currentdate,{'-'}) ;

url = ['http://128.214.253.150/api/v1/resources/emissions/findByDate?startdate=' datestart '&enddate=' dateend '&EmDB=EcoInvent&country=FI'] ;
p = webread(url) ;
datain = jsondecode(p) ;
% timearray = cellfun(@(x) datetime(x), {datain.results(:).date_time}) ;
emissions = [datain.results(:).em_cons]' ;

idx = cellfun('isempty',{datain.results(:).em_cons});
timearray = cellfun(@(x) datetime(x), {datain.results(~idx).date_time}) ;

emissionT = timetable(timearray',emissions) ;
emissionT = sortrows(emissionT) ;

datestart   = timeURL(datemovingaverage,{'-'}) ;
url = ['http://128.214.253.150/api/v1/resources/emissions/findByDate?startdate=' datestart '&enddate=' dateend '&EmDB=EcoInvent&country=FI'] ;
p = webread(url) ;
datain = jsondecode(p) ;

idx = cellfun('isempty',{datain.results(:).em_cons});
timearray = cellfun(@(x) datetime(x), {datain.results(~idx).date_time}) ;

movingaverage = [datain.results(:).em_cons] ;
longemissions = timetable(timearray',movingaverage') ;
longemissions = sortrows(longemissions) ;

movingmean = cummean(longemissions.Var1,1) ;
movingmeanT = timetable(timearray',movingmean) ;

emiT = synchronize(emissionT,movingmeanT,'Intersection') ;
%% Import the elspot price
% the elspot price include the 24 % taxes
elsepost_array = elspotENTSOE ;
elsepost_array.pricetime = elsepost_array.pricetime + hours(1) ;
% Find the nearest time to the current time ;
if currentdate.Minute >= 30
    [~, nearestIdx] = min(abs(elsepost_array.pricetime - currentdate)) ;
    nearestIdx = nearestIdx - 1; 
else
    [~, nearestIdx] = min(abs(elsepost_array.pricetime - currentdate)) ;
end
extracttime = timerange(elsepost_array.pricetime(nearestIdx),elsepost_array.pricetime(nearestIdx + 11)) ;
spot12 = elsepost_array(extracttime,:) ;

%% Set up the clock for the emissions

% Find out which section is above the 5% and above of the moving average,
% which is between 0 and  5% and everything that is below the moving
% average

emiT.cat(emiT.emissions > 1.05 * emiT.movingmean)                                       = .1 ;
emiT.cat(emiT.emissions >= emiT.movingmean & emiT.emissions <= 1.05*emiT.movingmean)    = .5 ;
emiT.cat(emiT.emissions < emiT.movingmean)                                              = 1 ;

timeAM = zeros(height(emiT),1);
emiT = addvars(emiT,timeAM) ;
emiT.timeAM(emiT.Time.Hour - 12 < 0) = emiT.Time.Hour(emiT.Time.Hour - 12 < 0) + emiT.Time.Minute(emiT.Time.Hour - 12 < 0) / 60;
emiT.timeAM(emiT.Time.Hour - 12 >= 0) = emiT.Time.Hour(emiT.Time.Hour - 12 >= 0) - 12 + emiT.Time.Minute(emiT.Time.Hour - 12 >= 0) / 60 ;

ref_zero = 0 ; % Time of the 0 value where the plot starts to be done

timerangecheck = datetime(currentdate.Year,currentdate.Month,currentdate.Day,ref_zero,0,0):minutes(3):datetime(currentdate.Year,currentdate.Month,currentdate.Day,ref_zero+12,0,0) ;
timerangecheck = timerangecheck';
timerangechecknum(timerangecheck.Hour - 12 < 0) = timerangecheck.Hour(timerangecheck.Hour - 12 < 0) + timerangecheck.Minute(timerangecheck.Hour - 12 < 0) / 60;
timerangechecknum(timerangecheck.Hour - 12 >= 0) = timerangecheck.Hour(timerangecheck.Hour - 12 >= 0) - 12 + timerangecheck.Minute(timerangecheck.Hour - 12 >= 0) / 60 ;
timerangechecknum = timerangechecknum';

emiT.timeplot = zeros(height(emiT),1) ;
emiT.timeplot(emiT.timeAM-ref_zero<0) = emiT.timeAM(emiT.timeAM-ref_zero<0) + 12 ;
emiT.timeplot(emiT.timeAM-ref_zero>0) = emiT.timeAM(emiT.timeAM-ref_zero>0)  ;
emiT.timeplot(emiT.timeAM-ref_zero>=0) = emiT.timeAM(emiT.timeAM-ref_zero>=0)  ;

emiT.timeplotorder = zeros(height(emiT),1) ;
emiT.timeplotorder = 20*(12 - floor(emiT.timeplot)) - floor(emiT.Time.Minute /3); % old version with image 20*(floor(emiT.timeplot)-ref_zero)+1 + floor(emiT.Time.Minute /3) ;

% dataincirc(emiT.timeplotorder) = emiT.cat ;

clocksplit = ones(1,20*12) / (20*12) ;

colorin = cell(20*12,1) ;
colorin = cellfun(@(x) [1 1 1], colorin, 'UniformOutput', false) ;

red = [233 175 175] / 255;
orange = [233 175 91] / 255;
green = [111 175 103] / 255;
white = [1 1 1] ;

for iclock = 1:length(emiT.cat)
    switch emiT.cat(iclock)
        case 0
            colorin{emiT.timeplotorder(iclock)} = white;
        case 1
            colorin{emiT.timeplotorder(iclock)} = green;
        case .5
            colorin{emiT.timeplotorder(iclock)} = orange;
        case .1
            colorin{emiT.timeplotorder(iclock)} = red;
        otherwise
            colorin{emiT.timeplotorder(iclock)} = white;
    end
    
end

donut(clocksplit,'color',colorin, 'axis', fig, 'width', 10);

%% Set up the clock for the elspot price
highLimit = 10 ; % 10 euro cents per kWh

spot12.cat(spot12.Var1 > highLimit)             = .1 ;
spot12.cat(spot12.Var1 > highLimit * .95 & spot12.Var1 <= highLimit)       = .5 ;
spot12.cat(spot12.Var1 <= highLimit * .95)   = 1 ;

timeAM = zeros(height(spot12),1);
spot12 = addvars(spot12,timeAM) ;
spot12.timeAM(spot12.pricetime.Hour - 12 < 0) = spot12.pricetime.Hour(spot12.pricetime.Hour - 12 < 0) + spot12.pricetime.Minute(spot12.pricetime.Hour - 12 < 0) / 60;
spot12.timeAM(spot12.pricetime.Hour - 12 >= 0) = spot12.pricetime.Hour(spot12.pricetime.Hour - 12 >= 0) - 12 + spot12.pricetime.Minute(spot12.pricetime.Hour - 12 >= 0) / 60 ;

ref_zero = 0 ; % Time of the 0 value where the plot starts to be done

timerangecheck = datetime(currentdate.Year,currentdate.Month,currentdate.Day,ref_zero,0,0):hours(1):datetime(currentdate.Year,currentdate.Month,currentdate.Day,ref_zero+12,0,0) ;
timerangecheck = timerangecheck';
timerangechecknum(timerangecheck.Hour - 12 < 0) = timerangecheck.Hour(timerangecheck.Hour - 12 < 0) + timerangecheck.Minute(timerangecheck.Hour - 12 < 0) / 60;
timerangechecknum(timerangecheck.Hour - 12 >= 0) = timerangecheck.Hour(timerangecheck.Hour - 12 >= 0) - 12 + timerangecheck.Minute(timerangecheck.Hour - 12 >= 0) / 60 ;
timerangechecknum = timerangechecknum';

spot12.timeplot = zeros(height(spot12),1) ;
spot12.timeplot(spot12.timeAM-ref_zero<0) = spot12.timeAM(spot12.timeAM-ref_zero<0) + 12 ;
spot12.timeplot(spot12.timeAM-ref_zero>0) = spot12.timeAM(spot12.timeAM-ref_zero>0)  ;
spot12.timeplot(spot12.timeAM-ref_zero>=0) = spot12.timeAM(spot12.timeAM-ref_zero>=0)  ;

spot12.timeplotorder = zeros(height(spot12),1) ;
spot12.timeplotorder = (12 - floor(spot12.timeplot)) - floor(spot12.pricetime.Minute /3) ;

clocksplit = ones(1,1*12) / (1*12) ;

colorin = cell(1*12,1) ;
colorin = cellfun(@(x) [1 1 1], colorin, 'UniformOutput', false) ;

red = [233 175 175] / 255;
orange = [233 175 91] / 255;
green = [111 175 103] / 255;
white = [1 1 1] ;

r = randi([0 3],1,1*12);

for iclock = 1:length(spot12.cat)
    switch spot12.cat(iclock)
        case 0
            colorin{spot12.timeplotorder(iclock)} = white;
        case 1
            colorin{spot12.timeplotorder(iclock)} = green;
        case .5
            colorin{spot12.timeplotorder(iclock)} = orange;
        case .1
            colorin{spot12.timeplotorder(iclock)} = red;
        otherwise
            colorin{spot12.timeplotorder(iclock)} = white;
    end
    
end

donut(clocksplit,'color',colorin, 'axis', fig, 'width', 13);

%% Finalise plotting

axes('pos',[0.015 0.015 1 1])

% Add the legend
delete(digdate1); digdate1 = text(.35,.9,strcat('Elspot'),...
                             'FontSize',12,'VerticalAlignment','middle','HorizontalAlignment','right');

delete(digdate2); digdate2 = text(.55,.32,strcat('Emissions'),...
                                  'FontSize',10,'VerticalAlignment','middle','HorizontalAlignment','right');

chi=get(gcf, 'Children') ;
set(gcf, 'Children',flipud(chi)) ;
fig.Children(1).Children(end-2).Visible = 'off' ;
fig.Visible = 'on';
set(gca, 'color', 'none');
axis off ;
fig2plotly(fig, 'offline', true, 'filename','test', 'open', false) ;
% exportgraphics(fig,'plot.pdf','BackgroundColor','none')
% ax = ancestor(fig.Children, 'axes');
% title(ax, 'title for magic image')
delete(fig) ;
end



% \.//////////////\.//////////////\.//////////////
% \.//////////////\.//////////////\.//////////////
function fig=setfigureproperties

% clear,close,clc
% set(0,'DefaultFigureWindowStyle','docked')
ssize = get(0,'ScreenSize');
fig=figure('units','pixels',...
    'menubar','none',...
    'name','clockplot',...
    'Position', [0 0 .5*ssize(3) .5*ssize(4)],...
    'numbertitle','off',...
    'renderer','opengl',...
    'visible','off',...
    'color',[.5 .5 .5]);
axis off,hold on
drawcircle(1,12)
for n=1:12
    text(-8.5*cosd(90+(n)*360/12),8.5*sind(90+(n)*360/12),num2str(n))
    plot([0.95*10*cosd(90+(n)*360/12) 1.1*10*cosd(90+(n)*360/12)],...
        [0.95*10*sind(90+(n)*360/12) 1.1*10*sind(90+(n)*360/12)],...
        'k','LineWidth',2)
    for ns=1:5
        plot([1.0*10*cosd(90+(n)*360/12+6*ns) 1.1*10*cosd(90+(n)*360/12+6*ns)],...
            [1.0*10*sind(90+(n)*360/12+6*ns) 1.1*10*sind(90+(n)*360/12+6*ns)],...
            'k','LineWidth',1)
    end
end
% plot(0.95*10*cosd(3:6:363),0.95*10*sind(3:6:363),'k.','MarkerSize',1)
ar=3:6:363; cosar=cosd(ar); sinar=sind(ar);
x1=0.95*10*cosar; x2=0.98*10*cosar; y1=0.95*10*sinar; y2=0.97*10*sinar;
for n=1:numel(x1)
    plot([x1(n) x2(n)],[y1(n) y2(n)],'k')
end
end
% \.//////////////\.//////////////\.//////////////
% \.//////////////\.//////////////\.//////////////
function setaxisproperties
% Set the axis properties (value of the variable ax is greater than (rs+somesmallvalue))
axis([-14 20 -14 14]);
end
% \.//////////////\.//////////////\.//////////////
% \.//////////////\.//////////////\.//////////////
function drawcircle(varargin)

th=0:12:360;
for n=1:nargin
    if varargin{n}==max(varargin{:});plot(varargin{n}*cosd(th),varargin{n}*sind(th),'LineWidth',6)
    elseif varargin{n}==min(varargin{:});fill(varargin{n}*cosd(th),varargin{n}*sind(th),'b')
    else plot(varargin{n}*cosd(th),varargin{n}*sind(th),'k')
    end
end
incr=45; plot(1.1*max(varargin{:})*cosd(0:incr:360),1.1*max(varargin{:})*sind(0:incr:360),'LineWidth',6)
end
% \.//////////////\.//////////////\.//////////////
% \.//////////////\.//////////////\.//////////////
function [month]=findmonth(number)
switch number
    case 1;m='Jan';case 2;m='Feb';case 3;m='March';case 4;m='Apr';case 5;m='May';case 6;m='June';
    case 7;m='July';case 8;m='Aug';case 9;m='Sept';case 10;m='Oct';case 11;m='Nov';case 12;m='Dec';
end;month = m;
end
% \.//////////////\.//////////////\.//////////////
% \.//////////////\.//////////////\.//////////////
function [week]=findweek(number)
if number>1 && number<=7
    week=1; 
elseif number>=8 && number<=14
    week=2;
elseif number>=15 && number<=21
    week=3; 
elseif number>-22 && number<=31
    week=4;
end
end