function vercontorno()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

hold on
S=load('.\salida\lamalla.mat');
A=load('..\anchors.mat');
nac=length(A.x);
plot((A.x(1:nac/2)+A.x(nac/2+1:nac))/2,(A.z(1:nac/2)+A.z(nac/2+1:nac))/2,'k','LineWidth',3);
contour(S.rangox,S.rangoz,S.malla_regular,200);


