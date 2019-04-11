%% Padraig Lysandrou April 4th 2019 -- ASEN5010 Final Project
clc;
close all;
clear all;

sigma_BN_0 = [0.3 -0.4 0.5].';
omega_BN_0 = rad2deg([1 1.75 -2.2]).';
Ic = diag([10 5 7.5]);

mu =  42828.3;            % km3/s2
h_LMO = 400;                % km 
R_M = 3397.2;              % km 
r_LMO = h_LMO + R_M;
theta_dot_LMO = sqrt(mu / (r_LMO^3)); % rad/s, orbital angular rate(circ)

r_GMO = 20424.2;
theta_dot_GMO = sqrt(mu / (r_GMO^3)); % rad/s, orbital angular rate(circ)
theta_dot_GMO = 0.0000709003;

% Let us test the first task
Omega_LMO = deg2rad(20);
inc_LMO = deg2rad(30);
theta_LMO_0 = deg2rad(60) + 450*theta_dot_LMO;
[rN,vN] = oe2rv_schaub(r_LMO,mu,Omega_LMO,inc_LMO,theta_LMO_0);
save_to_txt('rN_1.txt',rN)
save_to_txt('vN_1.txt',vN)

Omega_GMO = 0;
inc_GMO = 0;
theta_GMO_0 = deg2rad(250) + 1150*theta_dot_GMO;
[rN,vN] = oe2rv_schaub(r_GMO,mu,Omega_GMO,inc_GMO,theta_GMO_0);
save_to_txt('rN_2.txt',rN)
save_to_txt('vN_2.txt',vN)

% let us test the second task:
HN = dcm_HN(300);
save_to_txt('HN.txt',reshape(HN.',[1,9]))


% let us test the third task: this was super dumb
% this DCM transforms a vector in N to one in R
RsN = [-1 0 0;0 0 1; 0 1 0].';
omega_RsN = [0 0 0].';
save_to_txt('RsN.txt',reshape(RsN.',[1,9]))
save_to_txt('omega_RsN.txt',omega_RsN)

% let us test the fourth task: Nadir pointing
RnN = dcm_RnN(330);
save_to_txt('RnN.txt',reshape(RnN.',[1,9]))
omega_RnN = omega_RnN(330,theta_dot_LMO);
save_to_txt('omega_RnN.txt',omega_RnN)



























