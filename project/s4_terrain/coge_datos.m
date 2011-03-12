system('copy ..\s1_mesh\salida\nodos.txt .');
system('copy ..\s1_mesh\salida\elements.txt .');
system('copy ..\s3_road\lamalla.mat .');
system('copy ..\s2_elevation_b\salida\lamalla.mat lamalla2.mat');

errores=0
fid=fopen('lamalla2.mat','r');
if fid~=-1
  fclose(fid)
  errores=comprueba_malla2;
 else
  display('lamalla2 not found');
end
save('errores.mat','errores');
message(8);
