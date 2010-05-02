function create_hlg()

fichero_de_nodos_con_altura='..\s1_mesh\salida\nodos.txt';
[numero x z y]=textread(fichero_de_nodos_con_altura,'%d %f %f %f');

minx=min(x);
minz=min(z);
maxx=max(x);
maxz=max(z);

[mapeo]=textread('..\mapeo.txt','%f');
[longitudmin altura latitudmin]=BTB_a_coor(minx,0,minz,mapeo);
[longitudmax altura latitudmax]=BTB_a_coor(maxx,0,maxz,mapeo);

%‘Operations’>’Select’>’Load from file’
fid=fopen('grid.hlg','w');
fprintf(fid,'[HIGHLIGHTING]\r\n');
fprintf(fid,'zoom=17\r\n');
fprintf(fid,'PointLat_1=%f\r\n',latitudmax);%38.7015972947917
fprintf(fid,'PointLat_2=%f\r\n',latitudmax);%38.7015972947917
fprintf(fid,'PointLat_5=%f\r\n',latitudmax);%38.7015972947917
fprintf(fid,'PointLat_3=%f\r\n',latitudmin);%38.5691381150080
fprintf(fid,'PointLat_4=%f\r\n',latitudmin);%38.5691381150080
fprintf(fid,'PointLon_1=%f\r\n',longitudmax);%-0.268813929600834
fprintf(fid,'PointLon_4=%f\r\n',longitudmax);%-0.268813929600834
fprintf(fid,'PointLon_5=%f\r\n',longitudmax);%-0.268813929600834
fprintf(fid,'PointLon_2=%f\r\n',longitudmin);%-0.397154512982273
fprintf(fid,'PointLon_3=%f\r\n',longitudmin);%-0.397154512982273
fclose(fid)

fprintf(1,'-------------------------------------------------------------------------\n');
fprintf(1,'                                                                        .\n');
fprintf(1,'Operations -> Select -> Load from file -> Load -> Start                  \n');
fprintf(1,'Operations -> Select -> Previous Selection -> Stick -> Start             \n');
fprintf(1,'             Select .dat file bindings                                   \n');    
fprintf(1,'-------------------------------------------------------------------------\n');                                                                      