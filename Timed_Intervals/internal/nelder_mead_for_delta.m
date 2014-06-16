function [best_tau_i,best_tau_d,best_error,P] = nelder_mead_for_delta(V,min1,max1,epsilon,show,...
                                                  datafile,dt,LA,UA,t_mdpt_indices,data_at_SWS_midpoints)
%---------------------------------------------------------------------------
%NELDER   Nelder-Mead method to search for a minimum.
% Sample call
%   [V0,y0,dV,dy,P,Q] = nelder('Fn',V,min1,max1,epsilon,1)
% Inputs
%   Fn        name of the vector function
%   V         starting simplex (3 rows, 2 columns)
%   min1      minimum number of iterations
%   max1      maximum number of iterations
%   epsilon   convergence tolerance
%   show      if show==1 the iterations are displayed
% Return
%   V0        vertex V0 for the minimum
%   y0        function value  Fn(V0)
%   dV        size of the final simplex
%   dy        error bound for the minimum
%   P         matrix containing the vertices in the iterations
%   Q         array containing iterations for  F(P)
%
% NUMERICAL METHODS: MATLAB Programs, (c) John H. Mathews 1995
% To accompany the text:
% NUMERICAL METHODS for Mathematics, Science and Engineering, 2nd Ed, 1992
% Prentice Hall, Englewood Cliffs, New Jersey, 07632, U.S.A.
% Prentice Hall, Inc.; USA, Canada, Mexico ISBN 0-13-624990-6
% Prentice Hall, International Editions:   ISBN 0-13-625047-5
% This free software is compliments of the author.
% E-mail address:      in%"mathews@fullerton.edu"
%
% Algorithm 8.2 (Nelder-Mead's Minimization Method).
% Section	8.1, Minimization of a Function, Page 414
% 
% modified by me to use my functions instead of feval
% may want to add constraints to this so only positive 
% values are allowed. (it doesn't make sense to have a negative 
% time constant)
%---------------------------------------------------------------------------

%if nargin==5, show = 0; end
if show==1,
  figure
  Mx1 = 'Nelder-Mead search iteration No. ';
  Mx2 = '     p                  q                  f(p,q)';
  clc;
  diary output,disp(' '),disp(' '),....
      disp(Mx1),disp(Mx2),disp(' '),diary off;
end
[mm n] = size(V);
for j =1:n+1,
  Z = V(j,1:n);
      Simulation=run_S_model(datafile,dt,(LA(1)+UA(1))/2,LA,UA,Z(2),Z(1),0,0);% run model
      Y(j)=sqrt((sum((Simulation([t_mdpt_indices])-data_at_SWS_midpoints).^2))/length(t_mdpt_indices)); %RMSE
 end
[mm lo] = min(Y);            % Order the vertices:
[mm hi] = max(Y);
li = hi;
ho = lo;
for j = 1:n+1,
  if (j~=lo & j~=hi & Y(j)<=Y(li)), li=j; end
  if (j~=hi & j~=lo & Y(j)>=Y(ho)), ho=j; end
end                          % End of Order.

iterate=1;
cnt = 0;
while (Y(hi)>Y(lo)+epsilon & cnt<max1) | cnt<min1
% The main while loop has started.
  S = zeros(1,n);          % Form the new points:
  for j = 1:n+1,
    S = S + V(j,1:n);
  end
  M = (S - V(hi,1:n))/n;     % Construct vertex M:
  R = 2*M - V(hi,1:n);       % Construct vertex R:
  %yR = feval(Fn,R);
  Simulation=run_S_model(datafile,dt,(LA(1)+UA(1))/2,LA,UA,R(2), ...
                         R(1),0,0);% run model
  yR=sqrt((sum((Simulation([t_mdpt_indices])-data_at_SWS_midpoints).^2))/length(t_mdpt_indices));
  if (yR<Y(ho)),
    if (Y(li)<yR),
      V(hi,1:n) = R;         % Replace a vertex:
      Y(hi) = yR;
    else
      E = 2*R - M;           % Construct vertex E:
      %yE = feval(Fn,E);
      Simulation=run_S_model(datafile,dt,(LA(1)+UA(1))/2,LA,UA,E(2), ...
                         E(1),0,0);% run model
      yE=sqrt((sum((Simulation([t_mdpt_indices])-data_at_SWS_midpoints).^2))/length(t_mdpt_indices));
      if (yE<Y(li)),
        V(hi,1:n) = E;       % Replace a vertex:
        Y(hi) = yE;
      else
        V(hi,1:n) = R;       % Replace a vertex:
        Y(hi) = yR;
      end
    end
  else
    if (yR<Y(hi)),
      V(hi,1:n) = R;         % Replace a vertex:
      Y(hi) = yR;
    end
    C = (V(hi,1:n)+M)/2;     % Construct vertex C:
    %yC = feval(Fn,C);
    Simulation=run_S_model(datafile,dt,(LA(1)+UA(1))/2,LA,UA,C(2), ...
                         C(1),0,0);% run model
    yC=sqrt((sum((Simulation([t_mdpt_indices])-data_at_SWS_midpoints).^2))/length(t_mdpt_indices));
    C2 = (M+R)/2;            % Construct vertex C2:
    %yC2 = feval(Fn,C2);
    Simulation=run_S_model(datafile,dt,(LA(1)+UA(1))/2,LA,UA,C2(2), ...
                         C2(1),0,0);% run model
    yC2=sqrt((sum((Simulation([t_mdpt_indices])-data_at_SWS_midpoints).^2))/length(t_mdpt_indices));
    if (yC2<yC),
      C = C2;                % Replace a vertex:
      yC = yC2;
    end
    if (yC<Y(hi)),
      V(hi,1:n) = C;         % Replace a vertex:
      Y(hi) = yC;
    else
      for j = 1:n+1,         % Shrink the simplex:
        if (j~=lo),
          V(j,1:n) = (V(j,1:n)+V(lo,1:n))/2;
          Z = V(j,1:n);
    %      Y(j) = feval(Fn,Z);
    Simulation=run_S_model(datafile,dt,(LA(1)+UA(1))/2,LA,UA,Z(2), ...
                           Z(1),0,0);% run model
    Y(j)=sqrt((sum((Simulation([t_mdpt_indices])-data_at_SWS_midpoints).^2))/length(t_mdpt_indices));
        end
      end                    % End of Shrink.
    end
  end                        % End of Improve.
  [mm lo] = min(Y);          % Order the vertices:
  [mm hi] = max(Y);
  li = hi;
  ho = lo;
  for j = 1:n+1,
    if (j~=lo & j~=hi & Y(j)<=Y(li)), li=j; end
    if (j~=hi & j~=lo & Y(j)>=Y(ho)), ho=j; end
  end                        % End of Order.
  cnt = cnt+1;
  P(cnt,:) = V(lo,:);
  Q(cnt) = Y(lo);
  format long;               % Print iteration and plot 2-dim case.
  if show==1,
   
    diary output,disp([V(lo,:),Y(lo)]),diary off;
    XS(iterate,:) = V(1:n+1,1)'; XSL = [XS(iterate,:),XS(iterate,1)];
    YS(iterate,:) = V(1:n+1,2)'; YSL = [YS(iterate,:),YS(iterate,1)];
	hold on;

plot(XS,YS,'or',XSL,YSL,'-g');
	hold off;
	figure(gcf);
  end;
iterate=iterate+1;
end                          % End of the main while loop.
hold off;
snorm = 0;                   % Determine the size of the simplex:
for j = 1:n+1,
  s = norm(V(j)-V(lo));
  if (s>=snorm), snorm = s; end
end
Q = Q';
V0 = V(lo,1:n);
best_tau_d=V(lo,1);
best_tau_i=V(lo,2);
best_error = Y(lo);
dV = snorm;
dy = abs(Y(hi)-Y(lo));
size(V)
size(XS)
size(XSL)
