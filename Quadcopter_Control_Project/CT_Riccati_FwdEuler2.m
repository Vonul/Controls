function P = CT_Riccati_FwdEuler2(Q, R, A, B, Qf, dt, T)

P(:,:,1) = Qf;                          %Final value equal to Qf

time = 0:dt:T;

%Precomputing constant matrix values here for efficiency.
Rinv = inv(R);
Btr = transpose(B);
Atr = transpose(A);

for i = 1:length(time)-1
    P(:,:,i+1) = P(:,:,i) - dt*(-Atr*P(:,:,i) - P(:,:,i)*A + P(:,:,i)*B*Rinv*Btr*P(:,:,i) - Q);
end
end