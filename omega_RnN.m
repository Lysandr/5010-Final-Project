function RnN = omega_RnN(t,omega)
%dcm_RnN returns nadir pointing omega

omega = [0 0 omega].';
HN = dcm_HN(t);
RnN = HN.'*omega;
end

