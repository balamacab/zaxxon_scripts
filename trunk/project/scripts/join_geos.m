function join_geos()

[numero_sons caminos]=look_for_father_or_sons('..\sons.txt');

fid=my_fopen('salida\anchors_carretera.geo','r');
fid2=my_fopen('salida\phys111.txt','r');
contenido=fread(fid,Inf); 
cadena=char(contenido)';
contenido2=fread(fid2,Inf); 
cadena2=strcat('Physical Surface(111)={',char(contenido2)');
my_fclose(fid);
my_fclose(fid2);

for h=1:numero_sons
	fid=my_fopen(strcat(char(caminos(h)),'\s1_mesh\salida\anchors_carretera.geo'),'r');
	fid2=my_fopen(strcat(char(caminos(h)),'\s1_mesh\salida\phys111.txt'),'r');
	contenido=fread(fid,Inf); 
	cadena_nueva=char(contenido)';
	contenido2=fread(fid2,Inf); 
	cadena_nueva2=char(contenido2)';
	my_fclose(fid);
	my_fclose(fid2);
	cadena=strcat(cadena,cadena_nueva);
	cadena2=strcat(cadena2,',',cadena_nueva2);
end

cadena=strcat(char(10),char(13),cadena,char(10),char(13),cadena2,'};',char(10),char(13),'//******************* END OF JOINED .GEO FILES **************************',char(10),char(13));

fid=my_fopen('salida\joined.geo','w');
fprintf(fid,'%s',cadena);
my_fclose(fid);

%Si es multiproyecto los thresholds se anyaden en join_geos, pero si es un solo track se hace en mallado_regular
make_thresholds_active('salida\joined.geo');

message(19);