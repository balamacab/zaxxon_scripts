function errores=comprueba_malla2()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

S=load('lamalla2.mat');
minimox=min(S.rangox);
maximox=max(S.rangox);
minimoz=min(S.rangoz);
maximoz=max(S.rangoz);

[numero x z y]=textread('nodos.txt','%d %f %f %f');
minimo2x=min(x);
maximo2x=max(x);
minimo2z=min(z);
maximo2z=max(z);

errores=0;
%los que no tienen el 2 deben ser los más negativos y los más positivos
fprintf(1,'\n\n\nEn X (lamalla2,.msh)\n\n');
if minimox<minimo2x, mensaje='ok'; else	errores=1;mensaje='Failed'; end	
fprintf(1,'    %f<%f ->\t%s\n',minimox,minimo2x,mensaje);

if maximox>maximo2x, mensaje='ok'; else	errores=1;mensaje='Failed'; end	
fprintf(1,'    %f>%f ->\t%s\n\n\n',maximox,maximo2x,mensaje);

fprintf(1,'En Z (lamalla2,.msh)\n\n');

if minimoz<minimo2z, mensaje='ok'; else	errores=1;mensaje='Failed'; end	
fprintf(1,'    %f<%f ->\t%s\n',minimoz,minimo2z,mensaje);

if maximoz>maximo2z, mensaje='ok'; else	errores=1;mensaje='Failed'; end	
fprintf(1,'    %f>%f ->\t%s\n\n\n',maximoz,maximo2z,mensaje);
