function [tri,Pts]=mileer(archivo_entrada)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.


fid=fopen(archivo_entrada,'r')
if fid==0
    display(sprintf('No se ha podido abrir el archivo %s',archivo_entrada));
	return
end
fgets(fid);
fgets(fid);
fgets(fid);
cadena=fgets(fid);
partes=split(cadena,' ');
nvertices=str2num(partes(3,:))

fgets(fid);
fgets(fid);
fgets(fid);
cadena=fgets(fid);
partes=split(cadena,' ');
nfaces=str2num(partes(3,:));

fgets(fid);
fgets(fid);

lectura=fscanf(fid,'%f',nvertices*3);
x=lectura(1:3:end);
y=lectura(2:3:end);
z=lectura(3:3:end);
Pts=[x y z];

lectura=fscanf(fid,'%d',nfaces*4);
a1=lectura(2:4:end)+1;
a2=lectura(3:4:end)+1;
a3=lectura(4:4:end)+1;
tri=[a1 a2 a3];
fclose(fid);
