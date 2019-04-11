%% Padraig Lysandrou April 4th 2019 -- ASEN5010 Final Project
clc;
close all;
clear all;

mu =  42828.3;            % km3/s2
h_LMO = 400;                % km 
R_M = 3397.2;              % km 
r_LMO = h_LMO + R_M;
theta_dot_LMO = sqrt(mu / (r_LMO^3)); % rad/s, orbital angular rate(circ)



% t= 330;
% RcN = dcm_RcN(t);
% omegaRcN = omega_RcN(t);
% save_to_txt('RcN.txt',reshape(RcN.',[1,9]))
% save_to_txt('omega_RcN.txt',omegaRcN)


%% task 6 do rekative frame work
% clear all;
sigma_BN_0 = [0.3 -0.4 0.5].';
omega_BN_0 = deg2rad([1 1.75 -2.2]).';
t=0;

RsN = dcm_RsN(t);
omegaRsN = omega_RsN(t);
[sigma_BR, omega_BR] = track_error(sigma_BN_0,omega_BN_0, RsN,omegaRsN);
save_to_txt('sigma_BRs.txt',sigma_BR);
save_to_txt('omega_BRs.txt',omega_BR);

omega = theta_dot_LMO;
RnN = dcm_RnN(t);
omegaRnN = omega_RnN(t,omega);
[sigma_BR, omega_BR] = track_error(sigma_BN_0,omega_BN_0, RnN,omegaRnN);
save_to_txt('sigma_BRn.txt',sigma_BR);
save_to_txt('omega_BRn.txt',omega_BR);

RcN = dcm_RcN(t);
omegaRcN = omega_RcN(t);
[sigma_BR, omega_BR] = track_error(sigma_BN_0,omega_BN_0, RcN,omegaRcN);
save_to_txt('sigma_BRc.txt',sigma_BR);
save_to_txt('omega_BRc.txt',omega_BR);


omega_BRc = omega_BR









