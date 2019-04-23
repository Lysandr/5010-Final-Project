%% Padraig Lysandrou April 4th 2019 -- ASEN5010 Final Project
clc; close all; clear all;

% Problem specified dynamic initial conditions
sigma_BN_0 = [0.3 -0.4 0.5].';
omega_BN_B_0 = deg2rad([1 1.75 -2.2]).';
Ic = diag([10 5 7.5]); p.Ic = Ic;

% Problem specified orbital parameters
mu_M =  42828.3;            % km3/s2
h_LMO = 400;                % km 
R_M = 3396.19;              % km 
r_LMO = h_LMO + R_M;
theta_dot_LMO = sqrt(mu_M / (r_LMO^3)); % rad/s, orbital angular rate(circ)
r_GMO = 20424.2;
theta_dot_GMO = sqrt(mu_M / (r_GMO^3)); % rad/s, orbital angular rate(circ)
% theta_dot_GMO = 0.0000709003;

% Take care of timing
tend = 200;
dt = 1;
t = 0:dt:tend;
npoints = length(t);

% Set up the dynamic function as well as state tracking, init conds
f_dot = @(t_in,state_in,param) dynamics(t_in,state_in,param);
vehicle_state = zeros(6,npoints);
vehicle_state(:,1) = [sigma_BN_0; omega_BN_B_0];
p.L = [0.0 0 0].';
p.u = [0 0 0].';

% Setup the tracking error stuff, and input history stuff
sigma_BR = zeros(3,npoints);
omega_BR = zeros(3,npoints);
control_input = zeros(3, npoints);
sig_int = [0 0 0].';

% Set the initial conditions
H = zeros(3,npoints);
H(:,1) = Ic*omega_BN_B_0;
T = zeros(1,npoints);
T(1) = 0.5*omega_BN_B_0.'*Ic*omega_BN_B_0; 

% PD controller gain initialization
P = diag(Ic).*(2/exp(1));
K = max((P.^2)./diag(Ic));



%% Start the simulation
vehicle_mode = 3;

tic
for i = 1:npoints-1
    % Pull out state values to be used below
    sigma_BN = vehicle_state(1:3,i);
    omega_BN = vehicle_state(4:6,i);
    
    % Determine the DCM and omega vectors that we must track
    switch vehicle_mode
        case 1
            RN = dcm_RsN(t(i));
            omega_RN = omega_RsN(t(i));
            [sigma_BR(:,i), omega_BR(:,i)] = ...
                track_error(sigma_BN,omega_BN,RN,omega_RN);
        case 2
            RN = dcm_RnN(t(i));
            omega_RN = omega_RnN(t(i),theta_dot_LMO);
            [sigma_BR(:,i), omega_BR(:,i)] = ...
                track_error(sigma_BN,omega_BN,RN,omega_RN);
        case 3
            RN = dcm_RcN(t(i));
            omega_RN = omega_RcN(t(i));
            [sigma_BR(:,i), omega_BR(:,i)] = ...
                track_error(sigma_BN,omega_BN,RN,omega_RN);
        otherwise
            sigma_BR(:,i) = [0 0 0].';
            omega_BR(:,i) = [0 0 0].';
    end
    
    % Calculate the control input from mode error
    sig_int = sig_int + dt.*(sigma_BR(:,i));
    p.u = (-K.*sigma_BR(:,i)) + (-P.*omega_BR(:,i)); % + -0.01.*sig_int ;
    control_input(:,i) = p.u;

    
    % Pull out the angular momentum and the energy for debugging and
    % verification
    H(:,i) = Ic*omega_BN;
    T(i) = 0.5*omega_BN.'*Ic*omega_BN; 
    
    % RK4 step for the spacecraft dynamics
    k_1 = f_dot(t(i),vehicle_state(:,i),p);
    k_2 = f_dot(t(i)+0.5*dt, vehicle_state(:,i)+0.5*dt*k_1,p);
    k_3 = f_dot((t(i)+0.5*dt),(vehicle_state(:,i)+0.5*dt*k_2), p);
    k_4 = f_dot((t(i)+dt),(vehicle_state(:,i)+k_3*dt), p);
    vehicle_state(:,i+1) = vehicle_state(:,i) + (1/6)*(k_1+(2*k_2)+(2*k_3)+k_4)*dt;
    
    % Perform the nonsingular MRP propagation attitude check
    s = norm(vehicle_state(1:3,i+1));
    if s > 1
        vehicle_state(1:3,i+1) = -(vehicle_state(1:3,i+1) ./(s^2));
    end
end
toc


%% Plot data here.

% figure; plot(t, H); title('angular momentum');
figure; plot(t, vehicle_state(1:3,:)); title('mrps over time')
figure; plot(t, vehicle_state(4:6,:)); title('omegas over time')
% figure; plot(t, vecnorm(H)); title('Angular Momentum over time')

% figure; semilogy(t, T); title('system angular energy over time')
figure; plot(t, sigma_BR); title('MRP tracking error vs time');
figure; plot(t, omega_BR); title('Angular rate tracking error vs time');




% save_to_txt('H500B.txt', H(:,end));
% save_to_txt('T500.txt',T(end));
% save_to_txt('MRP500.txt',vehicle_state(1:3,end));
% save_to_txt('H500N.txt', MRP2C(vehicle_state(1:3,end)).'*H(:,end));


