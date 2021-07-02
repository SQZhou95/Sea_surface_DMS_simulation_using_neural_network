% Simulating DMS concentration and calculating its sea-to-air flux.
% Created by SQ Zhou.

global netS
netS = netSet; % netSet is the cell array containing the neural networks.

DMS_sim = 10.^(mymodel(input)); % the simulated DMS concentration (nM)
% You should substitute x_mean, x_std, t_mean, and t_std if you train a new
% network based on your initial data.

Kt = Kt_DMS(T,U,S).*(1-SI); % Calculating the transfer coefficient of DMS, m/s
% T --> sea surface temperature, U --> 10-m wind speed, S --> sea surface
% salinity, SI --> sea-ice covering fraction

DMS_flux_sim = DMS_sim.*Kt*86400; % DMS flux, unit: μmol S m-2 d-1