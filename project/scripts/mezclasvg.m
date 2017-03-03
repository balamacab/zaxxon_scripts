function mezclasvg(fichero)
%fichero='grid001';
fid=fopen(strcat(fichero,'.kml'),'r');
todo=fread(fid,inf);
fclose(fid)

cadena=char(todo)';




posicion1=strfind(cadena,'<coordinates>');
posicion2=strfind(cadena,'</coordinates>');
iniciodatos=posicion1+length('<coordinates>');
finaldatos=posicion2-1;

losdatos=cadena(iniciodatos:finaldatos);

coordenadas=sscanf(losdatos,'%f,%f,%f\n');

[m,n]=size(coordenadas);
coordenadas=reshape(coordenadas,3,m*n/3)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid=fopen(strcat(fichero,'.svg'),'r');
todo=fread(fid,inf);
fclose(fid)

cadena=char(todo)';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
poslabels1=strfind(cadena,'altitude y gridlines');
extracto=cadena(poslabels1:end);
poslabels2=strfind(extracto,'</g>');
poslabels2=poslabels2(1);
posmetros=strfind(extracto(1:poslabels2),'/text');
posmin=posmetros(1);
while (extracto(posmin)~='>')
    posmin=posmin-1;
end
posmin=posmin+1;
ymin=sscanf(extracto(posmin:poslabels2),'%f m');

posmax=posmetros(end);
while (extracto(posmax)~='>')
    posmax=posmax-1;
end
posmax=posmax+1;
ymax=sscanf(extracto(posmax:poslabels2),'%f m');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


inicio=strfind(cadena,'t1 track');
cadena=cadena(inicio:end);

posicionesy1=strfind(cadena,'y1="');
posicionesy2=strfind(cadena,'y2="');

posicionesy1=[posicionesy1 posicionesy2(end)];

altitud=zeros(length(posicionesy1),1);
for h=1:length(posicionesy1)
    datos=sscanf(cadena(posicionesy1(h)+4:end),'%f"');
    altitud(h)=datos(1);
end

minimo=min(altitud);
maximo=max(altitud);

altitud=(altitud-minimo)/(maximo-minimo);
altitud=ymin+altitud*(ymax-ymin);

fid=fopen(strcat(fichero,'_relleno.kml'),'w');
fprintf(fid,'%f,%f,%f\n',[coordenadas(:,1) coordenadas(:,2) altitud]');
fclose(fid);
end