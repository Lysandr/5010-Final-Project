%% Padraig Lysandrou April 4th 2019 -- ASEN5010 Final Project
clc; close all; clear all;

sigma_BN_0 = [0.3 -0.4 0.5].';
omega_BN_0 = [1 1.75 -2.2].';
Ic = diag([10 5 7.5]);

mu_M =  42828.3;            % km3/s2
h_LMO = 400;                % km 
R_M = 3397.2;              % km 
r_LMO = h_LMO + R_M;
theta_dot_LMO = sqrt(mu_M / (r_LMO^3)); % rad/s, orbital angular rate(circ)

r_GMO = 20424.2;
theta_dot_GMO = sqrt(mu_M / (r_GMO^3)); % rad/s, orbital angular rate(circ)

