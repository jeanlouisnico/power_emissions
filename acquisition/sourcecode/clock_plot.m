
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
imtool close all;  % Close all imtool figures if you have the Image Processing Toolbox.
clear;  % Erase all existing variables. Or clearvars if you want.
workspace;  % Make sure the workspace panel is showing.
format short g;
format compact;
fontSize = 20;

% Get the screen size in pixels.
screenSize = get(0,'ScreenSize') ;

% Ask user for the radii and number of colors.
defaultOuterDiameter = round(0.76 * screenSize(4));
defaultInnerDiameter = round(0.70 * defaultOuterDiameter);
% Define the default values.
defaultValues = {num2str(defaultOuterDiameter), num2str(defaultInnerDiameter), '240', '255'};

outerRadius = str2double(defaultValues{1}) / 2;		% outer radius of the colour ring
innerRadius = str2double(defaultValues{2}) / 2;		% inner radius of the colour ring
numberOfSectors = str2double(defaultValues{3});		% number of colour segments
grayLevel = str2double(defaultValues{4});		% Gray level outside the wheel.

[x, y] = meshgrid(-outerRadius : outerRadius);
[theta, rho] = cart2pol(x, y); % theta is an image here.

currentdate = datetime(now, "ConvertFrom", "datenum") ;
currentdatestart = datetime(now, "ConvertFrom", "datenum") - hours(11) ;

datemovingaverage = datetime(now, "ConvertFrom", "datenum") - days(7) ;

datestart = timeURL(currentdatestart,{'-'}) ;
dateend   = timeURL(currentdate,{'-'}) ;

url = ['http://128.214.253.150/api/v1/resources/emissions/findByDate?startdate=' datestart '&enddate=' dateend '&EmDB=EcoInvent&country=FI'] ;
p = webread(url) ;
datain = jsondecode(p) ;
timearray = cellfun(@(x) datetime(x), {datain.results(:).date_time}) ;
emissions = [datain.results(:).em_cons]' ;

emissionT = timetable(timearray',emissions) ;
emissionT = sortrows(emissionT) ;

datestart   = timeURL(datemovingaverage,{'-'}) ;
url = ['http://128.214.253.150/api/v1/resources/emissions/findByDate?startdate=' datestart '&enddate=' dateend '&EmDB=EcoInvent&country=FI'] ;
p = webread(url) ;
datain = jsondecode(p) ;
timearray = cellfun(@(x) datetime(x), {datain.results(:).date_time}) ;
movingaverage = [datain.results(:).em_cons] ;
longemissions = timetable(timearray',movingaverage') ;
longemissions = sortrows(longemissions) ;

movingmean = cummean(longemissions.Var1,1) ;
movingmeanT = timetable(timearray',movingmean) ;

emiT = synchronize(emissionT,movingmeanT,'Intersection') ;

% Find out which section is above the 5% and above of the moving average,
% which is between 0 and  5% and everything that is below the moving
% average

emiT.cat(emiT.emissions > 1.05 * emiT.movingmean) = .1 ;
emiT.cat(emiT.emissions >= emiT.movingmean & emiT.emissions <= 1.05*emiT.movingmean) = .5 ;
emiT.cat(emiT.emissions < emiT.movingmean) = 1 ;

timeAM = zeros(height(emiT),1);
emiT = addvars(emiT,timeAM) ;
emiT.timeAM(emiT.Time.Hour - 12 < 0) = emiT.Time.Hour(emiT.Time.Hour - 12 < 0) + emiT.Time.Minute(emiT.Time.Hour - 12 < 0) / 60;
emiT.timeAM(emiT.Time.Hour - 12 >= 0) = emiT.Time.Hour(emiT.Time.Hour - 12 >= 0) - 12 + emiT.Time.Minute(emiT.Time.Hour - 12 >= 0) / 60 ;

timerangecheck = datetime(currentdate.Year,currentdate.Month,currentdate.Day,9,0,0):minutes(3):datetime(currentdate.Year,currentdate.Month,currentdate.Day,21,0,0) ;
timerangecheck = timerangecheck';
timerangechecknum(timerangecheck.Hour - 12 < 0) = timerangecheck.Hour(timerangecheck.Hour - 12 < 0) + timerangecheck.Minute(timerangecheck.Hour - 12 < 0) / 60;
timerangechecknum(timerangecheck.Hour - 12 >= 0) = timerangecheck.Hour(timerangecheck.Hour - 12 >= 0) - 12 + timerangecheck.Minute(timerangecheck.Hour - 12 >= 0) / 60 ;
timerangechecknum = timerangechecknum';

emiT.timeplot = zeros(height(emiT),1) ;
emiT.timeplot(emiT.timeAM-9<0) = emiT.timeAM(emiT.timeAM-9<0) + 12 ;
emiT.timeplot(emiT.timeAM-9>0) = emiT.timeAM(emiT.timeAM-9>0)  ;
emiT.timeplot(emiT.timeAM-9>=0) = emiT.timeAM(emiT.timeAM-9>=0)  ;

emiT.timeplotorder = zeros(height(emiT),1) ;
emiT.timeplotorder = 20*(floor(emiT.timeplot)-9)+1 + floor(emiT.Time.Minute /3) ;

dataincirc(emiT.timeplotorder) = emiT.cat ;

% Set up color wheel in hsv space.
hueImage = (theta + pi) / (2 * pi);     % Hue is in the range 0 to 1.
sectors = ceil(hueImage * numberOfSectors) ;

for isect = 1:numberOfSectors
    sectors(sectors==isect) = dataincirc(isect) ;
end
sectors(sectors==1) = .416666667 ;
sectors(sectors==.5) = .0833 ;
sectors(sectors==0.1) = 1 ;
sectors(sectors==0) = 0 ;

hueImage = sectors ;   % Quantize hue 
saturationImage = ones(size(hueImage));      % Saturation (chroma) = 1 to be fully vivid.

% Make it have the wheel shape.
% Make a mask 1 in the wheel, and 0 outside the wheel.
wheelMaskImage = rho >= innerRadius & rho <= outerRadius;
% Hue and Saturation must be zero outside the wheel to get gray.
hueImage(~wheelMaskImage) = 0;
saturationImage(~wheelMaskImage|hueImage==0) = 0;
% Value image must be 1 inside the wheel, and the normalized gray level outside the wheel.
normalizedGrayLevel = grayLevel / 255;
valueImage = ones(size(hueImage)); % Initialize to all 1
valueImage(~wheelMaskImage) = normalizedGrayLevel;	% Outside the wheel = the normalized gray level.

% Combine separate h, s, and v channels into a single 3D hsv image.
hsvImage = cat(3, hueImage, saturationImage, valueImage);
% Convert to rgb space for display.
rgb = hsv2rgb(hsvImage);

% Display the final color wheel.
imshow(rgb, 'Parent', handles.axesImage);
