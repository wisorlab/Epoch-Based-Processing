% this function makes a movie of the Nelder-Mead 
% animation
function M=make_NM_animation(xs,ys,error)

% xs is a 3 column matrix of the x values for the 3 
% vertices of the triangle.  Each row corresponds to a 
% step of the NM method. 
% ys is a 3 column matrix of the y values...

figure


% First put the contour plot on there
tau_i=0:.005:0.4;
tau_d=0:.005:0.12;
[X,Y]=meshgrid(tau_d,tau_i);
contour(X,Y,error,50);
hold on



guesses=[0.08 .3;.11 .3;.095 .1];
first_simplex=[guesses;guesses(1,:)];
plot(first_simplex(:,1),first_simplex(:,2),'-kx')
axis([0 0.12 0 0.4])
M(1)=getframe;
pause(3)


for i=1:size(xs,1)
  xsl = [xs(i,:),xs(i,1)];
  ysl = [ys(i,:),ys(i,1)];
  plot(xs(i,:),ys(i,:),'or',xsl,ysl,'-k')
  axis([0 0.12 0 0.4])
  h=plot(xsl,ysl);
  set(h,'color',[0.5 0.5 0.5])
  axis([0 0.12 0 0.4])
  pause(0.7)
M(i+1)=getframe;
end
hold off

movie2avi(M,'NMsearch.avi','fps',2,'quality',90)