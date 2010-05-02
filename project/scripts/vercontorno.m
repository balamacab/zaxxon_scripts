function vercontorno()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

hold on
S=load('.\salida\lamalla.mat');
A=load('..\anchors.mat');
nac=length(A.x);
plot((A.x(1:nac/2)+A.x(nac/2+1:nac))/2,(A.z(1:nac/2)+A.z(nac/2+1:nac))/2,'k','LineWidth',3);
contour(S.rangox,S.rangoz,S.malla_regular,200);


