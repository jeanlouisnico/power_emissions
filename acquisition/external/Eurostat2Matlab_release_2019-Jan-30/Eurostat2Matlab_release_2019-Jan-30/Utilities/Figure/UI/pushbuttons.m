function pushbuttons(fhandle)
%
% Puts additional convenient clickable buttons to a figure object
% 
% INPUT: handle to a figure
% 
% OUTPUT: none
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

drawnow;
toolbar = findall(fhandle,'Type','uitoolbar');
if ~isempty(toolbar)

    % Always-on-top toggle switch
    aot = uipushtool(toolbar,'CData',get_AOT_image(), ...
            'Separator','on', ...
            ... 'HandleVisibility','off', ...
            'ToolTipString','Always on top toggle');%, ...
    set(aot,'ClickedCallback',@(varargin) AOTfeature(gcf,aot));%'AOTfeature(gcf)'

    % .PDF printer
    uipushtool(toolbar,'CData',PDF_button_im(), ...
        'Separator','off', ...
        ... 'HandleVisibility','off', ...
        'ToolTipString','Print figure to .pdf', ...
        'ClickedCallback','PDFclickedCallback(gcf)');

    % .PPTX export
    if ispc
        uipushtool(toolbar,'CData',PPT_button_im(), ...
            'Separator','off', ...
            ... 'HandleVisibility','off', ...
            'ToolTipString','Export figure to .pptx', ...
            'ClickedCallback','PPTclickedCallback(gcf)');
    end

end
    
%% Support functions

function img = get_AOT_image()
% 'Always on top' menu button

img(:,:,1) = [
  255  255  255  255  255  255  255  255  255  255  255  255  255  255  255  255
  255  255  255  255  255  255   50   50   50   50  255  255  255  255  255  255
  255  255  255  255   50   50  203  231  231  203   50   43  255  255  255  255
  255  255  255   50  203  231  231  231  231  231  231  203   43  255  255  255
  255  255   43  203  231  231  231  231  231  231  231  231  203   43  255  255
  255  255   43  231  231  255  255  231  231  231  231  231  231   43  255  255
  255   43  193  231  231  255  231  231  231  231  231  231  231  193   43  255
  255   34  193  231  231  231  157   66   66  157  231  231  231  193   34  255
  255   34  193  231  231  157   75  201   91   66  157  231  231  193   34  255
  255   34  193  193  231   66  157   51   22   91   66  231  193  193   34  255
  255  255   34  193  193   57   91   22   22   91   57  193  193   34  255  255
  255  255   34  193  193  157   57   80   80   57  157  193  193   34  255  255
  255  255  255   28  193  193  157   57   57  157  193  193   28  255  255  255
  255  255  220  220   28   28  193  193  193  193   28   28  220  220  255  255
  255  220  220  220  220  220   28   28   28   28  220  220  220  220  220  255
  255  255  220  220  220  220  220  220  220  220  220  220  220  220  255  255];

img(:,:,2) = [
  255  255  255  255  255  255  255  255  255  255  255  255  255  255  255  255
  255  255  255  255  255  255   85   85   85   85  255  255  255  255  255  255
  255  255  255  255   85   85  203  231  231  203   85   73  255  255  255  255
  255  255  255   85  203  231  231  231  231  231  231  203   73  255  255  255
  255  255   73  203  231  231  231  231  231  231  231  231  203   73  255  255
  255  255   73  231  231  255  255  231  231  231  231  231  231   73  255  255
  255   73  193  231  231  255  231  231  231  231  231  231  231  193   73  255
  255   58  193  231  231  231  184  106  106  184  231  231  231  193   58  255
  255   58  193  231  231  184  120  220  133  106  184  231  231  193   58  255
  255   58  193  193  231  106  184   95   22  133  106  231  193  193   58  255
  255  255   58  193  193   91  133   22   22  133   91  193  193   58  255  255
  255  255   58  193  193  184   91  116  116   91  184  193  193   58  255  255
  255  255  255   47  193  193  184   91   91  184  193  193   47  255  255  255
  255  255  220  220   47   47  193  193  193  193   47   47  220  220  255  255
  255  220  220  220  220  220   47   47   47   47  220  220  220  220  220  255
  255  255  220  220  220  220  220  220  220  220  220  220  220  220  255  255];

img(:,:,3) = [
  255  255  255  255  255  255  255  255  255  255  255  255  255  255  255  255
  255  255  255  255  255  255  115  115  115  115  255  255  255  255  255  255
  255  255  255  255  115  115  210  231  231  210  115   99  255  255  255  255
  255  255  255  115  210  231  231  231  231  231  231  210   99  255  255  255
  255  255   99  210  231  231  231  231  231  231  231  231  210   99  255  255
  255  255   99  231  231  255  255  231  231  231  231  231  231   99  255  255
  255   99  193  231  231  255  231  231  231  231  231  231  231  193   99  255
  255   79  193  231  231  231  207  140  140  207  231  231  231  193   79  255
  255   79  193  231  231  207  158  236  169  140  207  231  231  193   79  255
  255   79  193  193  231  140  207  133   22  169  140  231  193  193   79  255
  255  255   79  193  193  120  169   22   22  169  120  193  193   79  255  255
  255  255   79  193  193  207  120  148  148  120  207  193  193   79  255  255
  255  255  255   64  193  193  207  120  120  207  193  193   64  255  255  255
  255  255  220  220   64   64  193  193  193  193   64   64  220  220  255  255
  255  220  220  220  220  220   64   64   64   64  220  220  220  220  220  255
  255  255  220  220  220  220  220  220  220  220  220  220  220  220  255  255];
img = img/255;

end %<get_AOT_image>

function img = PDF_button_im()
% 'Always on top' menu button

img(:,:,1) = [
  186  129  129  129  129  129  129  129  129  129  129  129  129  213  212  212
  129  212  212  212  212  212  212  212  212  212  212  212  212  129  212  212
  129  212  236  234  234  235  235  235  236  236  237  240  212  129  212  212
  224  224  224  224  224  224  224  224  224  224  224  224  224  224  224  212
  224  212  212  212  224  224  212  212  212  224  224  212  212  212  224  212
  224  212  224  224  224  224  212  224  224  224  224  212  224  224  224  212
  224  224  212  212  224  224  212  224  224  212  224  212  212  224  224  212
  224  212  224  224  224  224  224  224  224  212  224  212  224  224  224  212
  224  212  224  224  224  224  212  212  224  224  224  224  224  224  224  212
  224  224  224  224  224  224  224  224  224  224  224  224  224  224  224  212
  129  212  236  235  235  235  235  235  235  235  235  241  212  129  212  212
  129  212  237  235  235  235  235  235  235  235  235  242  212  129  212  212
  129  212  237  237  238  239  239  240  240  241  242  242  212  129  212  212
  129  212  212  212  212  212  212  212  212  212  212  212  212  129  212  212
  180  129  129  129  129  129  129  129  129  129  129  129  129  185  212  212
  212  212  212  212  212  212  212  212  212  212  212  212  212  212  212  212];

img(:,:,2) = [
  186  129  129  129  129  129  129  129  129  129  129  129  129  213  208  208
  129  208  208  208  208  208  208  208  208  208  208  208  208  129  208  208
  129  208  236  234  234  235  235  235  236  236  237  240  208  129  208  208
   44   44   44   44   44   44   44   44   44   44   44   44   44   44   44  208
   44  208  208  208   44   44  208  208  208   44   44  208  208  208   44  208
   44  208   44   44  230   44  208   44   44  230   44  208   44   44   44  208
   44  230  208  208   44   44  208   44   44  208   44  208  208   44   44  208
   44  208   44   44   44   44  230   44   44  208   44  208   44   44   44  208
   44  208   44   44   44   44  208  208  230   44   44  230   44   44   44  208
   44   44   44   44   44   44   44   44   44   44   44   44   44   44   44  208
  129  208  236  235  235  235  235  235  235  235  235  241  208  129  208  208
  129  208  237  235  235  235  235  235  235  235  235  242  208  129  208  208
  129  208  237  237  238  239  239  240  240  241  242  242  208  129  208  208
  129  208  208  208  208  208  208  208  208  208  208  208  208  129  208  208
  180  129  129  129  129  129  129  129  129  129  129  129  129  185  208  208
  208  208  208  208  208  208  208  208  208  208  208  208  208  208  208  208];

img(:,:,3) = [
  186  129  129  129  129  129  129  129  129  129  129  129  129  213  200  200
  129  200  200  200  200  200  200  200  200  200  200  200  200  129  200  200
  129  200  236  234  234  235  235  235  236  236  237  240  200  129  200  200
   44   44   44   44   44   44   44   44   44   44   44   44   44   44   44  200
   44  200  200  200   44   44  200  200  200   44   44  200  200  200   44  200
   44  200   44   44  231   44  200   44   44  231   44  200   44   44   44  200
   44  231  200  200   44   44  200   44   44  200   44  200  200   44   44  200
   44  200   44   44   44   44  231   44   44  200   44  200   44   44   44  200
   44  200   44   44   44   44  200  200  231   44   44  231   44   44   44  200
   44   44   44   44   44   44   44   44   44   44   44   44   44   44   44  200
  129  200  236  235  235  235  235  235  235  235  235  241  200  129  200  200
  129  200  237  235  235  235  235  235  235  235  235  242  200  129  200  200
  129  200  237  237  238  239  239  240  240  241  242  242  200  129  200  200
  129  200  200  200  200  200  200  200  200  200  200  200  200  129  200  200
  180  129  129  129  129  129  129  129  129  129  129  129  129  185  200  200
  200  200  200  200  200  200  200  200  200  200  200  200  200  200  200  200];
img = img/255;

end %<PDF_button_im>

function img = PPT_button_im()
% Image for the PowerPoint toolbar button

img(:,:,1) = [
    239 240 240 241 240 240 240 240 240 240 239 240 239 240 241 240
    238 232 231 230 235 235 239 240 240 241 240 243 240 241 239 240
    240 228 231 228 230 229 226 231 235 233 237 239 239 241 240 240
    240 237 229 231 230 230 229 229 230 228 230 230 231 237 237 241
    240 240 240 238 238 238 236 234 233 235 232 228 230 230 238 239
    240 239 234 228 230 233 237 239 240 241 239 234 228 230 234 240
    241 242 228 229 227 229 230 241 240 240 240 240 233 229 229 239
    240 237 232 230 228 231 229 237 240 241 240 239 235 230 231 237
    240 242 232 230 228 229 230 235 240 239 239 239 232 230 228 240
    239 240 236 230 229 229 226 235 237 235 228 229 229 230 238 239
    240 239 238 229 230 229 226 234 239 232 230 230 233 239 241 239
    240 241 240 229 230 230 229 229 238 239 240 243 240 240 240 239
    239 241 239 232 229 228 229 228 238 239 241 239 240 241 237 240
    239 240 241 234 229 228 229 231 237 239 242 240 240 239 239 241
    243 239 241 240 235 231 233 233 240 240 236 240 241 241 239 241
    240 240 239 239 240 239 236 240 241 241 239 240 240 240 238 241];

img(:,:,2) = [
    241 232 227 237 242 240 240 240 240 240 241 240 240 240 241 240
    228 161 139 154 176 197 217 230 239 241 240 239 239 239 239 240
    214 129 119 118 118 119 127 141 159 181 203 221 238 240 240 240
    236 188 147 136 127 122 119 117 118 120 120 128 153 204 238 241
    240 240 233 211 202 203 195 178 167 150 136 124 118 125 197 239
    242 238 182 133 133 161 223 239 240 237 232 199 133 118 149 232
    239 225 133 117 119 119 153 232 240 240 240 240 168 117 130 219
    240 230 138 118 118 118 124 212 240 241 240 241 183 118 127 211
    240 238 162 118 118 118 118 190 240 234 226 211 145 118 136 223
    241 240 187 119 117 117 118 166 222 149 133 125 119 122 184 239
    240 241 212 125 118 118 118 148 217 150 141 153 174 204 237 240
    240 240 229 140 117 118 119 130 222 236 231 238 240 240 240 239
    241 241 239 164 118 118 117 122 206 239 239 240 240 240 241 240
    241 240 239 195 121 117 117 127 214 240 240 240 240 240 240 240
    239 240 240 232 173 135 138 188 239 240 240 240 241 240 240 239
    240 240 239 240 239 225 229 239 239 239 241 240 238 240 239 239];

img(:,:,3) = [
    238 229 221 234 241 240 242 240 238 240 240 240 242 238 241 240
    219 109  76 102 136 174 203 221 237 243 240 236 237 240 241 240
    201  61  43  43  42  44  59  81 110 144 178 207 236 238 238 242
    235 156  89  72  60  49  42  43  44  47  45  62 104 185 240 241
    240 242 227 192 178 181 167 141 119  96  75  53  44  57 175 237
    239 236 145  67  65 111 212 237 238 236 226 171  65  42  94 229
    240 217  67  43  46  44 101 225 238 240 238 242 126  41  63 208
    240 224  74  44  41  42  56 192 242 241 240 240 146  44  54 196
    240 239 113  42  43  46  42 159 238 230 217 199  91  42  73 213
    238 240 155  40  41  41  43 124 215  92  69  52  42  50 150 237
    240 240 195  52  44  46  45  91 204  92  81  99 134 185 238 242
    242 238 223  80  41  44  44  63 209 231 226 235 242 242 238 241
    240 241 241 115  39  43  41  48 183 239 240 242 238 238 240 240
    240 240 240 166  46  45  43  56 198 244 241 240 238 242 242 238
    238 242 236 229 134  74  72 157 237 238 239 240 243 238 242 240
    242 238 237 242 237 214 221 237 240 240 238 240 241 238 241 240];
img = img/255;

end %<PPT_button_im>

end %<pushbuttons>