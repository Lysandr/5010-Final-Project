function om_RcN = omega_RcN(t)
%dcm_RnN returns nadir pointing omega

dt= 0.00001;
RcN_t1 = dcm_RcN(t);
RcN_t2 = dcm_RcN(t+dt);

dRcN = (RcN_t2 - RcN_t1)./dt;
skew_omega = -dRcN/RcN_t1;
omega_RcN = deskew(skew_omega);
om_RcN = RcN_t1.'*omega_RcN;
end

