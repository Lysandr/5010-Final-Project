function HN = dcm_HN(t)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
mu =  42828.3;            % km3/s2
h_LMO = 400;                % km 
R_M = 3397.2;              % km 
r_LMO = h_LMO + R_M;
theta_dot_LMO = sqrt(mu / (r_LMO^3)); % rad/s, orbital angular rate(circ)
Omega_LMO = deg2rad(20);
inc_LMO = deg2rad(30);
theta_LMO_0 = deg2rad(60) + t*theta_dot_LMO;
[rN,vN] = oe2rv_schaub(r_LMO,mu,Omega_LMO,inc_LMO,theta_LMO_0);

ir = rN./norm(rN);
ih = (skew(rN)*vN)./norm(skew(rN)*vN);
itheta = skew(ih)*ir;
HN = [ir itheta ih].';
end

