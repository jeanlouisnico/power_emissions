function markers(varargin)

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% Generate some data using the besselj function
x = 0:0.2:10;
y0 = besselj(0,x);
y1 = besselj(0.3,x);
y2 = besselj(0.6,x);
y3 = besselj(0.9,x);
y4 = besselj(1.2,x);
y5 = besselj(1.5,x);
y6 = besselj(1.8,x);
y7 = besselj(2.1,x);
y8 = besselj(2.4,x);
y9 = besselj(2.7,x);
y10 = besselj(3.0,x);
y11 = besselj(3.3,x);
y12 = besselj(3.6,x);

% Plot the points from the Bessel functions using standard marker types
figure;
hold on;
plot(x, y0, 'r+', x, y1, 'go', x, y2, 'b*', x, y3, 'cx', ...
    x, y4, 'ms', x, y5, 'rd', x, y6, 'kv');
plot(x,y7,'color',[0.5 0.5 0.5],'marker','^');
plot(x,y8,'color',[0.5 0.3 1.0],'marker','.');
plot(x,y9,'color',[0.5 0.3 0.5],'marker','<');
plot(x,y10,'color',[0   0.3 0.5],'marker','>');
plot(x,y11,'color',[0.5 0   0.5],'marker','p');
plot(x,y12,'color',[0.5 0.3 0.0],'marker','h');

hold off;
lg = legend({'''+''','''o''','''*''','''x''','''s''', ...
             '''d''','''v''','''^''','''.''','''<''', ...
             '''>''','''p''','''h'''});

set(lg,'fontsize',14);

end