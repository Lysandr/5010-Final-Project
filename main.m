%% Padraig Lysandrou April 4th 2019 -- ASEN5010 Final Project
clc; close all; clear all;

sigma_BN_0 = [0.3 -0.4 0.5].';
omega_BN_B_0 = deg2rad([1 1.75 -2.2]).';
Ic = diag([10 5 7.5]); p.Ic = Ic;

mu_M =  42828.3;            % km3/s2
h_LMO = 400;                % km 
R_M = 3397.2;              % km 
r_LMO = h_LMO + R_M;
theta_dot_LMO = sqrt(mu_M / (r_LMO^3)); % rad/s, orbital angular rate(circ)

r_GMO = 20424.2;
theta_dot_GMO = sqrt(mu_M / (r_GMO^3)) % rad/s, orbital angular rate(circ)
theta_dot_GMO = 0.0000709003;

tend = 500;
% tend = 100;

dt = 1;
t = 0:dt:tend;
npoints = length(t);
f_dot = @(t_in,state_in,param) dynamics(t_in,state_in,param);
vehicle_state = zeros(6,npoints);
vehicle_state(:,1) = [sigma_BN_0; omega_BN_B_0];
p.L = [0 0 0].';
% p.L = [0.01 -0.01 0.02].';


H = zeros(3,npoints);
H(:,1) = Ic*omega_BN_B_0;
T = zeros(1,npoints);
T(1) = 0.5*omega_BN_B_0.'*Ic*omega_BN_B_0; 

tic
for i = 1:npoints-1
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
    
    sigma_BN = vehicle_state(1:3,i+1);
    omega_BN = vehicle_state(4:6,i+1);
    
    H(:,i+1) = Ic*omega_BN;
    T(i+1) = 0.5*omega_BN.'*Ic*omega_BN; 
end
toc


figure; plot(t, H); title('angular momentum');
figure; plot(t, vehicle_state(1:3,:)); title('mrps over time')
figure; plot(t, vehicle_state(4:6,:)); title('omegas over time')
figure; plot(t, vecnorm(H)); title('H norm over time')
save_to_txt('H500B.txt', H(:,end));

figure; semilogy(t, T);
save_to_txt('T500.txt',T(end));

save_to_txt('MRP500.txt',vehicle_state(1:3,end));
% I think this is just the hill frame...
save_to_txt('H500N.txt', MRP2C(vehicle_state(1:3,end)).'*H(:,end));

if tend == 100
    save_to_txt('MRP100u.txt',vehicle_state(1:3,end));
end



