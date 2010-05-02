function [controlA controlB controlC controlD]=saca_controlpoints(P,x)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.


longitud=length(P)/2;
for h=1:longitud
    distancia=x(h+1)-x(h);
	dU=distancia;
	dC=distancia*distancia;
	dT=dU*dC;
    A=dT*P(h,1);%1
	B=dC*P(h,2);%2
	C=dU*P(h,3);%3
    D=P(h,4);
	E=dT*P(h+longitud,1);%1
	F=dC*P(h+longitud,2);%2
	G=dU*P(h+longitud,3);%3
	H=P(h+longitud,4);
	controlA(1,h)=D;
	controlA(2,h)=H;
	controlB(1,h)=D+C/3;
	controlB(2,h)=H+G/3;
	controlC(1,h)=D+2*C/3+B/3;
	controlC(2,h)=H+2*G/3+F/3;
	controlD(1,h)=D+C+B+A;
	controlD(2,h)=H+G+F+E;
end