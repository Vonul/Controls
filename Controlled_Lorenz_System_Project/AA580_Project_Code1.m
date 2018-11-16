%% AA 580 - Project - Nathan Isaman
clear all; close all; clc

syms r s b x1 x2 x3

states = [x1;x2;x3];

f0 = [s*(x2-x1);
      x1*(r-x3) - x2;
      x1*x2 - b*x3];
f1 = [0;1;0];
f2 = [0;0;1];

df0 = jacobian(f0,states);
df1 = jacobian(f1,states);
df2 = jacobian(f2,states);

F = horzcat(f1,f2);

% [f0,f1]
f0f1 = df1*f0 - df0*f1
% [f0,f2]
f0f2 = df2*f0 - df0*f2

F = horzcat(F,f0f1,f0f2)
Ftest1 = subs(F,transpose(states),{0,0,0})

rank(Ftest1)

df0f1 = jacobian(f0f1,states)
df0f2 = jacobian(f0f2,states)
% [f0,[f0,f1]]
f0f0f1 = df0f1*f0 - df0*f0f1
% [f0,[f0,f2]]
f0f0f2 = df0f2*f0 - df0*f0f2

% Little Observability Algebras (Non-Trivial Cases)
h1 = x1;
h2 = x2;
h3 = x3;

% Testing with just h1
Lf0h1 = jacobian(h1,states)*f0
LLf0h1 = jacobian(Lf0h1,states)*f0
LLLf0h1 = jacobian(LLf0h1,states)*f0
LLLLf0h1 = jacobian(LLLf0h1,states)*f0
O1 = horzcat(h1,Lf0h1,LLf0h1,LLLf0h1,LLLLf0h1)
dO1 = jacobian(O1,states)
subs(dO1,transpose(states),{0,0,0})
rank(subs(dO1,transpose(states),{0,0,0}))

% Testing with just h2
Lf0h2 = jacobian(h2,states)*f0
LLf0h2 = jacobian(Lf0h2,states)*f0
LLLf0h2 = jacobian(LLf0h2,states)*f0
LLLLf0h2 = jacobian(LLLf0h2,states)*f0
O2 = horzcat(h2,Lf0h2,LLf0h2,LLLf0h2,LLLLf0h2)
dO2 = jacobian(O2,states)
subs(dO2,transpose(states),{0,0,0})
rank(subs(dO2,transpose(states),{0,0,0}))

% Testing with just h3
Lf0h3 = jacobian(h3,states)*f0
LLf0h3 = jacobian(Lf0h3,states)*f0
LLLf0h3 = jacobian(LLf0h3,states)*f0
LLLLf0h3 = jacobian(LLLf0h3,states)*f0
O3 = horzcat(h3,Lf0h3,LLf0h3,LLLf0h3,LLLLf0h3)
dO3 = jacobian(O3,states)
subs(dO3,transpose(states),{0,0,0})
rank(subs(dO3,transpose(states),{0,0,0}))

% Testing with h1 and h2
fprintf('dO12 with h1 and h2: \n')
O12 = horzcat(O1,O2);
dO12 = jacobian(O12,states)
subs(dO12,transpose(states),{0,0,0})
rank(subs(dO12,transpose(states),{0,0,0}))

% Testing with h1 and h3
fprintf('dO13 with h1 and h3: \n')
O13 = horzcat(O1,O3);
dO13 = jacobian(O13,states)
subs(dO13,transpose(states),{0,0,0})
rank(subs(dO13,transpose(states),{0,0,0}))

% Testing with h2 and h3
fprintf('dO23 with h2 and h3: \n')
O23 = horzcat(O2,O3);
dO23 = jacobian(O23,states)
subs(dO23,transpose(states),{0,0,0})
rank(subs(dO23,transpose(states),{0,0,0}))

% Big Observability Algebra tests for nontrivial observation cases
% Testing with just h1
fprintf('Big Obs Alg with just h1\n')
Lf1h1 = jacobian(h1,states)*f1
LLf1h1 = jacobian(Lf1h1,states)*f1
Lf2h1 = jacobian(h1,states)*f2
LLf2h1 = jacobian(Lf2h1,states)*f2
O1B = horzcat(h1,Lf0h1,LLf0h1,LLLf0h1,LLLf0h1,Lf1h1,LLf1h1,Lf2h1,LLf2h1)
dO1B = jacobian(O1B,states)
subs(dO1B,transpose(states),{0,0,0})
rank(subs(dO1B,transpose(states),{0,0,0}))

% Testing with just h2
fprintf('Big Obs Alg with just h2\n')
Lf1h2 = jacobian(h2,states)*f1
LLf1h2 = jacobian(Lf1h2,states)*f1
Lf2h2 = jacobian(h2,states)*f2
LLf2h2 = jacobian(Lf2h2,states)*f2
O2B = horzcat(h2,Lf0h2,LLf0h2,LLLf0h2,LLLf0h2,Lf1h2,LLf1h2,Lf2h2,LLf2h2)
dO2B = jacobian(O2B,states)
subs(dO2B,transpose(states),{0,0,0})
rank(subs(dO2B,transpose(states),{0,0,0}))

% Testing with just h3
fprintf('Big Obs Alg with just h3\n')
Lf1h3 = jacobian(h3,states)*f1
LLf1h3 = jacobian(Lf1h3,states)*f1
Lf2h3 = jacobian(h3,states)*f2
LLf2h3 = jacobian(Lf2h3,states)*f2
O3B = horzcat(h3,Lf0h3,LLf0h3,LLLf0h3,LLLf0h3,Lf1h3,LLf1h3,Lf2h3,LLf2h3)
dO3B = jacobian(O3B,states)
subs(dO3B,transpose(states),{0,0,0})
rank(subs(dO3B,transpose(states),{0,0,0}))

% Testing with h1 and h2
fprintf('Big Obs Alg with h1 and h2\n')
O12B = horzcat(O1B,O2B)
dO12B = jacobian(O12B,states)
subs(dO12B,transpose(states),{0,0,0})
rank(subs(dO12B,transpose(states),{0,0,0}))

% Testing with h1 and h3
fprintf('Big Obs Alg with h1 and h3\n')
O13B = horzcat(O1B,O3B)
dO13B = jacobian(O13B,states)
subs(dO13B,transpose(states),{0,0,0})
rank(subs(dO13B,transpose(states),{0,0,0}))

% Testing with h2 and h3
fprintf('Big Obs Alg with h2 h3\n')
O23B = horzcat(O2B,O3B)
dO23B = jacobian(O23B,states)
subs(dO23B,transpose(states),{0,0,0})
rank(subs(dO23B,transpose(states),{0,0,0}))

% Testing for Feedback Linearizability
fprintf('\nFeedback Linearization: ')
fprintf('\nDistributions Delta_0, Delta_1, and Delta_2')
D0 = horzcat(f1,f2)
D1 = horzcat(D0,f0f1,f0f2)
D2 = horzcat(D1,f0f0f1,f0f0f2)

fprintf('\nDistributions in the neighborhood of [0 0 0]')
fprintf('\nDelta_0: ')
subs(D0,transpose(states),{0,0,0})
fprintf('\nDelta_1: ')
subs(D1,transpose(states),{0,0,0})
fprintf('\nDelta_2: ')
subs(D2,transpose(states),{0,0,0})

fprintf('Ranks of Delta_0, Delta_1, Delta_2')
rank(subs(D0,transpose(states),{0,0,0}))
rank(subs(D1,transpose(states),{0,0,0}))
rank(subs(D2,transpose(states),{0,0,0}))

% Testing the involutivity of Delta_0 and Delta_1
fprintf('Testing the involutivity of Delta_0 :\n')
f1f2 = df2*f1 - df1*f2
fprintf('Testing the involutivity of Delta_1 :\n')
f1f0f1 = df0f1*f1 - df1*f0f1
f1f0f2 = df0f2*f1 - df1*f0f2
f2f0f1 = df0f1*f2 - df2*f0f1
f2f0f2 = df0f2*f2 - df2*f0f2

% Calculating Vector Relative Degree for Feedback Linearization
%h1
L1f0h1 = jacobian(h1,states)*f0;
L2f0h1 = jacobian(L1f0h1,states)*f0;
%h2
L1f0h2 = jacobian(h2,states)*f0;
L2f0h2 = jacobian(L1f0h2,states)*f0;
%h3
L1f0h3 = jacobian(h3,states)*f0;
L2f0h3 = jacobian(L1f0h3,states)*f0;
fprintf('\nTesting 1s order with f1')
Lf1L1f0h1 = jacobian(L1f0h1,states)*f1
Lf1L1f0h2 = jacobian(L1f0h2,states)*f1
Lf1L1f0h3 = jacobian(L1f0h3,states)*f1
fprintf('\nTesting 1s order with f2')
Lf2L1f0h1 = jacobian(L1f0h1,states)*f2
Lf2L1f0h2 = jacobian(L1f0h2,states)*f2
Lf2L1f0h3 = jacobian(L1f0h3,states)*f2

fprintf('\nTesting 2nd order with f1')
Lf1L2f0h1 = jacobian(L2f0h1,states)*f1
Lf1L2f0h2 = jacobian(L2f0h2,states)*f1
Lf1L2f0h3 = jacobian(L2f0h3,states)*f1
fprintf('\nTesting 2nd order with f2')
Lf2L2f0h1 = jacobian(L2f0h1,states)*f2
Lf2L2f0h2 = jacobian(L2f0h2,states)*f2
Lf2L2f0h3 = jacobian(L2f0h3,states)*f2

Lf1L0f0h1 = jacobian(h1,states)*f1;
Lf2L0f0h1 = jacobian(h1,states)*f2;
Lf1L0f0h3 = jacobian(h3,states)*f1;
Lf2L0f0h3 = jacobian(h3,states)*f2;
%% 
Del = [Lf1L1f0h1,Lf2L1f0h1;Lf1L0f0h3,Lf2L0f0h3]
B = [L2f0h1;L1f0h3]

alpha = -inv(Del)*B
beta = inv(Del)

Phi = [h1;L1f0h1;h3]
dPhi = jacobian(Phi,states)
dphi = [1 0 0; -s s 0; 0 0 1];
Phi_ = [1 0 0; -s s 0; 0 0 1];
Phi_inv = inv(Phi_)

Az = simplify(dPhi*(f0 + [f1,f2]*alpha))
B = dPhi*[f1,f2]*beta

% LQR Design for Stabilization and Trajectory Tracking
Alqr = [0 1 0; 0 0 0; 0 0 0;]
Blqr = [0 0; 1 0; 0 1]
%Qlqr = eye(3)
Clqr = [1 0 0; 0 1 0; 0 0 1]        %Observing z1 and z3 (x1 and x3)
Qlqr = 10*transpose(Clqr)*Clqr
Rlqr = eye(2)

Klqr = lqr(Alqr,Blqr,Qlqr,Rlqr)

% Creating the state trajectory
% Setting sigma = 10, rho = 28 beta = 8/3
sigma = 10;
rho = 28;
beta = 8/3;

Phi_set = [1 0 0; -sigma sigma 0; 0 0 1];
Phi_set_inv = inv(Phi_set);
h = 0.001;
theta = 0:h:(30*pi);
x_init = [2;1;0];
x_ref_pt = [6;3;9];
z_ref_pt = Phi_set*x_ref_pt;
x_ref(:,1) = x_init;
for j = 1:length(theta)
   x_ref(:,j) = refFun(theta(j));
end
% Transforming the trajectory into z coords
for k = 1:length(theta)
    z_ref(:,k) = Phi_set*x_ref(:,k);
end

% z_state(:,1) = Phi_set*x_init;
% for i = 1:length(theta)
%     %z_state(:,i+1) = z_state(:,i) + h*((Alqr - Blqr*Klqr)*z_state(:,i) + Blqr*Klqr*z_ref(:,i));
%     z_state(:,i+1) = z_state(:,i) + h*(Alqr*z_state(:,i) - Blqr*Klqr*(z_state(:,i) - z_ref(:,i)));
%     %z_state(:,i+1) = z_state(:,i) + h*(Alqr*z_state(:,i) - Blqr*Klqr*(z_state(:,i) - z_ref_pt));
% end
% %Transforming the z state back into x state
% for j = 1:length(theta)
%    x_state(:,i) =  Phi_set_inv*z_state(:,i);
% end
% 
% figure
% plot3(z_state(1,:),z_state(2,:),z_state(3,:))

x_state(:,1) = x_init;
for i = 1:length(theta)-1
   u = FBL_Ctrl(Phi_set,Phi_set_inv,Klqr,x_state(:,i),x_ref(:,i));
   x_state(:,i+1) = x_state(:,i) + h*(f0_fn(x_state(:,i)) + f1*u(1) + f2*u(2)); 
end
figure
plot3(x_init(1),x_init(2),x_init(3),'md'), hold on
plot3(x_state(1,:),x_state(2,:),x_state(3,:)), hold on
plot3(x_ref(1,:),x_ref(2,:),x_ref(3,:),'r--')
axis equal
hold off


z_state(:,1) = Phi_set*x_init;
for k = 1:length(theta)
   z_state(:,k) = Phi_set*x_state(:,k); 
end
% figure
% plot3(z_state(1,:),z_state(2,:),z_state(3,:))

%=======================================================================
%------------------------------- Functions ----------------------------
%=======================================================================
% The function for a circular trajectory on the x-y plane based on states
function vals = refFun(theta)
    r = 3;
    val1 = r*cos(theta);
    val2 = r*sin(theta);
    vals = [val1;val2;3];
end

% State Transform function
function x = zTox(z,Phi_inv)
    x = Phi_inv*z;
end
function z = xToz(x,Phi)
    z = Phi*x;
end

% Controller function and helper functions
function u = FBL_Ctrl(Phi,Phi_inv,K,x,xr)
    sigma = 10;
    Del_inv = [1/sigma, 0; 0 1];
    zr = xToz(xr,Phi);
    z = xToz(x,Phi);
    
    beta_inv = [sigma, 0; 0 1];  % beta_inv = inv(Del_inv) = Del
  
    u = -beta_inv*(K*(z-zr) - alpha_fn(x));
    %u = beta_inv*(K*x - alpha_fn(x));

end

function alphax = alpha_fn(x)
    sigma = 10;
    Del_inv = [1/sigma, 0; 0 1];
    
    alphax = -Del_inv*b_fn(x);

end

function bx = b_fn(x)
    sigma = 10;
    rho = 28;
    beta = 8/3;
    bx1 = sigma^2*(x(1) - x(2)) + sigma*(x(1)*(rho - x(3)) - x(2));
    bx2 = x(1)*x(2) - beta*x(3);
    
    bx = [bx1;bx2];
end

% Drift Function
function f0 = f0_fn(x)
    sigma = 10;
    rho = 28;
    beta = 8/3;
    
    f01 = sigma*(x(2) - x(1));
    f02 = x(1)*(rho - x(3)) - x(2);
    f03 = x(1)*x(2) - beta*x(3);
    
    f0 = [f01;f02;f03];
end