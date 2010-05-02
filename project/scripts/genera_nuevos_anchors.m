function genera_nuevos_anchors(fichero_anchors,fichero_anchors_retocados)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

if nargin<2
    display('Ejemplo: genera_nuevos_anchors(''anchors_originales.mat'',''nuevos_anchors.mat'')');
    return;
end

S=load('..\nac.mat');
nac=S.nac;

S=load(fichero_anchors);
datax=S.datax;
datay=S.datay';
dataz=S.dataz;

%%%%%%%%%%%%%%%%%%%%%%%%%%%Lo añado porque es lo que parece correcto ya que calcular_superficies usa anchors.mat
SA=load('..\anchors.mat');
orig_x=SA.x;
orig_y=SA.y;
orig_z=SA.z;

datax(1:nac)=orig_x;
datay(1:nac)=orig_y;
dataz(1:nac)=orig_z;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

S1=load(fichero_anchors_retocados);
nuevos_anchors=S1.nuevo_anchor;

distancia_antes=modulo([datax(1:nac/2)-datax(nac/2+1:nac) datay(1:nac/2)'-datay(nac/2+1:nac)' dataz(1:nac/2)-dataz(nac/2+1:nac)]);

datax(1:nac)=nuevos_anchors(1:nac,1);
datay(1:nac)=nuevos_anchors(1:nac,2);
dataz(1:nac)=nuevos_anchors(1:nac,3);

distancia_despues=modulo([datax(1:nac/2)-datax(nac/2+1:nac) datay(1:nac/2)'-datay(nac/2+1:nac)' dataz(1:nac/2)-dataz(nac/2+1:nac)]);


[distancia_antes distancia_despues sign(distancia_antes-distancia_despues)]

fid=fopen('movimiento_anchors.geo','w');
for h=1:nac
    fprintf(fid,'Point(%d) = {%f,%f,%f,1};\n',h*2,S.datax(h),S.datay(h),S.dataz(h));
    fprintf(fid,'Point(%d) = {%f,%f,%f,1};\n',h*2+1,datax(h),datay(h),dataz(h));
    fprintf(fid,'Line(%d) = {%d, %d};\n',h*2,h*2,h*2+1);
end
fclose(fid);

tamanyo=length(datax);

fid=fopen('salida\listado_anchors.txt','w');
fid2=fopen('salida\nodos_conaltura.txt','w');

fprintf(fid,'     <TerrainAnchors count="%d">\n',tamanyo);
for h=1:tamanyo
    fprintf(fid,'       <TerrainAnchor>\n         <Position x="%f" y="%f" z="%f" />\n       </TerrainAnchor>\n',datax(h),datay(h),dataz(h));
    fprintf(fid2,'%d %f %f %f\n',h,datax(h),dataz(h),datay(h));
end
fprintf(fid,'     </TerrainAnchors>\n');

fclose(fid);
fclose(fid2);

%display('Vaya al directorio .., ejecute junta. Luego incorpore surfaces.txt al Venue.xml')

function m=modulo(a)
        m=sqrt(a(:,1).^2+a(:,2).^2+a(:,3).^2);
end

end