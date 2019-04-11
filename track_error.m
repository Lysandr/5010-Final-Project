function [sigma_BR, omega_BR] = track_error(sigma_BN,omega_BN,RN,omega_RN)
%track_error return attitude and angular rate tracking error

% first tackle the error in attitude...
% sigma_RN = C2MRP(RN);
% sigma_BR = relMRP(sigma_BN.', sigma_RN.');
BN = MRP2C(sigma_BN);
sigma_BR = C2MRP(BN*(RN.'));
omega_BR = (omega_BN - BN*omega_RN);
end

