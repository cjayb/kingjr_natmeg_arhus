function export_fig(fname)
% simple wrapper to export figure to file, assume extension given

[pth,fil,ext] = fileparts(fname);

switch ext(2:end)
    case 'png'
        print('-dpng', fname)
end

