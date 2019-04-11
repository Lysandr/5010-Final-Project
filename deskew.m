function output_vec = deskew(mat)
%Creates vector from the skew symmetric construction


% skewed = [0 -mat(3) mat(2); mat(3) 0 -mat(1); -mat(2) mat(1) 0];
    output_vec = [mat(3,2) mat(1,3) mat(2,1)].';
end