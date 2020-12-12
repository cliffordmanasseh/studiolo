function [binauralRir] = compute_rir(sourceX,sourceY,sourceZ,receiverX,receiverY,receiverZ,azimuth,elevation,roomX,roomY,roomZ,coef1,coef2,coef3,coef4,coef5,coef6)
% COMPUTE_RIR
%   returns brir given parameters
%   uses lehmann fast image source method algorithm
%   and applies interpolated HRTF using VBAP

% Compute the fast RIR
Fs = 44100;
Delta_dB = 50;          % in dB, determines the length of the resulting RIRs
                        % (RIRs simulated until energy decays by Delta_dB).
Diffuse_dB = 20;        % usually between 8 and 20 dB
T60 = 1.0;              % reverb time, example between 0.2s and 0.6s, 0 has no reverb, T60 or T20

weights = [coef1 coef2 coef3 coef4 coef5 coef6];

room = [roomX, roomY, roomZ];               % room dimensions
X_src = [sourceX, sourceY, sourceZ];        % audio source position
X_rcv = [receiverX, receiverY, receiverZ];  % audio receiver position

% check if parameters ok
[alpha,okflag] = ISM_AbsCoeff('t60',T60,room,weights,'LehmannJohansson');
if(okflag == 0)
    fprintf("bad okflag");
end
beta = sqrt(1-alpha);   % reflection coefficients for current environment

% compute rir using lehmann fast algorithm
fprintf('computing transfer function... ');
roomRir = fast_ISM_RoomResp(Fs,beta,'t60',T60,X_src,X_rcv,room,'Diffuse_dB',Diffuse_dB,'Delta_dB',Delta_dB);
fprintf('done!\n');

% plot mono rir
%{
maxRIR = max(roomRir);
%scale = 1;
scale = 1 / maxRIR;
roomRir = roomRir * scale;
plot(roomRir), title("original rir");
%}

% generate mono rir audio file
%{
audiowrite("~/Desktop/genRir.wav", roomRir, Fs);
%}

% load hrtf database
load('ReferenceHRTF.mat', 'hrtfData', 'sourcePosition');
% grab hrtf data
hrtfData = permute(double(hrtfData),[2,3,1]);
% grab azimuth (1), elevation data (2)
sourcePosition = sourcePosition(:,[1,2]);

% set hrtf parameters
% -180 >= azimuth <= 360, horizontal rotation
% -90 <= elevation <= 180, vertical rotation
desiredAz = azimuth;
desiredEl = elevation;
desiredPosition = [desiredAz desiredEl];

% generate interpolated hrtf with VBAP algorithm
interpolatedHrtf  = interpolateHRTF(hrtfData,sourcePosition,desiredPosition, "Algorithm","VBAP");

% squeeze to reduce number of dimensions down to 2
hrtfLeft = squeeze(interpolatedHrtf(:,1,:));
hrtfRight = squeeze(interpolatedHrtf(:,2,:));

% normalise hrtf to 1
maxHrtf = max(interpolatedHrtf, [], 'all');
hrtfLeft = hrtfLeft / maxHrtf;
hrtfRight = hrtfRight / maxHrtf;

% plot left and right hrtf
%{
figure, plot(hrtfLeft), hold on, plot(hrtfRight), title("hrtf");
%}

% convolve rir with hrtf and plot
binauralRirLeft = fconv(roomRir, hrtfLeft);
binauralRirRight = fconv(roomRir, hrtfRight);

% rotate for python
binauralRir = [binauralRirLeft, binauralRirRight]';

% plot left and right binaural rir
%{
figure, plot(binauralRirLeft), hold on, plot(binauralRirRight), title("binaural rir");
%}

% generate binaural rir audio file
%{
binauralRir = cat(2, binauralRirLeft, binauralRirRight);
audiowrite("~/Desktop/genBinauralRir.wav", binauralRir, Fs);
%}

end

