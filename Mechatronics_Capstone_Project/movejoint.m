% % %move joint
% % clear all;close all;clc
% % % 
ssc32 = serial('COM5', 'BaudRate', 9600);
set(ssc32,'Terminator','CR');
fopen(ssc32);
fprintf(ssc32,'#10P1800S500');
fclose(ssc32);
% 
% % 
% % % ssc32 = serial('COM5', 'BaudRate', 9600);
% % % set(ssc32,'Terminator','CR');
% % % fopen(ssc32);
% % % format='#%fP%fS%d';
% % % curDeg = 10;
% % % pos = 1500 + (curDeg)*3.28;
% % % fprintf(ssc32,sprintf(format,0,pos,500));
% % % fclose(ssc32);
% 
% % prompt = 'What is the original value? ';
% % x = input(prompt)
% % y = x*10
% 
% elbowPoints = [0.0713   -0.1962   -0.0329];
% wristPoints = [0.2150   -0.0689    0.0146];
% handPoints =  [0.2163   -0.0560    0.0253];
% hand_rel = handPoints - wristPoints;
% 
% forearm = wristPoints - elbowPoints;
% humerus = elbowPoints;
% normal = cross(forearm,humerus);
% wrist = real(acos(normal/hand_rel));
% rad2deg(wrist)



