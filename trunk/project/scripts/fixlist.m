function fixlist()

fid=my_fopen('salida\anchors_carretera.geo','r');
contents=fread(fid,inf);
my_fclose(fid)
cadena=char(contents)';

pos=findstr(cadena,'Line Loop');
cadena=cadena(pos(end):end);

pos1=findstr(cadena,'{');
pos2=findstr(cadena,'}');
cadena=cadena(pos1(1)+1:pos2(1)-1);

cadena=regexprep(cadena,',',' ');
numeros=sscanf(cadena,'%d',inf);

fid=my_fopen('salida\lista_out.txt','w');
for h=1:length(numeros)-1
    if numeros(h)>=0
       fprintf(fid,' offsetp+%d,',numeros(h));
    else
       fprintf(fid,' -(offsetp+%d),',-numeros(h));
    end
end
if numeros(end)>=0
       fprintf(fid,' offsetp+%d',numeros(end));
else
       fprintf(fid,' -(offsetp+%d)',-numeros(end));
end
fclose(fid);
