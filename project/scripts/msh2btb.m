function msh2btb(dimx,dimy)
trocea_malla
system('copy salida\elements.txt elements.txt');
system('copy salida\nodos.txt nodos_conaltura.txt');
system('copy nodos_conaltura.txt ..\s4_terrain\salida\.');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid=my_fopen('..\s4_terrain\salida\listado_anchors.txt','w');

[numero x y z]=textread('nodos_conaltura.txt','%d %f %f %f');
temp=y;
y=z;
z=temp;

tamanyo=length(x);
fprintf(fid,'     <TerrainAnchors count="%d">\n',tamanyo);
for h=1:tamanyo
    fprintf(fid,'       <TerrainAnchor>\n         <Position x="%f" y="%f" z="%f" />\n       </TerrainAnchor>\n',x(h),y(h),z(h));
end
fprintf(fid,'     </TerrainAnchors>\n');

my_fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


procesar_elementstxt_mt(dimx,dimy,0,-1);%Sin mezclar con im�genes de fondo y sin unir a carretera
