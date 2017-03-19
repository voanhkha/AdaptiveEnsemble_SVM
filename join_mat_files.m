%% join_mat_files: 
% Author: Kha Vo.
% Date: March 2017.
% Usage: join all variables x and y in "dir/files", then save to 'filesave'
% Input: dir = directory to files, files = files listed in cells
% Output: save 'filesave' (with variable x and y) into disk

function join_mat_files(dir, files, filesave)

x_concat = []; y_concat = [];

for i = 1:length(files)
    load([dir files{i}])
    x_concat = [x_concat; x];
    y_concat = [y_concat; y];
end
x = x_concat; y = y_concat;
  save(filesave , 'x', 'y')
end
