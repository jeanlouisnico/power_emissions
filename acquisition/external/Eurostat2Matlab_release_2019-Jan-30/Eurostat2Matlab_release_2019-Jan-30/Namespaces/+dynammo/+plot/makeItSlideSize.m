function makeItSlideSize(han)
% 
% Resizes figure to make it fit into slide
% 
% INPUT: han ...figure handle (figure can even be non-tsobj())
% 

% keyboard;

%% Body
units = get(han,'Units');

set(han,'Units','pixels');
pos_ = get(han,'Position');

pos_(3) = 820;% tsobj() uses 960;
pos_(4) = 450;% tsobj() uses 520;

set(han,'Position',pos_);

set(han,'Units',units);

end