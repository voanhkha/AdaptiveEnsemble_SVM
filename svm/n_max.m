function [score, index] = n_max(x, n)
% find the n^th max of x and return the score as well as the index

sorted_x = sort(x,'descend');

score = sorted_x(n);
index = find(x==score);