function q_plus = h(t,u,q,qdot,qdotdot,m,I,g)
%Param t        : time step [s]
%Param u        : control input (thrust, torque) [N,Nm]
%Param q        : state (horizontal, vertical, roation) [m,m,rad]
%Param qdot     : state velocity [m/s,m/s,rad/s]
%Param qdotdot  : state acceleration [m/2^2, m/s^2, rad/s^2]
%Param m        : mass [kg]
%Param I        : moment of Inertia [kg/m^2]
%Param g        : gravitational accelleration [m/s^2]

q_plus = q + t*qdot + (t^2)*qdotdot;

end