# emissionskit
Source code for evaluating the emissions from power system. Mainly applies to continental Europe.

The module was originally created in 2014 for the use in smart home application. It has then be further developed for the use in EU project for informing user in real-time about the environmental impact of their power consumption.

## Pre-requisite

In principle, the model can be run without any additional package, toolbox, or software. However, for a smooth implementation and plotting purposes, couple of external tools are requires: **<u>PostgreSQL</u>** ([Portable](https://github.com/garethflowers/postgresql-portable) or [official release](https://www.postgresql.org/download/)) and [**<u>Plotly</u>**](https://plotly.com/matlab/). 

PostgreSQL is used to store data on a remote server or localhost (to be defined in the initialization phase). If psql is not installed, all data generated will be stored in an xml file in the project folder. The access to the PostgreSQL is set up in the beginning of the model and has to be run once. Changes can be made at any time by running the setup file again. The easiest (and admin free) way to get PostgreSQL is through the [PortableApps.com Platform](http://portableapps.com/download), but not can also be installed straight from [github](https://github.com/garethflowers/postgresql-portable).

Regarding [plotly](https://github.com/plotly/plotly_matlab), it is used in the post process if one wants to create html figures and/or present the data on an online graphing tool which is handy. You will have to setup plotly as it is recommended by their developers and it should run quite smoothly.

### Before running the model

Configure PostgreSQL correctly with a username and password and the correct port. No need to create a database at this point, it can be done through the setupfectcher.m function.

Run the setupfetcher.m function from the MatLab command window. You will have to give data about:

1. Get a security Token key from [Fingrid](https://data.fingrid.fi/en/pages/apis) to get access to their API 
2. Get a security Token key from [ENTSOE](https://transparency.entsoe.eu/content/static_content/Static%20content/web%20api/Guide.html#_request_methods) (see section 2 of their documentation) to get access to their API 
3. Set up the access to your PostgreSQL database.

If none of the security token are given, access to the TSO data are not provided and the model will run (but most likely giving incorrect output since it won't work as intended)

## Before running

start the 

## Running

The model can be run on a time to time basis or set within a timer that will run the model at regular intervals. In this second case, either run the module on a virtual machine on a server that will run uninterruptible or make sure you have a dedicated machine to do the job.

### One time run

just run *emissionskit* from the command window

```matlab
>> emissionskit
```

### Continuous run

run the data fetcher interface for starting up both the timer for data gathering and plotting. 

## Related work

The electricitymap project is a popular tool and well made for putting together the power networks. The network file from electricitymap was used to set up the power markets. The emission coefficient factors were used to aggregate the IPCC emission factors. Our method uses the IPCC data for comparison purposes and use primarily the EcoInvent data as a point of reference. There are fundamental differences on the environmental side of the model and represent the main difference with electricitymap. Most countries provide data on their energy production from thermal power plants (CHP or separate production), but the fuel accounting is not known. ENTSOE retrieves data that are guestimated but are quite off the recorded data. Our method uses historical data and linear predictive model for estimating the current fuel mix that is being used by a country. This significantly increases the accuracy of the emissions from the model. For a more detailed explanation, refer to our publication

## How to cite

Please cite this package using our main publication.

