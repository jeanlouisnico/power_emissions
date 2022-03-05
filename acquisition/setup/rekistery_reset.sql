begin;

drop table if exists rekistery_fi;

create table rekistery_fi (
    id          BIGSERIAL NOT NULL PRIMARY key,
    name varchar(100),
    company varchar(100),
    businessID varchar(100),
    address varchar(100),
    town varchar(100),
    postalCode int,
    location varchar(100),
    type varchar(100),
    separatePowerProduction_Maximum_Total_MW numeric,
    separatePowerProduction_Maximum_Hour_MW numeric,
    separatePowerProduction_Decomissioned_Hour_MW numeric,
    combinedHeatAndPowerProduction_Industry_Maximum_Total_MW numeric,
    combinedHeatAndPowerProduction_Industry_Hour_Total_MW numeric,
    combinedHeatAndPowerProduction_Industry_Decomissioned_Total_MW numeric,
    combinedHeatAndPowerProduction_DistrictHeating_Total_MW numeric,
    combinedHeatAndPowerProduction_DistrictHeating_Hour_MW numeric,
    combinedHeatAndPowerProduction_DistrictHeating_Decomissioned_To numeric,
    maximum_Total_MW numeric,
    hour_Total_MW numeric,
    decomissioned_Total_MW numeric,
    mainFuel  varchar(100),
    standbyFuel varchar(100),
    standbyFuel_1 varchar(100)
);

commit;