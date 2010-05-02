function addt()
fid=my_fopen('salida\joined.geo','r');
contents=fread(fid,Inf);
my_fclose(fid);
cadena=char(contents)';
pos=strfind(cadena,'Plane Surface');
pos_ultimo=pos(end);
cadena_final=regexprep(cadena(pos_ultimo:end),'Plane Surface\((\d+)\)(.*)Spline\((\d+)\)','Plane Surface($1)$2Transfinite Surface($1)','dotall');
cadena=strcat(cadena(1:pos_ultimo-1),cadena_final);
fid=my_fopen('salida\joined.geo','w');
fprintf(fid,'%s',cadena);
my_fclose(fid)
