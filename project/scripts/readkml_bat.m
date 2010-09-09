function readkml_bat(camino,curvas)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

if nargin==0
	camino=pwd;
end

if nargin==1
	curvas='sin curvas';
end


[errores,filename]=system(sprintf('dir %s\\*.kml /b',camino));
ficheros=strsplit(filename,strcat(char(13),char(10)));

for h=1:length(ficheros)
	if length(find(char(ficheros(h)))>0)
		readkml(strcat(camino,'\',char(ficheros(h))),curvas);
	end
end	