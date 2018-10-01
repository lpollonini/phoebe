%%
files = dir;

%%
for n=1:size(files)
    
    if length(files(n).name) > 3 && ...
            strcmp(files(n).name(1:3), 'lsl') && ...
            strcmp (files(n).name(end-1:end), '.c')
        mex(files(n).name)
    end
end