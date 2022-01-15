% The following are the parameters for the network between my home and
% office.
nextsampletime = 35.5e-3/2; %initial delay value; set to mean RTT/2
oldoutput = 0; %initial value
amplitude = 0.006;
sigma = 1.22061;
mu = -2.4380872433823235;
offset = 0.0328;
sampleinterval = 0.05; %must be a multiple of integration time step
sampleindex = 0; %initial value
delay = nextsampletime; %initial value
quantizationinterval = 4e-3; %should be equal to the integration time step