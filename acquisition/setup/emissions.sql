begin;

CREATE TABLE IF NOT EXISTS emissions (
    id          BIGSERIAL NOT NULL PRIMARY key,
    date_time   timestamp NOT NULL,
    country     VARCHAR(50),
    EmDB        VARCHAR(50),
    emissionintprod    FLOAT,
    emissionintcons    FLOAT
);

CREATE TABLE IF NOT EXISTS xchange (
    id          BIGSERIAL NOT NULL PRIMARY key,
    date_time   timestamp NOT NULL,
	source   	VARCHAR(50),
    fromcountry VARCHAR(50),
    tocountry   VARCHAR(50),
    powerexch   FLOAT
);

CREATE TABLE IF NOT EXISTS powerbyfuel (
    id          BIGSERIAL NOT NULL PRIMARY key,
    date_time   timestamp NOT NULL,
    country     VARCHAR(50),
    fuel        VARCHAR(50),
    powersource VARCHAR(50),
    power_generated    FLOAT
);

CREATE TABLE IF NOT EXISTS emissionsEurostat (
    id          BIGSERIAL NOT NULL PRIMARY key,
    date_time   DATE NOT NULL,
    country     VARCHAR(50),
    fuel        VARCHAR(50),
    valuel 	NUMERIC
);

CREATE TABLE IF NOT EXISTS emissions_estonia (
    id          BIGSERIAL NOT NULL PRIMARY key,
    date_time   timestamp NOT NULL,
    coal NUMERIC,
    firewood        NUMERIC,
    heavy_fuel_oil  NUMERIC,
    light_fuel_oil  NUMERIC,
    milled_peat     NUMERIC,
    natural_gas NUMERIC,
    oil_shale   NUMERIC,
    peat_briquette NUMERIC,
    pellets NUMERIC,
    shale_oil NUMERIC,
    sod_peat NUMERIC,
    wood_chips NUMERIC,
    wood_waste_industrial NUMERIC
);

CREATE TABLE IF NOT EXISTS rekistery_fi (
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