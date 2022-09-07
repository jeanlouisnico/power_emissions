function name_exists = isvar(t, variablenames)


name_exists = any(strcmp(variablenames,t.Properties.VariableNames)) ;