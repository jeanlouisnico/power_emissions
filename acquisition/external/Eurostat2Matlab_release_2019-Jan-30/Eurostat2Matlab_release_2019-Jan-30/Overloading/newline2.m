function out = newline2()
if dynammo.compatibility.M2017a
    out = newline();
else
    out = sprintf('\n');
end