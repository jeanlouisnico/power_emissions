function eq_ = simplify(eq_)
%
% Drops redundant brackets from a string expression (used for derivatives)
%

%
% >> Project Dyn:Ammo - EUROSTAT module, release 2019-Jan-30
% >> Written by: Jakub Rysanek
%

% keyboard;

%% Bracket profile <stolen from brackets_earthquake>
br = dynammo.symbdiff.brackets_profile(eq_);

%% Collapse redundant brackets <stolen from brackets_earthquake>
% -> Matlab by default allows nested brackets up to level 32 

% if max(br)>30 % 32 is the limit, we want to keep it safe at a lower level
    
    br_tmp = [0;br];
    diffs = br_tmp(2:end)-br_tmp(1:end-1);

    % Increments
    cands = (diffs==1);
    %cands3 = (diffs==-1);
    cands_tmp = [0;cands];
    diffs_up = ( cands_tmp(2:end)+cands_tmp(1:end-1)==2 );

    % Decrements
    cands2 = (flipud(diffs)==-1);
    cands_tmp2 = [0;cands2];
    diffs_down = flipud( cands_tmp2(2:end)+cands_tmp2(1:end-1)==2 );

    % Result
    %[br diffs diffs_up diffs_down cands]

    if any(diffs_up) && any(diffs_down) % We search for two consecutive nested brackets
       to_keep = true(size(diffs_up));
       up_pool = find(diffs_up); 
       for ii = 1:length(up_pool)
            levelnow = br(up_pool(ii));
            down_cand = find(br(up_pool(ii):end)==(levelnow-1),1,'first')+up_pool(ii)-1;
            if diffs_down(down_cand)==1
                to_keep([up_pool(ii);down_cand],1) = false;
                %[br diffs_up diffs_down to_keep]
            end
       end
       eq_ = eq_(to_keep);
       
    end

% end

end %<eof>