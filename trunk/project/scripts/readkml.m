function readkml(ficherokml,curvas)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

if (nargin<1) || (ficherokml=='h')
	disp('Uso: readkml(''file.kml'',''s'')');
	disp('2nd parameter can be ''t'', for adding straight lines, ''s'' for adding a spline, or ''st'' for adding both');
	return;
end

if nargin==1
	curvas='no curve';
end

[longitud latitud altura]=leer_datos(ficherokml);

[mapeo]=textread('..\mapeo.txt','%f');
fichero_salida=dame_nombre_salida(ficherokml);
fid=my_fopen(fichero_salida,'w');
fid2=my_fopen('salida\route_plain.txt','w');

display('Grabando ficheros')

contador=0;
aleatorio=round(rand*100000);

fprintf(fid,'cl_route%.4d=100;\n',aleatorio);
fprintf(fid,'numk=newreg;\n',aleatorio);
for h=1:length(longitud)    
			[lax nada laz]=coor_a_BTB(longitud(h),latitud(h),0,mapeo);
			x(h)=lax;
			y(h)=laz;
            fprintf(fid,'Point (numk+%d)={%f, %f, %f, cl_route%d};\r\n',contador,x(h),y(h),0,aleatorio);%nada(h) en lugar de 0
			fprintf(fid2,'%f,%f,%f\r\n',x(h),y(h),0);%nada(h) en lugar de 0
			if (isempty(findstr(curvas,'t'))==0) & (h>1)
			    fprintf(fid,'Line(numk+%d)={numk+%d,numk+%d};\r\n',contador,contador-1,contador);
			end
			contador=contador+1;
end
inserta_field(fid,length(longitud),0);

	if (isempty(findstr(curvas,'t'))==0) 
			    fprintf(fid,'Line(numk+%d)={numk+%d,numk+%d};\r\n',0,contador-1,0);
	end

	if (isempty(findstr(curvas,'s'))==0)
			fprintf(fid,'Spline(numk+%d)={',length(longitud)+1);
			for h=1:length(longitud)
			    fprintf(fid,'numk+%d,',h-1);
			end
			fprintf(fid,'numk+%d};\r\n',0);
	end

my_fclose(fid);
my_fclose(fid2);


function fichero_salida=dame_nombre_salida(ficherokml)
[A,B,C]=fileparts(ficherokml);
fichero_salida=strcat('salida\',B,'.geo');
end


function inserta_field(fid,longitud,insertar)
	fprintf(fid,'If (%d)\r\n',insertar);
    fprintf(fid,'  Field[numk+1] = Attractor;\r\n');
    fprintf(fid,'  Field[numk+1].NodesList = {numk+0:numk+%d};\r\n',longitud-1);

    fprintf(fid,'  Field[numk+2] = Threshold;\r\n');
    fprintf(fid,'  Field[numk+2].IField = numk+1;\r\n');
    fprintf(fid,'  Field[numk+2].LcMin = 20;\r\n');
    fprintf(fid,'  Field[numk+2].LcMax = 2000;\r\n');
    fprintf(fid,'  Field[numk+2].DistMin = 1;\r\n');
    fprintf(fid,'  Field[numk+2].DistMax = 10000;\r\n');
    fprintf(fid,'  Field[numk+2].StopAtDistMax = 0;\r\n');
    fprintf(fid,'  Mesh.CharacteristicLengthExtendFromBoundary = 0;\r\n');
	
	fprintf(fid,'  Background Field=numk+2;\r\n');
	fprintf(fid,'EndIf\r\n');
end

end
