function readkml_bat(camino,curvas)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

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