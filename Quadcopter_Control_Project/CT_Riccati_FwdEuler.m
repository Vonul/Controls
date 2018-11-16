%function Pout = CT_Riccati_FwdEuler(Q, R, A, B, Qf, dt, T)

%Testing purposes only
Q = PD_RandMat(6);
Qf = Q;
R = PD_RandMat(2);
A = rand(6,6);
B = rand(6,2);
dt = 0.0001;
T = 5;

%---------------------

e = size(Qf,1);

P(:,1,1) = reshape(Qf,[e*e,1]);        %vectorizing Qf / init P
Qvec = reshape(Q,[e*e,1])
time = 0:dt:T;

%Precomputing for some efficiency
Rinv = inv(R);
Atr = transpose(A);
Btr = transpose(B);


%Using FWD Euler on Vectorized matrix differential equation:
for i = 1:length(time)
    for j = 1:e:e*e
        P(j:j+e-1,1,i+1) = P(j:j+e-1,1,i) - dt*(-Atr*P(j:j+e-1,1,i) - (P(j:j+e-1,1,i)'*A)' + ...
            P(j:j+e-1,1,i)*B*Rinv*Btr*P(j:j+e-1,1,i) - Qvec(j:j+e-1,1);
    end
end

Pout = reshape(P,[e,e,size(time)]);

%end