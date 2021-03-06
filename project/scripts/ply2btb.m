function ply2btb(dimx,dimy)

[tri1,Pts1] = mileer('salida\n.ply','tri');
x=Pts1(:,1);
y=Pts1(:,2);
z=Pts1(:,3);
n1=tri1(:,1);
n2=tri1(:,2);
n3=tri1(:,3);

fid=fopen('nodos_conaltura.txt','w');
fprintf(fid,'%d %f %f %f\r\n',[(1:length(x))' x z y]');
fclose(fid)
fid=fopen('elements.txt','w');
fprintf(fid,'%d 2 2 222 0 %d %d %d\r\n',[(1:length(n1))' n1 n2 n3]');
fclose(fid);

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

