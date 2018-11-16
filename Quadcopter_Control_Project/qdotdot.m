function q_dotdot = qdotdot(u,q,m,I,g)
%Param u        : control input (thrust, torque) [N,Nm]
%Param q        : state (horizontal, vertical, roation) [m,m,rad]
%Param m        : mass [kg]
%Param I        : moment of Inertia [kg/m^2]
%Param g        : gravitational accelleration [m/s^2]

q_dotdot = [(u(1)/m)*sin(q(3));
           (u(1)/m)*cos(q(3)) - g;
           u(2)/I];
       
end