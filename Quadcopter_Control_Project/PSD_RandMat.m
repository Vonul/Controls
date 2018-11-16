function matPD = PSD_RandMat(size)
% This function creates a Positive Definite matrix of a given size.

%Param size     : size of symmetric matrix to create

matPD = rand(size,size);

matPD = 0.5*(matPD + transpose(matPD)) + randi(size)*eye(size);

end