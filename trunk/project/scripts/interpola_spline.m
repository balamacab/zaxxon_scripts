function [salida angulop]=interpola_spline(punto0,distancia0,angulos0,punto3,distancia3,angulos3,t)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

x0=punto0(1);
y0=punto0(2);
z0=punto0(3);

x3=punto3(1);
y3=punto3(2);
z3=punto3(3);

anguloxz0=pi+(pi/2-angulos0(1));
anguloy0=-angulos0(2);

x1=x0+(distancia0*cos(anguloy0))*cos(anguloxz0);
z1=z0+(distancia0*cos(anguloy0))*sin(anguloxz0);
y1=y0+distancia0*sin(anguloy0);

anguloxz3=(pi/2-angulos3(1));
anguloy3=angulos3(2);

x2=x3+(distancia3*cos(anguloy3))*cos(anguloxz3);
z2=z3+(distancia3*cos(anguloy3))*sin(anguloxz3);
y2=y3+distancia3*sin(anguloy3);



A = x3 - 3*x2 + 3*x1 - x0;
B = 3*x2  - 6*x1  + 3*x0;   
C = 3*x1 - 3*x0;
D = x0;

E = z3 - 3*z2 + 3*z1 - z0;
F = 3*z2  - 6*z1  + 3*z0;   
G = 3*z1 - 3*z0;
H = z0;

I = y3 - 3*y2 + 3*y1 - y0;
J = 3*y2  - 6*y1  + 3*y0;   
K = 3*y1 - 3*y0;
L = y0;

x=A*t^3+B*t^2+C*t+D;
y=I*t^3+J*t^2+K*t+L;
z=E*t^3+F*t^2+G*t+H;

salida=[x y z];

%plot(x0,z0,'+',x1,z1,'*',x2,z2,'o',x3,z3,'+',x,z,'r*');


%Derivadas
%Según x
dx=3*A*t^2+2*B*t+C;
%Según z
dz=3*E*t^2+2*F*t+G;

%Pendiente de la recta perpendicular
angulop=atan2(-dx,dz);
