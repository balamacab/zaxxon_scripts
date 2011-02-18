function check_rellenofiles(offset)

[errores,filename]=system(sprintf('dir salida\\*_relleno.kml /b'));
ficheros=strsplit(filename,strcat(char(13),char(10)));

for h=1:length(ficheros)
	if length(find(char(ficheros(h)))>0)
		ficherokml=strcat('salida\\',char(ficheros(h)));
		[longitud latitud altura]=leer_datos(ficherokml);
		cumplen=sum(altura<=offset);
		if cumplen>0
			display(sprintf('------------------ %s has points with elevation below %f',ficherokml,offset));
			pause
		end
	end
end	
