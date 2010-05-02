function leehgt2(fichero1,latitud1,longitud1,fichero2,latitud2,longitud2)
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

[mapeo]=textread('..\mapeo.txt','%f');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        [B1 rangox1 rangoz1]=lee_hgt(fichero1,latitud1,longitud1,mapeo);
        [B2 rangox2 rangoz2]=lee_hgt(fichero2,latitud2,longitud2,mapeo)
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if (latitud2(1)==latitud1(2))
             rangoz=[rangoz1(1:end-1) rangoz2];
             rangox=rangox1;
             B=[B1(1:end-1,:) ;B2];
        end

        if (longitud2(1)==longitud1(2))
             rangox=[rangox1(1:end-1) rangox2];
             rangoz=rangoz1;
             B=[B1(:,1:end-1) B2];
        end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	malla_regular=B;

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
