function value=get_option(nombre,tipo)

[numero_padres caminos]=look_for_father_or_sons('..\father.txt');

if numero_padres==0
    fid=fopen('..\options.ini','r');
 else
    fid=fopen(sprintf('%s\\options.ini',char(caminos(1))),'r');
end

contenido=fread(fid,inf);
contenido=char(contenido)';

pos_option=findstr(contenido,nombre);
if length(pos_option)>0
	value=sscanf(contenido((pos_option+length(nombre)+1):end),tipo,1);
else
	value=-1;
end
fclose(fid);