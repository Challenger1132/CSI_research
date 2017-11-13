function steervec = util_steering_aoa_tof(aoa,tof,Nrx,ant_dist,fc,Nc,Delta_f)
	steervec = zeros(Nrx*Nc,1);
	Phi = zeros(Nrx,1);
	Omega = zeros(Nc,1);
	lambda = 3e8/fc;
	for i = 1:Nrx
	    Phi(i) = exp(-1j*2*pi*(i-1)*ant_dist*sin(aoa*pi/180)/lambda);
	    for j = 1:Nc
	        Omega(j) = exp(-1j*2*pi*(j-1)*Delta_f*tof);
	        steervec((i-1)*Nc + j) = Phi(i)*Omega(j);
	    end
	end
end

