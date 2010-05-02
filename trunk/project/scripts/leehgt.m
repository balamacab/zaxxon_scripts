function leehgt(fichero,latitud,longitud)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.


%<PointLongitude>0.0001389</PointLongitude>
%<PointLatitude>38.9998611</PointLatitude>

[mapeo]=textread('..\mapeo.txt','%f');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        [B1 rangox rangoz]=lee_hgt(fichero,latitud,longitud,mapeo);
	
	malla_regular=B1;

	save -mat-binary 'salida\lamalla.mat' rangox rangoz malla_regular


function [B rangox rangoz]=lee_hgt(fichero,latitud,longitud,mapeo)
	fid=fopen(fichero);
        B=fread(fid,inf,'*int16','ieee-be')
	fclose(fid);
        numdata=round(sqrt(length(B)));

	fid=fopen(fichero);
	B=(1+1e-9)*rot90(fread(fid,[numdata numdata],'*int16','ieee-be'));
	fclose(fid);
	
	B=single(B);
	rango_lat=linspace(latitud(1),latitud(2),numdata)
	rango_long=linspace(longitud(1),longitud(2),numdata)

	[x1 y1 z1]=coor_a_BTB(rango_long(1),rango_lat(1),B(1),mapeo);
	[x2 y2 z2]=coor_a_BTB(rango_long(end),rango_lat(end),B(end),mapeo);

	rangox=linspace(x1,x2,numdata)
	rangoz=linspace(z1,z2,numdata)
end

end
