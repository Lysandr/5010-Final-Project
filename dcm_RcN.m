function RcN = dcm_RcN(t)
%dcm_RcN outputs reference DCM for pointing at GMO satellite
%   Detailed explanation goes here

mu =  42828.3;            % km3/s2
h_LMO = 400;                % km 
R_M = 3397.2;              % km 
r_LMO = h_LMO + R_M;
theta_dot_LMO = sqrt(mu / (r_LMO^3)); % rad/s, orbital angular rate(circ)
r_GMO = 20424.2;
theta_dot_GMO = 0.0000709003;

% Let us test the first task
Omega_LMO = deg2rad(20);
inc_LMO = deg2rad(30);
theta_LMO_0 = deg2rad(60) + t*theta_dot_LMO;
Omega_GMO = 0;
inc_GMO = 0;
theta_GMO_0 = deg2rad(250) + t*theta_dot_GMO;
[rN_LMO,~] = oe2rv_schaub(r_LMO,mu,Omega_LMO,inc_LMO,theta_LMO_0);
[rN_GMO,~] = oe2rv_schaub(r_GMO,mu,Omega_GMO,inc_GMO,theta_GMO_0);

% let us test the fifth task: GMO pointing shit
delta_r = rN_GMO - rN_LMO;
r1 = -delta_r./norm(delta_r);
r2 = (skew(delta_r)*[0 0 1].')./norm((skew(delta_r)*[0 0 1].'));
r3 = skew(r1)*r2;

RcN = [r1 r2 r3].';

end

