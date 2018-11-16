function cGram = teddyGram(A,B,dt)
%       _           _  
%     ((`'-"``""-'`)) 
%       )   -    -  (
%      /    o _ o    \ 
%      \    ( 0 )    /   <I sure hope this crap works!)
%    _, '-..__^__..-' ,_
%   (:'`'-/       \-'`':) 
%    `'-.; .;;;;;. ;.-'`
%        ; ;;ctrl; ;
%       /  ';;;;;'  \
%      /  ;._____.;  \
%     _\  \       /  /_
%    (((___|     |___)))

t = 0;
Q = B*transpose(B);

ctrlGram(:,:,1) = zeros(size(B*B'));
Q_ = A*ctrlGram(:,:,1) + ctrlGram(:,:,1)*A';

i=1;

while abs(norm(Q_ + Q,2)) > 0.006
   ctrlGram(:,:,i+1) =  ctrlGram(:,:,i) + dt*(expm(A*t)*B*B'*expm(A'*t));
        
   Q_ = A*ctrlGram(:,:,i+1) + ctrlGram(:,:,i+1)*A';
   
   t = t + dt;
   i = i + 1;
   
   if i > 3e3
       fprintf('\n\nfunction teddyGram exceeded max iterations');
       break
   end
   
end
cGram = ctrlGram(:,:,end);
end
