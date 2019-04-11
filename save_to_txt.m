function save_to_txt(name_string,var)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

fileID = fopen(name_string,'w');
fprintf(fileID,'%10.8f',var(1));
fprintf(fileID,' %10.8f',var(2:end));
fclose(fileID);
disp("saved to " + name_string)
end

