function creax(x,y,z,u,v,tri,ficherosalida,textura)
%creax(x',y',alturas',u,v,tri(ii,:)-1,'salida/inside.x','Placa3.dds');
fid=fopen('../scripts/esqueleto_directx.x','r');
contenido=char(fread(fid,inf,'char'))';
fclose(fid);
inicio=contenido(1:496);%findstr(contenido','Mesh {')
% 171756;
%      2051.904541;449.297119;-626.045227;,
centro1='      MeshNormals { ';
%        57252;
%        -0.114429; 0.969981; 0.214577;,
%        57252;
%        3;0,0,0;,
centro2='      MeshTextureCoords {';
%        171756;
%         0.000000; 1.000000;,
centro3='      MeshMaterialList {';
%        1;
%        57252;
%        0,
%        0,
final1=contenido(1379:1600);
final2=contenido(1611:end);


fid=fopen(ficherosalida,'w');
fprintf(fid,'%s\n      %d;\n',inicio,length(x));
cadena=sprintf('      %f; %f; %f;,\n',[x' z' -y']');cadena(end-1)=';';
fprintf(fid,'%s       %d;\n',cadena,length(tri));
cadena=sprintf('       3;%d,%d,%d;,\n',tri');cadena(end-1)=';';
fprintf(fid,'%s%s\n      %d;\n',cadena,centro1,length(tri));
cadena=sprintf('      %f; %f; %f;,\n',[zeros(1,length(tri))' -ones(1,length(tri))' zeros(1,length(tri))']');cadena(end-1)=';';
fprintf(fid,'%s        %d;\n',cadena,length(tri));
cadena=sprintf('      3;%d,%d,%d;,\n',[(0:length(tri)-1)' (0:length(tri)-1)' (0:length(tri)-1)']');cadena(end-1)=';';
fprintf(fid,'%s      }\n%s\n      %d;\n',cadena,centro2,length(x));
cadena=sprintf('        %f; %f;,\n',[u' v']');cadena(end-1)=';';
fprintf(fid,'%s      }\n%s\n        1;\n        %d;\n',cadena,centro3,length(tri));
for h=1:length(tri)-1
    fprintf(fid,'       0,\n');      
end
 fprintf(fid,'       0;;');   
fprintf(fid,'%s%s%s',final1,textura,final2);
fclose(fid);
end