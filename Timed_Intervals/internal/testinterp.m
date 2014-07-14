% This is a little test script to test interpolation of a lactate signal
% after calling edfread.m 

% Since different signals may have been read at different frequencies, I need 
% to interpolate those that are sampled at a lower frequency than the highest frequency


% Find the largest values in header.samples (this is the number of samples per 'duration' seconds)
max_samples_per_epoch = max(header.samples(1:4));   %I'm leaving off EDFAnnotations because I don't care about interpolate
scale_factor = ones(1,4);

for i=1:4
	if header.samples(i) ~= max_samples_per_epoch
		scale_factor(i) = max_samples_per_epoch/header.samples(i);
	end 
end 

num_of_vars_to_scale = sum(scale_factor~=1);
indices = find(scale_factor~=1);

% Now loop over all the variables that need scaling
for i=1:num_of_vars_to_scale 
	clear a,X,Xq,V 
	a = find(record(indices(i),:)==0);
	first_zero_loc = a(1);
	X = 0:1:first_zero_loc-2;
	V = record(1,1:first_zero_loc-1);
	Xq = 0:1/scale_factor(indices(i)):first_zero_loc-1;
	Xq=Xq(1:end-1);
	newlactatevec = interp1(X,V,Xq);
	size(newlactatevec)
	size(record)
	record(indices(i),:) = newlactatevec;
end

