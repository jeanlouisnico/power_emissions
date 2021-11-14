function out = countrycode(countryname)

countries = {'Afghanistan'	'The Islamic Republic of Afghanistan'	'UN member state'	'AF'	'AFG'
'Åland Islands'	'Åland'	'Finland'	'AX'	'ALA'
'Albania'	'The Republic of Albania'	'UN member state'	'AL'	'ALB'
'Algeria'	'The People Democratic Republic of Algeria'	'UN member state'	'DZ'	'DZA'
'American Samoa'	'The Territory of American Samoa'	'United States'	'AS'	'ASM'
'Andorra'	'The Principality of Andorra'	'UN member state'	'AD'	'AND'
'Angola'	'The Republic of Angola'	'UN member state'	'AO'	'AGO'
'Anguilla'	'Anguilla'	'United Kingdom'	'AI'	'AIA'
'Antarctica '	'All land and ice shelves south of the 60th parallel south'	'Antarctic Treaty'	'AQ'	'ATA'
'Antigua and Barbuda'	'Antigua and Barbuda'	'UN member state'	'AG'	'ATG'
'Argentina'	'The Argentine Republic'	'UN member state'	'AR'	'ARG'
'Armenia'	'The Republic of Armenia'	'UN member state'	'AM'	'ARM'
'Aruba'	'Aruba'	'Netherlands'	'AW'	'ABW'
'Australia '	'The Commonwealth of Australia'	'UN member state'	'AU'	'AUS'
'Austria'	'The Republic of Austria'	'UN member state'	'AT'	'AUT'
'Azerbaijan'	'The Republic of Azerbaijan'	'UN member state'	'AZ'	'AZE'
'Bahamas (the)'	'The Commonwealth of The Bahamas'	'UN member state'	'BS'	'BHS'
'Bahrain'	'The Kingdom of Bahrain'	'UN member state'	'BH'	'BHR'
'Bangladesh'	'The People Republic of Bangladesh'	'UN member state'	'BD'	'BGD'
'Barbados'	'Barbados'	'UN member state'	'BB'	'BRB'
'Belarus'	'The Republic of Belarus'	'UN member state'	'BY'	'BLR'
'Belgium'	'The Kingdom of Belgium'	'UN member state'	'BE'	'BEL'
'Belize'	'Belize'	'UN member state'	'BZ'	'BLZ'
'Benin'	'The Republic of Benin'	'UN member state'	'BJ'	'BEN'
'Bermuda'	'Bermuda'	'United Kingdom'	'BM'	'BMU'
'Bhutan'	'The Kingdom of Bhutan'	'UN member state'	'BT'	'BTN'
'Bolivia (Plurinational State of)'	'The Plurinational State of Bolivia'	'UN member state'	'BO'	'BOL'
'Bonaire'	'Bonaire, Sint Eustatius and Saba'	'Netherlands'	'BQ'	'BES'
'Bosnia and Herzegovina'	'Bosnia and Herzegovina'	'UN member state'	'BA'	'BIH'
'Botswana'	'The Republic of Botswana'	'UN member state'	'BW'	'BWA'
'Bouvet Island'	'Bouvet Island'	'Norway'	'BV'	'BVT'
'Brazil'	'The Federative Republic of Brazil'	'UN member state'	'BR'	'BRA'
'British Indian Ocean Territory (the)'	'The British Indian Ocean Territory'	'United Kingdom'	'IO'	'IOT'
'Brunei Darussalam '	'The Nation of Brunei, the Abode of Peace'	'UN member state'	'BN'	'BRN'
'Bulgaria'	'The Republic of Bulgaria'	'UN member state'	'BG'	'BGR'
'Burkina Faso'	'Burkina Faso'	'UN member state'	'BF'	'BFA'
'Burundi'	'The Republic of Burundi'	'UN member state'	'BI'	'BDI'
'Cabo Verde '	'The Republic of Cabo Verde'	'UN member state'	'CV'	'CPV'
'Cambodia'	'The Kingdom of Cambodia'	'UN member state'	'KH'	'KHM'
'Cameroon'	'The Republic of Cameroon'	'UN member state'	'CM'	'CMR'
'Canada'	'Canada'	'UN member state'	'CA'	'CAN'
'Cayman Islands (the)'	'The Cayman Islands'	'United Kingdom'	'KY'	'CYM'
'Central African Republic (the)'	'The Central African Republic'	'UN member state'	'CF'	'CAF'
'Chad'	'The Republic of Chad'	'UN member state'	'TD'	'TCD'
'Chile'	'The Republic of Chile'	'UN member state'	'CL'	'CHL'
'China'	'The People Republic of China'	'UN member state'	'CN'	'CHN'
'Christmas Island'	'The Territory of Christmas Island'	'Australia'	'CX'	'CXR'
'Cocos (Keeling) Islands (the)'	'The Territory of Cocos (Keeling) Islands'	'Australia'	'CC'	'CCK'
'Colombia'	'The Republic of Colombia'	'UN member state'	'CO'	'COL'
'Comoros (the)'	'The Union of the Comoros'	'UN member state'	'KM'	'COM'
'Congo (the Democratic Republic of the)'	'The Democratic Republic of the Congo'	'UN member state'	'CD'	'COD'
'Congo (the) '	'The Republic of the Congo'	'UN member state'	'CG'	'COG'
'Cook Islands (the)'	'The Cook Islands'	'New Zealand'	'CK'	'COK'
'Costa Rica'	'The Republic of Costa Rica'	'UN member state'	'CR'	'CRI'
'Côte dIvoire '	'The Republic of Côte dIvoire'	'UN member state'	'CI'	'CIV'
'Croatia'	'The Republic of Croatia'	'UN member state'	'HR'	'HRV'
'Cuba'	'The Republic of Cuba'	'UN member state'	'CU'	'CUB'
'Curaçao'	'The Country of Curaçao'	'Netherlands'	'CW'	'CUW'
'Cyprus'	'The Republic of Cyprus'	'UN member state'	'CY'	'CYP'
'Czechia '	'The Czech Republic'	'UN member state'	'CZ'	'CZE'
'Denmark'	'The Kingdom of Denmark'	'UN member state'	'DK'	'DNK'
'Djibouti'	'The Republic of Djibouti'	'UN member state'	'DJ'	'DJI'
'Dominica'	'The Commonwealth of Dominica'	'UN member state'	'DM'	'DMA'
'Dominican Republic (the)'	'The Dominican Republic'	'UN member state'	'DO'	'DOM'
'Ecuador'	'The Republic of Ecuador'	'UN member state'	'EC'	'ECU'
'Egypt'	'The Arab Republic of Egypt'	'UN member state'	'EG'	'EGY'
'El Salvador'	'The Republic of El Salvador'	'UN member state'	'SV'	'SLV'
'Equatorial Guinea'	'The Republic of Equatorial Guinea'	'UN member state'	'GQ'	'GNQ'
'Eritrea'	'The State of Eritrea'	'UN member state'	'ER'	'ERI'
'Estonia'	'The Republic of Estonia'	'UN member state'	'EE'	'EST'
'Eswatini '	'The Kingdom of Eswatini'	'UN member state'	'SZ'	'SWZ'
'Ethiopia'	'The Federal Democratic Republic of Ethiopia'	'UN member state'	'ET'	'ETH'
'Falkland Islands (the) [Malvinas] '	'The Falkland Islands'	'United Kingdom'	'FK'	'FLK'
'Faroe Islands (the)'	'The Faroe Islands'	'Denmark'	'FO'	'FRO'
'Fiji'	'The Republic of Fiji'	'UN member state'	'FJ'	'FJI'
'Finland'	'The Republic of Finland'	'UN member state'	'FI'	'FIN'
'France '	'The French Republic'	'UN member state'	'FR'	'FRA'
'French Guiana'	'Guyane'	'France'	'GF'	'GUF'
'French Polynesia'	'French Polynesia'	'France'	'PF'	'PYF'
'French Southern Territories (the) [m]'	'The French Southern and Antarctic Lands'	'France'	'TF'	'ATF'
'Gabon'	'The Gabonese Republic'	'UN member state'	'GA'	'GAB'
'Gambia (the)'	'The Republic of The Gambia'	'UN member state'	'GM'	'GMB'
'Georgia'	'Georgia'	'UN member state'	'GE'	'GEO'
'Germany'	'The Federal Republic of Germany'	'UN member state'	'DE'	'DEU'
'Ghana'	'The Republic of Ghana'	'UN member state'	'GH'	'GHA'
'Gibraltar'	'Gibraltar'	'United Kingdom'	'GI'	'GIB'
'Greece'	'The Hellenic Republic'	'UN member state'	'GR'	'GRC'
'Greenland'	'Kalaallit Nunaat'	'Denmark'	'GL'	'GRL'
'Grenada'	'Grenada'	'UN member state'	'GD'	'GRD'
'Guadeloupe'	'Guadeloupe'	'France'	'GP'	'GLP'
'Guam'	'The Territory of Guam'	'United States'	'GU'	'GUM'
'Guatemala'	'The Republic of Guatemala'	'UN member state'	'GT'	'GTM'
'Guernsey'	'The Bailiwick of Guernsey'	'British Crown'	'GG'	'GGY'
'Guinea'	'The Republic of Guinea'	'UN member state'	'GN'	'GIN'
'Guinea-Bissau'	'The Republic of Guinea-Bissau'	'UN member state'	'GW'	'GNB'
'Guyana'	'The Co-operative Republic of Guyana'	'UN member state'	'GY'	'GUY'
'Haiti'	'The Republic of Haiti'	'UN member state'	'HT'	'HTI'
'Heard Island and McDonald Islands'	'The Territory of Heard Island and McDonald Islands'	'Australia'	'HM'	'HMD'
'Holy See (the) '	'The Holy See'	'UN observer state'	'VA'	'VAT'
'Honduras'	'The Republic of Honduras'	'UN member state'	'HN'	'HND'
'Hong Kong'	'The Hong Kong Special Administrative Region of China[10]'	'China'	'HK'	'HKG'
'Hungary'	'Hungary'	'UN member state'	'HU'	'HUN'
'Iceland'	'Iceland'	'UN member state'	'IS'	'ISL'
'India'	'The Republic of India'	'UN member state'	'IN'	'IND'
'Indonesia'	'The Republic of Indonesia'	'UN member state'	'ID'	'IDN'
'Iran (Islamic Republic of)'	'The Islamic Republic of Iran'	'UN member state'	'IR'	'IRN'
'Iraq'	'The Republic of Iraq'	'UN member state'	'IQ'	'IRQ'
'Ireland'	'Ireland'	'UN member state'	'IE'	'IRL'
'Isle of Man'	'The Isle of Man'	'British Crown'	'IM'	'IMN'
'Israel'	'The State of Israel'	'UN member state'	'IL'	'ISR'
'Italy'	'The Italian Republic'	'UN member state'	'IT'	'ITA'
'Jamaica'	'Jamaica'	'UN member state'	'JM'	'JAM'
'Japan'	'Japan'	'UN member state'	'JP'	'JPN'
'Jersey'	'The Bailiwick of Jersey'	'British Crown'	'JE'	'JEY'
'Jordan'	'The Hashemite Kingdom of Jordan'	'UN member state'	'JO'	'JOR'
'Kazakhstan'	'The Republic of Kazakhstan'	'UN member state'	'KZ'	'KAZ'
'Kenya'	'The Republic of Kenya'	'UN member state'	'KE'	'KEN'
'Kiribati'	'The Republic of Kiribati'	'UN member state'	'KI'	'KIR'
'Kosovo'	'Republic of Kosovo'	'UN member state'	'KX'	'KX'
'South Korea (the Democratic Peoples Republic of) '	'The Democratic Peoples Republic of Korea'	'UN member state'	'KP'	'PRK'
'North Korea (the Republic of)'	'The Republic of Korea'	'UN member state'	'KR'	'KOR'
'Kuwait'	'The State of Kuwait'	'UN member state'	'KW'	'KWT'
'Kyrgyzstan'	'The Kyrgyz Republic'	'UN member state'	'KG'	'KGZ'
'Lao Peoples Democratic Republic (the) '	'The Lao Peoples Democratic Republic'	'UN member state'	'LA'	'LAO'
'Latvia'	'The Republic of Latvia'	'UN member state'	'LV'	'LVA'
'Lebanon'	'The Lebanese Republic'	'UN member state'	'LB'	'LBN'
'Lesotho'	'The Kingdom of Lesotho'	'UN member state'	'LS'	'LSO'
'Liberia'	'The Republic of Liberia'	'UN member state'	'LR'	'LBR'
'Libya'	'The State of Libya'	'UN member state'	'LY'	'LBY'
'Liechtenstein'	'The Principality of Liechtenstein'	'UN member state'	'LI'	'LIE'
'Lithuania'	'The Republic of Lithuania'	'UN member state'	'LT'	'LTU'
'Luxembourg'	'The Grand Duchy of Luxembourg'	'UN member state'	'LU'	'LUX'
'Macao '	'The Macao Special Administrative Region of China'	'China'	'MO'	'MAC'
'North Macedonia '	'The Republic of North Macedonia'	'UN member state'	'MK'	'MKD'
'Madagascar'	'The Republic of Madagascar'	'UN member state'	'MG'	'MDG'
'Malawi'	'The Republic of Malawi'	'UN member state'	'MW'	'MWI'
'Malaysia'	'Malaysia'	'UN member state'	'MY'	'MYS'
'Maldives'	'The Republic of Maldives'	'UN member state'	'MV'	'MDV'
'Mali'	'The Republic of Mali'	'UN member state'	'ML'	'MLI'
'Malta'	'The Republic of Malta'	'UN member state'	'MT'	'MLT'
'Marshall Islands (the)'	'The Republic of the Marshall Islands'	'UN member state'	'MH'	'MHL'
'Martinique'	'Martinique'	'France'	'MQ'	'MTQ'
'Mauritania'	'The Islamic Republic of Mauritania'	'UN member state'	'MR'	'MRT'
'Mauritius'	'The Republic of Mauritius'	'UN member state'	'MU'	'MUS'
'Mayotte'	'The Department of Mayotte'	'France'	'YT'	'MYT'
'Mexico'	'The United Mexican States'	'UN member state'	'MX'	'MEX'
'Micronesia (Federated States of)'	'The Federated States of Micronesia'	'UN member state'	'FM'	'FSM'
'Moldova (the Republic of)'	'The Republic of Moldova'	'UN member state'	'MD'	'MDA'
'Monaco'	'The Principality of Monaco'	'UN member state'	'MC'	'MCO'
'Mongolia'	'Mongolia'	'UN member state'	'MN'	'MNG'
'Montenegro'	'Montenegro'	'UN member state'	'ME'	'MNE'
'Montserrat'	'Montserrat'	'United Kingdom'	'MS'	'MSR'
'Morocco'	'The Kingdom of Morocco'	'UN member state'	'MA'	'MAR'
'Mozambique'	'The Republic of Mozambique'	'UN member state'	'MZ'	'MOZ'
'Myanmar [t]'	'The Republic of the Union of Myanmar'	'UN member state'	'MM'	'MMR'
'Namibia'	'The Republic of Namibia'	'UN member state'	'NA'	'NAM'
'Nauru'	'The Republic of Nauru'	'UN member state'	'NR'	'NRU'
'Nepal'	'The Federal Democratic Republic of Nepal'	'UN member state'	'NP'	'NPL'
'Netherlands (the)'	'The Kingdom of the Netherlands'	'UN member state'	'NL'	'NLD'
'New Caledonia'	'New Caledonia'	'France'	'NC'	'NCL'
'New Zealand'	'New Zealand'	'UN member state'	'NZ'	'NZL'
'Nicaragua'	'The Republic of Nicaragua'	'UN member state'	'NI'	'NIC'
'Niger (the)'	'The Republic of the Niger'	'UN member state'	'NE'	'NER'
'Nigeria'	'The Federal Republic of Nigeria'	'UN member state'	'NG'	'NGA'
'Niue'	'Niue'	'New Zealand'	'NU'	'NIU'
'Norfolk Island'	'The Territory of Norfolk Island'	'Australia'	'NF'	'NFK'
'Northern Mariana Islands (the)'	'The Commonwealth of the Northern Mariana Islands'	'United States'	'MP'	'MNP'
'Norway'	'The Kingdom of Norway'	'UN member state'	'NO'	'NOR'
'Oman'	'The Sultanate of Oman'	'UN member state'	'OM'	'OMN'
'Pakistan'	'The Islamic Republic of Pakistan'	'UN member state'	'PK'	'PAK'
'Palau'	'The Republic of Palau'	'UN member state'	'PW'	'PLW'
'Palestine, State of'	'The State of Palestine'	'UN observer state'	'PS'	'PSE'
'Panama'	'The Republic of Panamá'	'UN member state'	'PA'	'PAN'
'Papua New Guinea'	'The Independent State of Papua New Guinea'	'UN member state'	'PG'	'PNG'
'Paraguay'	'The Republic of Paraguay'	'UN member state'	'PY'	'PRY'
'Peru'	'The Republic of Perú'	'UN member state'	'PE'	'PER'
'Philippines (the)'	'The Republic of the Philippines'	'UN member state'	'PH'	'PHL'
'Pitcairn [u]'	'The Pitcairn, Henderson, Ducie and Oeno Islands'	'United Kingdom'	'PN'	'PCN'
'Poland'	'The Republic of Poland'	'UN member state'	'PL'	'POL'
'Portugal'	'The Portuguese Republic'	'UN member state'	'PT'	'PRT'
'Puerto Rico'	'The Commonwealth of Puerto Rico'	'United States'	'PR'	'PRI'
'Qatar'	'The State of Qatar'	'UN member state'	'QA'	'QAT'
'Réunion'	'Réunion'	'France'	'RE'	'REU'
'Romania'	'Romania'	'UN member state'	'RO'	'ROU'
'Russian Federation (the) '	'The Russian Federation'	'UN member state'	'RU'	'RUS'
'Rwanda'	'The Republic of Rwanda'	'UN member state'	'RW'	'RWA'
'Saint Barthélemy'	'The Collectivity of Saint-Barthélemy'	'France'	'BL'	'BLM'
'Saint Helena'	'Saint Helena, Ascension and Tristan da Cunha'	'United Kingdom'	'SH'	'SHN'
'Saint Kitts and Nevis'	'Saint Kitts and Nevis'	'UN member state'	'KN'	'KNA'
'Saint Lucia'	'Saint Lucia'	'UN member state'	'LC'	'LCA'
'Saint Martin (French part)'	'The Collectivity of Saint-Martin'	'France'	'MF'	'MAF'
'Saint Pierre and Miquelon'	'The Overseas Collectivity of Saint-Pierre and Miquelon'	'France'	'PM'	'SPM'
'Saint Vincent and the Grenadines'	'Saint Vincent and the Grenadines'	'UN member state'	'VC'	'VCT'
'Samoa'	'The Independent State of Samoa'	'UN member state'	'WS'	'WSM'
'San Marino'	'The Republic of San Marino'	'UN member state'	'SM'	'SMR'
'Sao Tome and Principe'	'The Democratic Republic of São Tomé and Príncipe'	'UN member state'	'ST'	'STP'
'Saudi Arabia'	'The Kingdom of Saudi Arabia'	'UN member state'	'SA'	'SAU'
'Senegal'	'The Republic of Senegal'	'UN member state'	'SN'	'SEN'
'Serbia'	'The Republic of Serbia'	'UN member state'	'RS'	'SRB'
'Seychelles'	'The Republic of Seychelles'	'UN member state'	'SC'	'SYC'
'Sierra Leone'	'The Republic of Sierra Leone'	'UN member state'	'SL'	'SLE'
'Singapore'	'The Republic of Singapore'	'UN member state'	'SG'	'SGP'
'Sint Maarten (Dutch part)'	'Sint Maarten'	'Netherlands'	'SX'	'SXM'
'Slovakia'	'The Slovak Republic'	'UN member state'	'SK'	'SVK'
'Slovenia'	'The Republic of Slovenia'	'UN member state'	'SI'	'SVN'
'Solomon Islands'	'The Solomon Islands'	'UN member state'	'SB'	'SLB'
'Somalia'	'The Federal Republic of Somalia'	'UN member state'	'SO'	'SOM'
'South Africa'	'The Republic of South Africa'	'UN member state'	'ZA'	'ZAF'
'South Georgia and the South Sandwich Islands'	'South Georgia and the South Sandwich Islands'	'United Kingdom'	'GS'	'SGS'
'South Sudan'	'The Republic of South Sudan'	'UN member state'	'SS'	'SSD'
'Spain'	'The Kingdom of Spain'	'UN member state'	'ES'	'ESP'
'Sri Lanka'	'The Democratic Socialist Republic of Sri Lanka'	'UN member state'	'LK'	'LKA'
'Sudan (the)'	'The Republic of the Sudan'	'UN member state'	'SD'	'SDN'
'Suriname'	'The Republic of Suriname'	'UN member state'	'SR'	'SUR'
'Svalbard'	'Svalbard and Jan Mayen'	'Norway'	'SJ'	'SJM'
'Sweden'	'The Kingdom of Sweden'	'UN member state'	'SE'	'SWE'
'Switzerland'	'The Swiss Confederation'	'UN member state'	'CH'	'CHE'
'Syrian Arab Republic (the) '	'The Syrian Arab Republic'	'UN member state'	'SY'	'SYR'
'Taiwan'	'The Republic of China'	'Disputed [z]'	'TW'	'TWN'
'Tajikistan'	'The Republic of Tajikistan'	'UN member state'	'TJ'	'TJK'
'Tanzania, the United Republic of'	'The United Republic of Tanzania'	'UN member state'	'TZ'	'TZA'
'Thailand'	'The Kingdom of Thailand'	'UN member state'	'TH'	'THA'
'Timor-Leste '	'The Democratic Republic of Timor-Leste'	'UN member state'	'TL'	'TLS'
'Togo'	'The Togolese Republic'	'UN member state'	'TG'	'TGO'
'Tokelau'	'Tokelau'	'New Zealand'	'TK'	'TKL'
'Tonga'	'The Kingdom of Tonga'	'UN member state'	'TO'	'TON'
'Trinidad and Tobago'	'The Republic of Trinidad and Tobago'	'UN member state'	'TT'	'TTO'
'Tunisia'	'The Republic of Tunisia'	'UN member state'	'TN'	'TUN'
'Turkey'	'The Republic of Turkey'	'UN member state'	'TR'	'TUR'
'Turkmenistan'	'Turkmenistan'	'UN member state'	'TM'	'TKM'
'Turks and Caicos Islands (the)'	'The Turks and Caicos Islands'	'United Kingdom'	'TC'	'TCA'
'Tuvalu'	'Tuvalu'	'UN member state'	'TV'	'TUV'
'Uganda'	'The Republic of Uganda'	'UN member state'	'UG'	'UGA'
'Ukraine'	'Ukraine'	'UN member state'	'UA'	'UKR'
'United Arab Emirates (the)'	'The United Arab Emirates'	'UN member state'	'AE'	'ARE'
'United Kingdom of Great Britain and Northern Ireland (the)'	'The United Kingdom of Great Britain and Northern Ireland'	'UN member state'	'GB'	'GBR'
'United States Minor Outlying Islands (the) '	'Baker Island, Howland Island, Jarvis Island, Johnston Atoll, Kingman Reef, Midway Atoll, Navassa Island, Palmyra Atoll, and Wake Island'	'United States'	'UM'	'UMI'
'United States of America (the)'	'The United States of America'	'UN member state'	'US'	'USA'
'Uruguay'	'The Oriental Republic of Uruguay'	'UN member state'	'UY'	'URY'
'Uzbekistan'	'The Republic of Uzbekistan'	'UN member state'	'UZ'	'UZB'
'Vanuatu'	'The Republic of Vanuatu'	'UN member state'	'VU'	'VUT'
'Venezuela (Bolivarian Republic of)'	'The Bolivarian Republic of Venezuela'	'UN member state'	'VE'	'VEN'
'Viet Nam [ae]'	'The Socialist Republic of Viet Nam'	'UN member state'	'VN'	'VNM'
'Virgin Islands (British) '	'The Virgin Islands'	'United Kingdom'	'VG'	'VGB'
'Virgin Islands (U.S.) '	'The Virgin Islands of the United States'	'United States'	'VI'	'VIR'
'Wallis and Futuna'	'The Territory of the Wallis and Futuna Islands'	'France'	'WF'	'WLF'
'Western Sahara '	'The Sahrawi Arab Democratic Republic'	'Disputed [ai]'	'EH'	'ESH'
'Yemen'	'The Republic of Yemen'	'UN member state'	'YE'	'YEM'
'Zambia'	'The Republic of Zambia'	'UN member state'	'ZM'	'ZMB'
'Zimbabwe'	'The Republic of Zimbabwe'	'UN member state'	'ZW'	'ZWE'
};

countries = cell2table(countries, 'VariableNames', {'countryname' 'officialname' 'sovereignty' 'alpha-2code' 'alpha-3code'}) ;

if isa(countryname,'string') || isa(countryname,'char')
    out = countries.("alpha-2code")(contains(countries.countryname, countryname)) ;
    out = out{:} ;
elseif isa(countryname,'cell')
    out = cellfun(@(x) countries.("alpha-2code")(contains(countries.countryname,x)),countryname,'UniformOutput',false);
    out = [out{:}]' ;
end

