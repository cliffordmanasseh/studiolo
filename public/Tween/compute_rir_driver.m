% script to generate audio file for compute_rir function

% define inputs
sourceX = 3; sourceY = 2; sourceZ = 1;
receiverX = 3; receiverY = 3; receiverZ = 1;
azimuth = 0; elevation = -90;
scaleFactor = 6;

roomX = 6; roomY = 6; roomZ = 3;
% coef1 = 0.0001; coef2 = 0.0001; coef3 = 0.0001; coef4 = 0.0001; coef5 = 0.0001; coef6 = 0.0001;
coef1 = 0.07; coef2 = 0.1; coef3 = 0.1; coef4 = 0.1; coef5 = 0.06; coef6 = 0.04;

% source x,y,z, receiver x,y,z, azimuth, elevation
% rotate and scale
binauralRir = compute_rir(sourceX,sourceY,sourceZ,receiverX,receiverY,receiverZ,azimuth,elevation,roomX,roomY,roomZ,coef1,coef2,coef3,coef4,coef5,coef6)' * scaleFactor;

%{
binauralRirLeft = binauralRir(1,:);
binauralRirRight = binauralRir(2,:);
%}

% figure, plot(binauralRir);
audiowrite("~/Desktop/genBinauralRir.wav", binauralRir, 44100);
