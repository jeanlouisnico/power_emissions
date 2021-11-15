function [Emissions] = load_emissions
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames')
%%%
% Load three types of database: the EcoInvent characterised data, the
% emissions factors used by Energiateolisuus, and the Fingrid emission
% factors.

Emissions.EcoInvent                 = readtable('Emissions_Summary.csv') ;
Emissions.ET                        = readtable('Emissions_ET.csv') ;
Emissions.ETS                       = readtable('Emissions_ETS.csv') ;
Emissions.Fingrid                   = readtable('Fingrid_coeff.csv') ;
Emissions.IPCC  = EM_EF_decode ;

%%% 
% Load the new system, in future release, the json file will be used
p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end-1), filesep) ;

Emissions.newem = jsondecode(fileread([fparts{1} filesep 'input' filesep 'co2emissions_uoulu.json']));

warning('ON', 'MATLAB:table:ModifiedAndSavedVarnames')
