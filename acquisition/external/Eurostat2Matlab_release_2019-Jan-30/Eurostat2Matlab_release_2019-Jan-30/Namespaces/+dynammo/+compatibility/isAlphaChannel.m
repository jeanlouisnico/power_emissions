function res = isAlphaChannel()
res = [100,1]*sscanf(version,'%d.',2)>=806; % M2015b+