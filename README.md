# emissionskit
Source code for evaluating the emissions from power system. Mainly applies to continental Europe.

The module was originally created in 2014 for the use in smart home application. It has then be further developed for the use in EU project for informing user in real-time about the environmental impact of their power consumption.

## Pre-requisite

In principle, the model can be run without any additional package, toolbox, or software. However, for a smooth implementation and plotting purposes, couple of external tools are requires: PostgreSQL ([Portable](https://github.com/garethflowers/postgresql-portable) or [official release](https://www.postgresql.org/download/)) and [Plotly](https://plotly.com/matlab/). PostgreSQL is used as it store data on a remote server. If psql is not installed, all data generated will be stored in an xml file in the project folder. The access to the PostgreSQL is set up in the beginning of the model and has to be run once. Changes can be made at any time by running the setup file again.

Regarding plotly, it it only used in the post process if one want to create html figures and/or present the data on an online graphing tool which is handy. You will have to setup plotly as it is recommended by their developers and it should run quite smoothly.

### Create database

Before starting the model, you will have to setup a database in PostgreSQL. You can name it the way you want as long as you defined it correctly in the *setupfetcher.m* command later.

When the setupfetcher is run, you will have to give data about:

- Get a security Token key from Fingrid to get access to their API 
- Get a security Token key from ENTSOE to get access to their API 
- Set up the access to your psql database if you are going to use it.

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
