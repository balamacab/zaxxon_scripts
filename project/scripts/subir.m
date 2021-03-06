function subir()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.


[numero datax dataz datay]=textread('nodos_conaltura.txt','%d %f %f %f');

[x z radio subidacentral]=textread('circulos.txt','%f %f %f %f');

S=load('..\nac.mat');
nac=S.nac;

for h=1:length(x)
    
    posx=x(h);
    posz=z(h);
    elradio=radio(h);
    subidamaxima=subidacentral(h);

    %nodos que est�n en ese radio de acci�n
    distancias=sqrt((posx-datax).^2+(posz-dataz).^2);  
    indices=find(distancias<elradio);
    
    nodos_carretera=indices(indices<=nac);
    nodos_a_retocar=indices(indices>nac);
    
    if (length(nodos_a_retocar)>0)
     
        fichero=sprintf('salida\\rebajado%d.geo',h);
        fid=fopen(fichero,'w');
        for g=1:length(nodos_carretera)
            fprintf(fid,'Point(%d) = {%f, %f, %f, 20};\n',g+100,datax(nodos_carretera(g)),datay(nodos_carretera(g)),dataz(nodos_carretera(g)));        
        end

        for g=1:length(nodos_a_retocar)
           elevacion=subidamaxima*(elradio-distancias(nodos_a_retocar(g)))/elradio; %En el centro se aplica la subida m�xima. En el per�metro subida cero
           fprintf(fid,'Point(%d) = {%f, %f, %f, 20};\n',g,datax(nodos_a_retocar(g)),datay(nodos_a_retocar(g)),dataz(nodos_a_retocar(g)));
	   datay(nodos_a_retocar(g))=datay(nodos_a_retocar(g))+elevacion;            
           fprintf(fid,'Point(%d) = {%f, %f, %f, 20};\n',g+50,datax(nodos_a_retocar(g)),datay(nodos_a_retocar(g)),dataz(nodos_a_retocar(g)));
           fprintf(fid,'Line(%d) = {%d,%d};',g+50,g,g+50);
        end
        fclose(fid);
    else
        fprintf(1,'Problema en la horquilla: (%f,%f)',posx,posz);
    end
end

%_--------------------------------------------------------
%_--------------------------------------------------------

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

save('salida\anchors_originales.mat','datax','datay','dataz');

end
