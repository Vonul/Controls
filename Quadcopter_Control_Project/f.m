function qdot_plus = f(t,u,q,qdot,m,I,g)
%Param t        : time step [s]
%Param u        : control input (thrust, torque) [N,Nm]
%Param q        : state (horizontal, vertical, roation) [m,m,rad]
%Param qdot     : state derivative [m/s,m/s,rad/s]
%Param m        : mass [kg]
%Param I        : moment of Inertia [kg/m^2]
%Param g        : gravitational accelleration [m/s^2]

qdot_plus = qdot + t*qdotdot(u,q,m,I,g);

end