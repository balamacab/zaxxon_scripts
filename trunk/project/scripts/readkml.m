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
	curvas='sin curvas';
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
pos=findstr('.',ficherokml);
nombre_sin_extension=ficherokml(1:pos(end)-1);
fichero_salida=strcat('salida\',nombre_sin_extension,'.geo');
end

end
