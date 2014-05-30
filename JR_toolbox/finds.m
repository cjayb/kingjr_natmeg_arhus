function [index x] = finds(data,field,value)
% finds indexes of in a structured data:
% [index x] = finds(data,field,value)

if isstr(value)
    cdata = struct2cell(data);
    cdata = squeeze(cdata(strcmp(fieldnames(data    ), field),:,:));
    index =  find(strcmp(cdata,value));
%     eval(['[x index] = find(strcmp([data.' field '],value)==1);']);
elseif isnumeric(value)
    if length(eval(['[data.' field ']'])) ~= length(data)
        warning('missing values!')
        for t = length(data)
            if not(isfield(data(t), field))
                eval(['data(t). ' field '=[];']);
            end
        end
    end
    eval(['[x index] = find([data.' field ']==value);']);
end
end