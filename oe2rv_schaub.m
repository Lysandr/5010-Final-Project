function [rN,vN] = oe2rv_schaub(r,mu,Omega,incl,theta)
%oe2rv JUST FOR THIS PROJECT: NOT ROBUST FOR ANYTHING
    R3_omega = [ cos(theta)  sin(theta)  0 
                -sin(theta)  cos(theta)  0
                0       0     1];
    R3_Omega = [ cos(Omega)  sin(Omega)  0
                -sin(Omega)  cos(Omega)  0
                 0        0     1];
    R1_inc = [1       0          0
            0   cos(incl)  sin(incl)
            0  -sin(incl)  cos(incl)];
    % Take perifocal coordinates and transform to ECI coords
    perif_to_ECI = (R3_omega*R1_inc*R3_Omega).';
    rN =  perif_to_ECI*([r 0 0].');
    % This is an angular rate that only works for circular orbits:
    % basically just mean motion
    n = sqrt(mu/r^3);
    vN = perif_to_ECI* ([0 r*n 0].');
end
 
