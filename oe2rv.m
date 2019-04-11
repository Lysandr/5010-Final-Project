function [rN,vN] = oe2rv(r,Omega,incl,theta)
%oe2rv Takes simple Euler angle orbital elements and outputs inertial r and
%rdot

    R3_omega = [ cos(theta)  sin(theta)  0 
                -sin(theta)  cos(theta)  0
                0       0     1];
    R3_Omega = [ cos(Omega)  sin(Omega)  0
                -sin(Omega)  cos(Omega)  0
                 0        0     1];
    R1_inc = [1       0          0
            0   cos(incl)  sin(incl)
            0  -sin(incl)  cos(incl)];
        
    perif_to_ECI = (R3_omega*R1_inc*R3_Omega).';
    rN =  perif_to_ECI*([r 0 0].');
    vN = 
    
end

