[numero_padres caminos]=look_for_father_or_sons('..\father.txt');

if numero_padres==0
    system('copy ..\s2_elevation\salida\lamalla.mat .');
 else
   system(sprintf('copy %s\\s3_road\\lamalla.mat .',char(caminos(1))));
end
system('copy ..\Venue\nodos.mat .');
system('copy ..\Venue\porcentajes.mat .');

%system('del porcentajes.mat')
%leer_porcentajes('..\venue\porcentajes.xml','porcentajes.mat')
%system('del nodos.mat')
%leer_nodos('..\venue\nodes.xml','nodos.mat')

message(4);