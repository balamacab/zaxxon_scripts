function make_thresholds_active(fichero)

%Anyadimos threshold.txt al final del fichero .geo
fid=fopen(fichero,'a');
fid2=fopen('threshold.txt','r');
contenido=fread(fid2,inf);
fwrite(fid,contenido);
fclose(fid2);

%Si encontramos limites, los a�adimos tras los puntos que definen los thresholds
fid_limits=fopen('salida\limits.geo','r');
if fid_limits~=-1
	contents=fread(fid_limits,Inf); 
	fclose(fid_limits);
	fwrite(fid,contents);
end
fclose(fid); 
end