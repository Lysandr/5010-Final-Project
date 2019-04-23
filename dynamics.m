function f_x = dynamics(~,state_in,p)
%%This function defines all of the system dynamics
    % pull out struct constants
    Ic = p.Ic;
    
    % distribute the states for use! these are row vectors.
    sigma_BN =  state_in(1:3);
    omega_BN =  state_in(4:6);

    % MRP integration, remember to perform norm check on this badboi: 3X1
    sigma_dot = (0.25.*((1 -(sigma_BN.'*sigma_BN))*eye(3) + 2*skew(sigma_BN.') ...
        + (2*sigma_BN*(sigma_BN.'))))*omega_BN;
    
    % Angular Rate Integration
    omega_dot = Ic\((-skew(omega_BN)*(Ic*omega_BN)) + p.L + p.u);
    
    % Send out the derivative
    f_x = [sigma_dot.' omega_dot.'].'; 
end
