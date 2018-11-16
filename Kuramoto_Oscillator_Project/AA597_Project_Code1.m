%% AA 597 - Project - Nathan Isaman
clear all; close all; clc

cases = 0:0.01:1.0;

N = 100;        % Number of agents
g = 0.05;       % Width of Lorentzian distribution
xs = randn(N,1);
ws = lorentzian(xs,0,g);        % Same initial condition for every run

for q = 1:length(cases)

%p = 0.95;
p = cases(q);
K1 = -0.5;
K2 = 1.0;
Q = -K1/K2;
Ki = GammaK2(xs,p,K1,K2);

h = 0.01;
T = 10000;
time = 0:h:T;
%phi_init = (pi/4)*randn(N,1);
phi_init = zeros(N,1);
phi(:,1) = phi_init;
c = Ki/N;
% An alternative approach to calculating the Kuramoto Dynamics:=========
% Src: https://www.uccs.edu/~jmarsh2/doc/Kuramoto.pdf
%fprintf('Starting ode45 on Kuramoto Dynamics...')
dPdt = @(P,W,c)(W+c.*sum(sin(meshgrid(P)-meshgrid(P)'),2));
[times phases] = ode45(@(t,p)dPdt(p,ws,c),[0 T],phi_init);
phi = transpose(phases);
time = transpose(times);
%fprintf('\node45 Complete.')
%=======================================================================
% Forward Euler approach to solving DE (Not very efficient) ============
% for i = 1:length(time)-1
%     for j = 1:N
%         phi(j,i+1) = phi(j,i) + h*kuramoto2(ws(j,1),Ki(j,1),N,phi(j,i),phi(:,i));
%     end
% end
%======================================================================
% Normalizing the phase wrt Pi (i.e. pushing the phases onto the interval [-pi,pi]
phinorm = zeros(size(phi));
for k = 1:size(phi,2)
    phinorm(:,k) = wrapTo2Pi(phi(:,k));    
end
% Plotting =============================================================

% Plotting the Complex Order Parameter (with unit circle shown)
for o = 1:length(phinorm)
    Zt(o) = complexOrderParam(N,phinorm(:,o));
    ReZt(o) = real(Zt(o));
    ImZt(o) = imag(Zt(o));
end

Zfinal = complexOrderParam(N,phinorm(:,end))
Rfinal = abs(Zfinal)
Rtest(q) = Rfinal;              % Storing R for p vs R plot
ReZ = real(Zfinal);
ImZ = imag(Zfinal);
circlePlot = 1*exp(sqrt(-1)*(0:0.01:2*pi));
ReCir = real(circlePlot);
ImCir = imag(circlePlot);

% Plotting every other p value
if mod(q,4) == 0
    [fd,xd] = ksdensity(phinorm(:,end));
    figure
    subplot(1,2,1)
    plot(xd,fd)
    ylabel('P(phi)')
    xlabel('phi')
    title(['Distribution of Phases with p = ' num2str(p)])

    subplot(1,2,2)
    plot(ReCir,ImCir,'k--'), hold on
    plot(ReZt(end-100:end),ImZt(end-100:end),'g.')
    plot(ReZ,ImZ,'md')
    legend('Unit Circle','Z(t)','Z(T)')
    xlabel('Re{Z}')
    ylabel('Im{Z}')
    title(['Complex Order Parameter Z for p = ' num2str(p)])
    axis equal
    hold off
end
end

figure
plot(cases,Rtest,'md')
title(['Order Parameter R vs p for Q = ' num2str(Q)])
xlabel('p')
ylabel('R')
axis equal
%====================================================================
%----------------------------Functions-------------------------------
%====================================================================
function w = lorentzian(x,m,g)
% Function used to generate natural frequencies out of the Lorentzian
% Distribution.
% P(x) = (1/pi)*g/((x-m)^2 + g^2)
% Params:
% g : distribution mean width
% m : distribution mean; for this case we are assuming m = 0
% x : value at which to evaluate P(x); generally a random number
w = zeros(length(x),1);
for i = 1:length(x)
    w(i,1) = (1/pi)*g/((x(i)^2 + g^2));
end
end

function pdot = kuramoto(wi,Ki,N,phi_i,phis)
% This function represents the RHS of the Kuramoto dynamics
% phi_i_dot = wi + (Ki/N)sum(sin(phi_j - phi_i) for i = 1,...,N
% Params:
% wi : ith agent's natural frequency
% Ki : ith agent's coupling strength
% N  : number of agents in swarm
% phi : the agent's phase

pdot = wi + (Ki/N)*sum(sin(phis - phi_i));
end

function pdot = kuramoto2(wi,Ki,N,phi_i,phis)
% Implementation of equation (3) where the oscillators interact via the
% mean-field variables R and PHI.
PHI = mean(phis);      % Collective/Mean Phase
Z = complexOrderParam(N,phis);
R = real(Z);
pdot = wi + Ki*R*sin(PHI - phi_i);
end


function Z = complexOrderParam(N,phis)
% This function calculates the Complex Order Parameter:
% Z = R*e^(iPHI) = 1/N * SUM(e^i*phi_j)
im = sqrt(-1);
Z = (1/N)*sum(exp(im*phis));
end

function Ki = GammaK(x,p,K1,K2)
% This function represents the double-delta distribution for oscillator
% coupling strengths.
% Ki(x) = (1-p)*dirac(x - K1) + p*dirac(x - K2)
% Params:
% x : point to draw Ki from in the distribution (random entry)
% p : probability that a random oscillator is a conformist
% K1 : coupling strength for contrarian agent
% K2 : coupling strength for conformist agent
vals = rand(length(x),1);

Ki = zeros(length(x),1);
for i = 1:length(x)
    if vals(i) <= p
        Ki(i,1) = K2;
    end
    if vals(i) > p
        Ki(i,1) = K1;
    end
end
end

function Ki = GammaK2(x,p,K1,K2)
% This function represents the double-delta distribution for oscillator
% coupling strengths.
% Ki(x) = (1-p)*dirac(x - K1) + p*dirac(x - K2)
% Params:
% x : point to draw Ki from in the distribution (random entry)
% p : probability that a random oscillator is a conformist
% K1 : coupling strength for contrarian agent
% K2 : coupling strength for conformist agent
thresh = length(x)*p;
Ki = zeros(length(x),1);
for i = 1:length(x)
    if i <= thresh
        Ki(i,1) = K2;
    end
    if i > thresh
        Ki(i,1) = K1;
    end
end
end