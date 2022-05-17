% Chord diagram Matrix

 tes = load("testing_xchangev2.mat") ;
    Power = tes.Power ; 
    Emissions = tes.Emissions ;

country = fieldnames(Emissions) ;

DB = {'ENTSOE' 'emissionskit'} ;
ES = {'IPCC' 'EcoInvent'} ;
for DBi = 1:2
    for ESi = 1:2
        optionsChange.(DB{DBi}).(ES{ESi}) = array2table(zeros(length(country),length(country)));
        optionsChange.(DB{DBi}).(ES{ESi}).Properties.VariableNames = country ;
        optionsChange.(DB{DBi}).(ES{ESi}).Properties.RowNames = country ;
    end
end
for eachcountry = 1:length(country)
    for DBi = 1:2
        for ESi = 1:2
            try
                 XChangedtaa = Emissions.(country{eachcountry}).(DB{DBi}).(ES{ESi}).exchange ;
            catch Me
                Me
                source = join({country{eachcountry} DB{DBi} ES{ESi}},'-')
                continue
            end
             count_Name = fieldnames(XChangedtaa) ;
             for destination_coun = 1:length(count_Name)
                 switch count_Name{destination_coun}
                     case 'EL'
                         outcount = 'GR' ;
                     otherwise
                         outcount = count_Name{destination_coun} ;
                 end
                try            
                    optionsChange.(DB{DBi}).(ES{ESi})(country{eachcountry},outcount).Variables = XChangedtaa.(count_Name{destination_coun}) ;
                catch
                    continue ;
                end
             end
%              optionsChange.(DB{DBi}).(ES{ESi})(country{eachcountry},country{eachcountry}).Variables = Emissions.(country{eachcountry}).(DB{DBi}).(ES{ESi}).total-sum(struct2array(XChangedtaa)) ;
        end
    end
end
optionsChange.emissionskit.EcoInvent.Variables = round(optionsChange.emissionskit.EcoInvent.Variables) ;
a = optionsChange.emissionskit.EcoInvent.Variables ;
a(a<0) = 0 ;
optionsChange.emissionskit.EcoInvent.Variables = a ;

writetable(optionsChange.emissionskit.EcoInvent,'test.csv');


exec=system('"C:\Portable_software\R-4.1.3\bin\Rscript.exe" chord_diagramR_v3.R');