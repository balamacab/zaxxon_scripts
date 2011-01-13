function [a,b]=getimagecoordinates(fichero,crearmapeo)

fid=fopen(fichero,'r');
contenido=fread(fid,inf);
fclose(fid);
contenido=char(contenido)';
contenido=strtrim(contenido);
pos1=findstr('min x y z',contenido);
pos2=findstr('max x y z',contenido);
cadena=strtrim(contenido(pos1+10:end));
a=sscanf(cadena,'%f',3);
cadena=strtrim(contenido(pos2+10:end));
b=sscanf(cadena,'%f',3);

%pies_a_metros=0.3048;

if nargin==2
	centrox=a(1)+(b(1)-a(1))/2
	dimx=(b(1)-a(1))
	centroy=a(2)+(b(2)-a(2))/2
	dimy=(b(2)-a(2))
	fid=fopen('mapeo.txt','w');

	%Esquinas inferior izquierda y superior derecha
	fprintf(fid,'%.10f\n%.10f\n%.10f\n%.10f\n',-dimx/2,-dimy/2,a(1),a(2));
	fprintf(fid,'%.10f\n%.10f\n%.10f\n%.10f\n',dimx/2,dimy/2,b(1),b(2));

	fclose(fid);	
end