function setscripts(scripts)
% cfg = setscripts(scripts)
% write scripts gathered with getscripts
% JeanRémi King, jeanremi.king@gmail.com

%-- read all script in folder
files = fieldnames(scripts);
for f = 1:length(files) 
    if ~strcmp(files{f}, 'path') && ~strcmp(files{f}, 'filetype')
        fid = fopen([files{f} scripts.filetype(2:end) ], 'w');
        eval(['fwrite(fid,scripts.' files{f} ');']);
        fclose(fid);
    end
end
