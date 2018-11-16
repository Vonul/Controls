%% AA548 Project - Nathan Isaman (20180309)

clear all; close all; clc

% ======================================================================
% ================= Part 1: Modeling and Simulation ====================
% ======================================================================

% Subpart a: Implement ODE control system model
m = 1;                                          %kg
g = 9.81;                                       %m/s^2
I = 1;                                          %kg/m^2

t = 0.0001;                                     %time step param
timespan = 0:t:(2/pi);                          %time horizon vector
u = [m*g, 0];
omega = pi;
 for o = 1:length(timespan)
     ut(:,o) = [m*g + sin(2*timespan(o)*pi*omega); 0];
 end

% for r = 1:length(timespan)
%    ut(:,r) = [-m*g;0]; 
% end

% Simulating the system dynamics
q(:,1) = [0;0;0];                               %initial condition (origin)
qdot(:,1) = [0;0;0];                            %and at rest
qdot(:,2) = f(t,ut(:,1),q(:,1),qdot(:,1),m,I,g);
q(:,2) = h(t,ut(:,2),[0;0;0],[0;0;0],m,I,g);

for j = 3:length(timespan)
    qdot(:,j) = f(t,ut(:,j),q(:,j-1),qdot(:,j-1),m,I,g);
    
    q_dotdot = qdotdot(ut(:,j),q(:,j-2),m,I,g);
    q(:,j) = h(t,ut(:,j),q(:,j-1),qdot(:,j-2),q_dotdot,m,I,g);
    
end

figure
plot(timespan,q(1,:),timespan,q(2,:),timespan,q(3,:))
xlabel('time')
ylabel('States')
legend('h','v','\theta','Location','NorthWest')
title('Part 1: Positions vs Time')

figure
plot(timespan,qdot(1,:),timespan,qdot(2,:),timespan,qdot(3,:))
xlabel('time')
ylabel('Velocities')
leg2 =legend('$\dot{h}$','$\dot{v}$','$\dot{\theta}$','Location','NorthWest');
set(leg2, 'Interpreter', 'latex');
title('Part 1: Velocities vs Time')

figure
plot(timespan,ut(1,:),timespan,ut(2,:))
xlabel('time')
ylabel('Inputs')
legend('u_1','u_2','Location','NorthWest')
title('Part 1: Inputs vs Time')

% ======================================================================
% ================== Part 2: Stabilizing the System ====================
% ======================================================================

%Equilibrium point to stabilize about
eqQ = [0; 0.1; 0; 0; 0; 0];
eqU = [m*g; 0];

% Jacobian wrt state
A =     [0 0 0 1 0 0;
         0 0 0 0 1 0;
         0 0 0 0 0 1;
         0 0 eqU(1)*(1/m)*cos(eqQ(3)) 0 0 0;
         0 0 -eqU(1)*(1/m)*sin(eqQ(3)) 0 0 0;
         0 0 0 0 0 0];
     
% Jacobian wrt input
B     = [0 0;
         0 0;
         0 0;
         sin(eqQ(3))/m 0;
         cos(eqQ(3))/m 0;
         0 1/I];

% Part 2b -- Testing controllability 
ctrlMat = [B, A*B, A*A*B, A*A*A*B, A*A*A*A*B, A*A*A*A*A*B, A*A*A*A*A*B];
fprintf('\n\nPart 2b: Testing controllability of linearized system')
if rank(ctrlMat) == size(ctrlMat,1)
    fprintf('\n\tControllability Matrix is full rank => System is Controllable')
else
    fprintf('\n\tControllability Matrix is not full rank => System is not Controllable')
end

% Part 2c -- Design a stabilizing feedback control law using Lyapunov
lambda = 4;
Ac = (-lambda*eye(size(A)) - A);
fprintf('\n\nProblem 2c: Stabilizing Feedback Control')
fprintf('\n\tTesting Stability of -lambda*I - A matrix')
eig_of_Astab = eig(Ac)

Bc = B;
Cc = [1 0 0 0 0 0;
      0 1 0 0 0 0;
      0 0 1 0 0 0;
      0 0 0 0 0 0;
      0 0 0 0 0 0;
      0 0 0 0 0 0];
% Cc = [1 0 0 0 0 0;
%       0 1 0 0 0 0];
Dc = zeros(size(Bc));

ctrlSys = ss(Ac,Bc,Cc,0);
Wcf = gram(ctrlSys,'c');             %Replace with own numerical method? 
Wc = teddyGram(Ac,Bc,0.01);
Wcf - Wc;

K = 0.5*transpose(Bc)*inv(Wc);
Acl = (Ac - Bc*K);

fprintf('\n\nPart 2d: Stabilizing the System with a Feedback gain matrix')
fprintf('\n\tClosed Loop system is stable if all eigenvalues have negative real components')
eig_of_Acl = eig(Acl)

% Part D: Simulate the Nonlinear CL System using the K matrix found above
%         for a random initialization in the neighborhood of eqQ.

t = 0.0001;                                      %time step param
timespan = 0:t:5;                                %time horizon vector

% Simulating the system dynamics
q_del = rand(3,1);                               %Random perturbations
qdot_del = rand(3,1);

q2(:,1) = [0;0.1;0];                             %IC for lin pt
q2dot(:,1) = [0;0;0];                            %and at rest

q2(:,1) = q2(:,1) + q_del;                       %Perturbing the IC
q2dot(:,1) = q2dot(:,1) + qdot_del;              %Perturbing the IC

utStab(:,1) = eqU + -K*vertcat(q2(:,1),q2dot(:,1));

q2dot(:,2) = f(t,utStab(:,1),q2(:,1),q2dot(:,1),m,I,g);
q2(:,2) = h(t,utStab(:,1),q2(:,1),q2dot(:,1),m,I,g);

utStab(:,2) = eqU + -K*vertcat(q2(:,2),q2dot(:,2));

for j = 3:length(timespan)
    q2dot(:,j) = f(t,utStab(:,j-1),q2(:,j-1),q2dot(:,j-1),m,I,g);
    q2_dotdot = qdotdot(utStab(:,j-1),q2(:,j-2),m,I,g);
    q2(:,j) = h(t,utStab(:,j-1),q2(:,j-1),q2dot(:,j-2),q2_dotdot,m,I,g);
    
    utStab(:,j) = eqU + -K*vertcat(q2(:,j),q2dot(:,j));
end

figure
plot(timespan,q2(1,:),timespan,q2(2,:),timespan,q2(3,:))
xlabel('time')
ylabel('States')
legend('h','v','\theta','Location','NorthWest')
title('Part 2: Positions vs Time for Stabilized System')

figure
plot(timespan,q2dot(1,:),timespan,q2dot(2,:),timespan,q2dot(3,:))
xlabel('time')
ylabel('Velocities')
leg2 =legend('$\dot{h}$','$\dot{v}$','$\dot{\theta}$','Location','NorthWest');
set(leg2, 'Interpreter', 'latex');
title('Part 2: Velocities vs Time for Stabilized System')

figure
plot(timespan,utStab(1,:),timespan,utStab(2,:))
xlabel('time')
ylabel('Inputs')
legend('u_1','u_2','Location','NorthWest')
title('Part 2: Inputs vs Time for Stabilized System')

% ======================================================================
% ====================== Part 3: CT LQR Design  ========================
% ======================================================================

% Part A1: Write a function to create a random PD matrix
%               --> See PD_RandMat function for this

% Part A2: Write a numerical scheme to solve LQR.
%               --> See CT_Riccati_FwdEuler2 function for this

T = 20;                         %time horizon
dt = 0.0001;                    %time step
Qalt = transpose(Cc)*Cc;        %alternate Q formulation
Q = PD_RandMat(size(A,1));      %random Q matrix for cost function
R = PD_RandMat(size(B,2));      %random R matrix for cost function

% multi-dim array with Pt's
Plqr(:,:,:) = CT_Riccati_FwdEuler2(Q,R,A,B,Q,dt,T); 

% Constructing K matrices from the computed P values
time = 0:dt:T;
Rinv = inv(R);
Btr = transpose(B);
for t = 1:length(time) 
   Klqr(:,:,t+1) = -Rinv*Btr*Plqr(:,:,t);
end
Klqr_final = Klqr(:,:,end);            %Last value is SS val

% Simulating the LQR Dynamics
t = 0.0001;                                      %time step param
timespan = 0:t:T;                                %time horizon vector

%q_del = rand(3,1);                              %Random perturbations
%qdot_del = rand(3,1);

q3(:,1) = [0;0.1;0];                             %IC for linearized sys
q3dot(:,1) = [0;0;0];                            %and at rest

q3(:,1) = q3(:,1) + q_del;                       %Using previous q_del
q3dot(:,1) = q3dot(:,1) + qdot_del;              %Using previous qdot_del

utLQR(:,1) = eqU + Klqr_final*vertcat(q3(:,1),q3dot(:,1));

q3dot(:,2) = f(t,utLQR(:,1),q3(:,1),q3dot(:,1),m,I,g);
q3(:,2) = h(t,utLQR(:,1),q3(:,1),q3dot(:,1),m,I,g);

utLQR(:,2) = eqU + Klqr_final*vertcat(q3(:,2),q3dot(:,2));

for j = 3:length(timespan)
    q3dot(:,j) = f(t,utLQR(:,j-1),q3(:,j-1),q3dot(:,j-1),m,I,g);
    q3_dotdot = qdotdot(utLQR(:,j-1),q3(:,j-2),m,I,g);
    q3(:,j) = h(t,utLQR(:,j-1),q3(:,j-1),q3dot(:,j-2),q3_dotdot,m,I,g);
    
    utLQR(:,j) = eqU + Klqr_final*vertcat(q3(:,j),q3dot(:,j));
end

% MATLAB LQR Soln--------------------------------------------------------
[Ksolv,Psolv,Esolv] = lqr(A,B,Q,R,0);

qLQR(:,1) = [0;0.1;0];                               %IC for lin pt
qLQRdot(:,1) = [0;0;0];                              %and at rest

qLQR(:,1) = qLQR(:,1) + q_del;                       %Perturbing the IC
qLQRdot(:,1) = qLQRdot(:,1) + qdot_del;              %Perturbing the IC

utLQR_M(:,1) = eqU + -Ksolv*vertcat(qLQR(:,1),qLQRdot(:,1));

qLQRdot(:,2) = f(t,utLQR_M(:,1),qLQR(:,1),qLQRdot(:,1),m,I,g);
qLQR(:,2) = h(t,utLQR_M(:,1),qLQR(:,1),qLQRdot(:,1),m,I,g);

utLQR_M(:,2) = eqU + -Ksolv*vertcat(qLQR(:,2),qLQRdot(:,2));

for j = 3:length(timespan)
    qLQRdot(:,j) = f(t,utLQR_M(:,j-1),qLQR(:,j-1),qLQRdot(:,j-1),m,I,g);
    qLQR_dotdot = qdotdot(utLQR_M(:,j-1),qLQR(:,j-2),m,I,g);
    qLQR(:,j) = h(t,utLQR_M(:,j-1),qLQR(:,j-1),qLQRdot(:,j-2),qLQR_dotdot,m,I,g);
    
    utLQR_M(:,j) = eqU + -Ksolv*vertcat(qLQR(:,j),qLQRdot(:,j));
end
%-------------------------END of MATLAB LQR Soln Code -------------------

figure
subplot(1,2,1)
plot(timespan,q3(1,:),timespan,q3(2,:),timespan,q3(3,:))
xlabel('time')
ylabel('States')
legend('h','v','\theta','Location','NorthWest')
title('Part 3: Positions vs Time for LQR System')
subplot(1,2,2)
plot(timespan,qLQR(1,:),timespan,qLQR(2,:),timespan,qLQR(3,:))
xlabel('time')
ylabel('States')
legend('h','v','\theta','Location','NorthWest')
title('Part 3: Positions vs Time for LQR System (Matlab)')

figure
subplot(1,2,1)
plot(timespan,q3dot(1,:),timespan,q3dot(2,:),timespan,q3dot(3,:))
xlabel('time')
ylabel('Velocities')
leg2 =legend('$\dot{h}$','$\dot{v}$','$\dot{\theta}$','Location','NorthWest');
set(leg2, 'Interpreter', 'latex');
title('Part 3: Velocities vs Time for LQR System')
subplot(1,2,2)
plot(timespan,qLQRdot(1,:),timespan,qLQRdot(2,:),timespan,qLQRdot(3,:))
xlabel('time')
ylabel('Velocities')
leg2 =legend('$\dot{h}$','$\dot{v}$','$\dot{\theta}$','Location','NorthWest');
set(leg2, 'Interpreter', 'latex');
title('Part 3: Velocities vs Time for LQR System (Matlab)')

figure
subplot(1,2,1)
plot(timespan,utLQR(1,:),timespan,utLQR(2,:))
xlabel('time')
ylabel('Inputs')
legend('u_1','u_2','Location','NorthWest')
title('Part 3: Inputs vs Time for LQR System')
subplot(1,2,2)
plot(timespan,utLQR_M(1,:),timespan,utLQR_M(2,:))
xlabel('time')
ylabel('Inputs')
legend('u_1','u_2','Location','NorthWest')
title('Part 3: Inputs vs Time for LQR System (Matlab)')

% ADD COMPARISON BTW OPT CTRL AND STAB FEEDBACK CTRL HERE

% SHOW COMPARISON BTW VARYING Q AND R HERE

% Use C'C as Q and R = I to get similar perf as StabFeedback ctrl

% ======================================================================
% ===================== Part 4: Kalman Filtering =======================
% ======================================================================

% Part a: Discretization of the System (A-BK)x - Bw --------------------
Akf = (A + B*Klqr_final);                      %CL Sys using LQR gain mat K
del_t = 0.001;                                 %Discretization time step
endTime = 5;

Ad = expm(Akf*del_t);                          %-------------------------
Bd = inv(Akf)*(Ad - eye(size(Ad)))*B;          %|       Discretized     |
Cd = Cc;                                       %|         System        |
Dd = Dc;                                       %-------------------------
Fd = Bd;
Hd = eye(6);

% Part bcd: Noisy system -------------------------------------------------
kftime = 0:del_t:endTime;

% Generating the initial random state;
sig_0 = 0.1*eye(6);
x0_mu = [0 0 0 0 0 0];
x0 = mvnrnd(x0_mu,sig_0,1)';

% Generating the signal noise
sig_v = 0.2*eye(6);
v_mu = [0 0 0 0 0 0];
vt = mvnrnd(v_mu,sig_v,length(kftime))';

% Generating the state disturbance
sig_w = 0.1*eye(2);
w_mu = [0 0];
wt = mvnrnd(w_mu,sig_w,length(kftime))';

% Initial Noisy State/Measurement Values
xnoise(:,1) = x0 + Fd*wt(:,1) + Bd*eqU;
ynoise(:,1) = Cd*xnoise(:,1) + Hd*vt(:,1);

% Kalman Filter ICs
Kkf(:,:,1) = sig_0*Cd'*inv(Cd*sig_0*Cd' + Hd*sig_v*Hd');
x_hat(:,1) = Kkf(:,:,1)*ynoise(:,1) + Bd*eqU;
sig_hat(:,:,1) = sig_0;

for j = 2:length(kftime)
    % Noisy State Update
    xnoise(:,j) = Ad*xnoise(:,j-1) + Fd*wt(:,j) + Bd*eqU;
    ynoise(:,j) = Cd*xnoise(:,j) + Hd*vt(:,j);
         
    % Time Update
    x_hat(:,j) = Ad*x_hat(:,j-1) + Bd*eqU;
    sig_hat(:,:,j) = Ad*sig_hat(:,:,j-1)*Ad' + Fd*sig_w*Fd';
    
    % Measurement Update
    Kkf(:,:,j) = sig_hat(:,:,j)*Cd'*inv(Cd*sig_hat(:,:,j)*Cd' + Hd*sig_v*Hd');
    x_hat(:,j) = x_hat(:,j) + Kkf(:,:,j)*(ynoise(:,j) - Cd*x_hat(:,j));
    sig_hat(:,:,j) = (eye(6) - Kkf(:,:,j)*Cd)*sig_hat(:,:,j);
end

figure
subplot(3,1,1)
plot(kftime,ynoise(1,:),kftime,x_hat(1,:))
xlabel('Time')
ylabel('h')
title('Kalman Filter Applied to Measurement, Horizontal Position')
legend('h noisy','h estimate')

subplot(3,1,2)
plot(kftime,ynoise(2,:),kftime,x_hat(2,:))
xlabel('Time')
ylabel('v')
title('Kalman Filter Applied to Noisy Measurement, Vertical Position')
legend('v noisy','v estimate')

subplot(3,1,3)
plot(kftime,ynoise(3,:),kftime,x_hat(3,:))
xlabel('Time')
ylabel('\theta')
title('Kalman Filter Applied to Noisy Measurement, Rotational Position')
legend('\theta noisy','\theta estimate')







