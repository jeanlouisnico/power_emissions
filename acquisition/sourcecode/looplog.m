function looplog(msgin)
% yourMsg = 'I am alive.'

p = mfilename('fullpath') ;
[filepath,~,~] = fileparts(p) ;
fparts = split(filepath, filesep) ;
fparts = join(fparts(1:end), filesep) ;

% save([fparts{1} filesep 'database' filesep 'data_input.mat'],'data_input');


fid = fopen(fullfile(fparts{1}, 'fetcher.log'), 'a');
if fid == -1
  error('Cannot open log file.');
end
fprintf(fid, '%s: %s\n', char(datetime('now')), msgin);
fclose(fid);