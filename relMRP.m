function [relset] = relMRP(set1,set2)

set1nmsq = set1 * set1.';
set2nmsq = set2 * set2.';

relset = ((1-set1nmsq).*set1 -(1-set2nmsq).*set2 + cross(2.*set1, set2))...
    ./(1+ set1nmsq*set2nmsq + dot(2*set2, set1));

if norm(relset) > 1
    nmsq = relset * relset.';
   relset = [-relset(1)/nmsq -relset(2)/nmsq -relset(3)/nmsq];
end

end

