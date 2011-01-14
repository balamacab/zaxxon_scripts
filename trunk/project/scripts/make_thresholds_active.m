function make_thresholds_active(fichero)

%Anyadimos threshold.txt al final del fichero .geo
fid=fopen(fichero,'a');
fid2=fopen('threshold.txt','r');
contenido=fread(fid2,inf);
fwrite(fid,contenido);
fclose(fid2);
fclose(fid); 
end