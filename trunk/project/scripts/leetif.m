function leetif(fichero,latitud,longitud)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.


%<PointLongitude>0.0001389</PointLongitude>
%<PointLatitude>38.9998611</PointLatitude>

	fid=fopen(fichero );
	Inicio=fread(fid,2,'*int8','ieee-be');
	if Inicio(1)=='I' %Little endian
		Inicio2=fread(fid,3,'uint16');
		B1=rot90(fread(fid,[3601 3601],'*int16'));
	else
		Inicio2=fread(fid,3,'uint16','ieee-be');
		B1=rot90(fread(fid,[3601 3601],'*int16'));
	end
	
	fclose(fid);
	%jj=find(B1==-32768);
	%B1(jj)=NaN;
	%B1(1:100)
	%figure,contour(1:3601,1:3601,B1)


	B1=single(B1);
	rango_lat=linspace(latitud(1),latitud(2),3601)
	rango_long=linspace(longitud(1),longitud(2),3601)


	[mapeo]=textread('..\mapeo.txt','%f');

	[x1 y1 z1]=coor_a_BTB(rango_long(1),rango_lat(1),B1(1),mapeo);
	[x2 y2 z2]=coor_a_BTB(rango_long(end),rango_lat(end),B1(end),mapeo);

	rangox=linspace(x1,x2,3601)
	rangoz=linspace(z1,z2,3601)
	
	malla_regular=B1;

	save -mat-binary 'salida\lamalla.mat' rangox rangoz malla_regular
end
