function fill_between_lines(X,Y1,Y2,C)
%usage: fill_between_lines(X,Y1,Y2,C)
%
% Shade region between 2 curves. 
%
% INPUTS:
% X: x locations of data
% Y1: data for one curve
% Y2: data for the other curve
% C: color (e.g. 'r' or [0.5 0.5 0.5])

fill( [X fliplr(X)], [Y1 fliplr(Y2)], C)

