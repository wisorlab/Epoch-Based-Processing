function errorout = myobjectivefunction(signal,t_mdpt_indices,data_at_SWS_midpoints, ...
					datafile,dt,LA,UA,window_length,mask,p)



  if strcmp(signal,'delta1') || strcmp(signal,'delta2')
    Simulation = run_S_model(datafile,dt,(LA(1)+UA(1))/2,LA,UA,p(1),p(2),0,0);
    errorout   = sqrt((sum((Simulation([t_mdpt_indices])-data_at_SWS_midpoints).^2))/length(t_mdpt_indices));
  end
 

  if strcmp(signal,'lactate')
    Simulation = run_S_model(datafile,dt,(LA(1)+UA(1))/2,LA,UA,p(1),p(2),window_length,0);
    size(Simulation)
    size(datafile([mask],2))
    size(datafile,1)

    errorout   = sqrt((sum((Simulation'-datafile([mask],2)).^2))/(size(datafile,1)-(window_length*360)));
  end
