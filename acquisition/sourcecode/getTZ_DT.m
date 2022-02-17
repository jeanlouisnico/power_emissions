function TZout = getTZ_DT(timein)

hoursin = hours(timein) ;
    minutesdec = mod(hoursin,1) ;

minutesin = minutes(minutes(minutesdec * 60)) ;

if hoursin >= 0
    sign = '+' ;
else
    sign = '-' ;
    hoursin = abs(hoursin) ;
end

timeTZ2find = ['UTC ' sign sprintf('%02d',hoursin) ':' sprintf('%02d',minutesin)] ;

timezones = {'Pacific/Pago_Pago'	'UTC -11:00'
            'Pacific/Honolulu'	'UTC -10:00'
            'America/Juneau'	'UTC -08:00'
            'America/Los_Angeles'	'UTC -07:00'
            'America/Denver'	'UTC -06:00'
            'America/Mexico_City'	'UTC -05:00'
            'America/Indiana/Indianapolis'	'UTC -04:00'
            'America/Caracas'	'UTC -04:30'
            'America/Santiago'	'UTC -03:00'
            'America/St_Johns'	'UTC -02:30'
            'America/Godthab'	'UTC -02:00'
            'Atlantic/Cape_Verde'	'UTC -01:00'
            'Etc/UTC'	'UTC +00:00'
            'Europe/Lisbon'	'UTC +01:00'
            'Europe/Skopje'	'UTC +02:00'
            'Europe/Helsinki'	'UTC +03:00'
            'Asia/Tehran'	'UTC +03:30'
            'Asia/Muscat'	'UTC +04:00'
            'Asia/Kabul'	'UTC +04:30'
            'Asia/Yekaterinburg'	'UTC +05:00'
            'Asia/Colombo'	'UTC +05:30'
            'Asia/Kathmandu'	'UTC +05:45'
            'Asia/Dhaka'	'UTC +06:00'
            'Asia/Rangoon'	'UTC +06:30'
            'Asia/Jakarta'	'UTC +07:00'
            'Asia/Chongqing'	'UTC +08:00'
            'Asia/Seoul'	'UTC +09:00'
            'Australia/Darwin'	'UTC +09:30'
            'Australia/Sydney'	'UTC +10:00'
            'Pacific/Guadalcanal'	'UTC +11:00'
            'Asia/Kamchatka'	'UTC +12:00'
            'Pacific/Chatham'	'UTC +12:45'
            'Pacific/Fakaofo'	'UTC +13:00'} ;



TZout = timezones(contains(timezones(:,2), timeTZ2find),1) ;
