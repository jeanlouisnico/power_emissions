function res = isAutoUpdate() 
res = ([100,1]*sscanf(version,'%d.',2))>=902;% M2017a and later, legend by default automatically shows newly appended objects