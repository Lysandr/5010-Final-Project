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
r_GMO = 20424.2;
Omega_GMO = 0; inc_GMO = 0; theta_GMO_0 = deg2rad(250);
Omega_LMO = deg2rad(20); inc_LMO = deg2rad(30); theta_LMO_0 = deg2rad(60);
theta_dot_LMO = sqrt(mu_M / (r_LMO^3)); % rad/s, orbital angular rate(circ)
theta_dot_GMO = sqrt(mu_M / (r_GMO^3)); % rad/s, orbital angular rate(circ)

% theta_dot_GMO = 0.0000709003;

% Take care of timing
tend = 6500;
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
P = max(diag(Ic).*(2/120));
K = (P^2)./Ic(2,2); % still not sure why this is the gain he wants...

% xi_1 = sqrt((P^2)./(K.*Ic(1,1))) % keeps <=1
% xi_2 = sqrt((P^2)./(K.*Ic(2,2))) % does not keep <= 1
% xi_3 = sqrt((P^2)./(K.*Ic(3,3))) % does not keep <= 1


%% Start the simulation
vehicle_mode = 4;

tic
for i = 1:npoints-1
    % Pull out state values to be used below
    sigma_BN = vehicle_state(1:3,i);
    omega_BN = vehicle_state(4:6,i);
    
    % Determine the inertial small sat and GMO vectors
    theta_LMO = theta_LMO_0 + t(i)*theta_dot_LMO;
    [rN_LMO,~] = oe2rv_schaub(r_LMO,mu_M,Omega_LMO,inc_LMO,theta_LMO);
    theta_GMO = theta_GMO_0 + t(i)*theta_dot_GMO;
    [rN_GMO,~] = oe2rv_schaub(r_GMO,mu_M,Omega_GMO,inc_GMO,theta_GMO);
    
    % Determine the mode of the spacecraft
    if rN_LMO(2)>=0
        vehicle_mode = 1;
    elseif acosd((rN_LMO.'*rN_GMO)/(norm(rN_LMO)*norm(rN_GMO))) < 35
        % put the system into GMO data transfer mode
        vehicle_mode = 3;
    else
        % put the system into nadir point science mode
        vehicle_mode = 2;
    end
    
    
    % Determine the trackgin DCM/Omega based on vehicle mode
    switch vehicle_mode
        case 1      % Sun pointing energy gather mode
            RN = dcm_RsN(t(i));
            omega_RN = omega_RsN(t(i));
            [sigma_BR(:,i), omega_BR(:,i)] = ...
                track_error(sigma_BN,omega_BN,RN,omega_RN);
        case 2      % Nadir pointing science mode
            RN = dcm_RnN(t(i));
            omega_RN = omega_RnN(t(i),theta_dot_LMO);
            [sigma_BR(:,i), omega_BR(:,i)] = ...
                track_error(sigma_BN,omega_BN,RN,omega_RN);
        case 3      % GMO comm pointing mode
            RN = dcm_RcN(t(i));
            omega_RN = omega_RcN(t(i));
            [sigma_BR(:,i), omega_BR(:,i)] = ...
                track_error(sigma_BN,omega_BN,RN,omega_RN);
        case 4      % Safemode hold
            sigma_BR(:,i) = [0 0 0].';
            omega_BR(:,i) = [0 0 0].';
        otherwise   % Safemode hold
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



% Saving things for Checkoff 7
% save_to_txt('H500B.txt', H(:,end));
% save_to_txt('T500.txt',T(end));
% save_to_txt('MRP500.txt',vehicle_state(1:3,end));
% save_to_txt('H500N.txt', MRP2C(vehicle_state(1:3,end)).'*H(:,end));

% close all;
% Saving things for Checkoff 8-10:
% save_to_txt('gains.txt', [P K]);
% save_to_txt('MRP15.txt', vehicle_state(1:3,16));
% save_to_txt('MRP100.txt', vehicle_state(1:3,101));
% save_to_txt('MRP200.txt', vehicle_state(1:3,201));
% save_to_txt('MRP400.txt', vehicle_state(1:3,401));

% close all;
% Saving things for Checkoff 11:
% save_to_txt('MRP300.txt', vehicle_state(1:3,301));
% save_to_txt('MRP2100.txt', vehicle_state(1:3,2101));
% save_to_txt('MRP3400.txt', vehicle_state(1:3,3401));
% save_to_txt('MRP4400.txt', vehicle_state(1:3,4401));
% save_to_txt('MRP5600.txt', vehicle_state(1:3,5601));


































