function RnN = dcm_RnN(t)
%dcm_RnN returns nadir pointing dcm

%RN is transforming R into N
% need DCM that transforms 
RH = [-1 0 0; 0 1 0; 0 0 -1];
HN = dcm_HN(t);
RnN = RH*HN;

end

