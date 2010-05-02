function terrain_noise(amp_ruido)

S=load('salida\anchors_originales.mat');
x=S.datax;
y=S.datay;
z=S.dataz;

y=y+(amp_ruido(1)+(amp_ruido(2)-amp_ruido(1))*rand(size(y)));


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

tamanyo=length(z);

fid=my_fopen('salida\listado_anchors.txt','w');
fid2=my_fopen('salida\nodos_conaltura.txt','w');

fprintf(fid,'     <TerrainAnchors count="%d">\n',tamanyo);
for h=1:tamanyo
    fprintf(fid,'       <TerrainAnchor>\n         <Position x="%f" y="%f" z="%f" />\n       </TerrainAnchor>\n',x(h),y(h),z(h));
    fprintf(fid2,'%d %f %f %f\n',h,x(h),z(h),y(h));
end
fprintf(fid,'     </TerrainAnchors>\n');

my_fclose(fid);
my_fclose(fid2);

