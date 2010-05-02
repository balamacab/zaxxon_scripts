function alisar()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.


[numero datax dataz datay]=textread('nodos_conaltura.txt','%d %f %f %f');

[x z radio]=textread('horquillas.txt','%f %f %f');

S=load('..\nac.mat');
nac=S.nac;

for h=1:length(x)
    
    posx=x(h);
    posz=z(h);
    elradio=radio(h);
    
    %nodos que están en ese radio de acción
    distancias=sqrt((posx-datax).^2+(posz-dataz).^2);  
    y=find(distancias<elradio);
    
    nodos_carretera=y(y<=nac);
    nodos_a_retocar=y(y>nac);
    
    if (length(nodos_carretera)>0) && (length(nodos_a_retocar)>0)
     
        fichero=sprintf('salida\\horquilla%d.geo',h);
        fid=fopen(fichero,'w');
        for g=1:length(nodos_carretera)
            fprintf(fid,'Point(%d) = {%f, %f, %f, 20};\n',g+100,datax(nodos_carretera(g)),datay(nodos_carretera(g)),dataz(nodos_carretera(g)));        
        end
        %Este debería ser un vector que apunte desde el centro de la
        %horquilla hacia la esquina donde hay carretera
        vectores=[(datax(nodos_carretera)-posx) (dataz(nodos_carretera)-posz)];
        suma=sum(vectores,1); %dirección del vértice
        suma=suma/norm(suma);
        
        for g=1:length(nodos_a_retocar)
%             distancias=sqrt((datax(nodos_a_retocar(g))-datax(nodos_carretera)).^2+(dataz(nodos_a_retocar(g))-dataz(nodos_carretera)).^2);
            separacion=min(distancias);
            vector_desde_centro=[datax(nodos_a_retocar(g))-posx dataz(nodos_a_retocar(g))-posz];
            producto=dot(vector_desde_centro/norm(vector_desde_centro),suma); %Su amplitud también se usa. Cuanto más pequeña más se debe respetar el valor anterior
            %angulo=angle(vector_desde_centro(1)+j*vector_desde_centro(2));
            
            
            %El respeto al valor anterior debe ser mínimo en la dirección del vértice
            %(vector suma) y lejos de los nodos de la carretera
            if norm(vector_desde_centro)>2
                respeto=0.5*(0.5*(1-producto)+1.5*(separacion/elradio));
            else
                respeto=1.5*(separacion/elradio);
            end
            if respeto>1
                respeto=1;
            end
            if respeto<0
                respeto=0;
            end
            
            
           fprintf(fid,'Point(%d) = {%f, %f, %f, 20};\n',g,datax(nodos_a_retocar(g)),datay(nodos_a_retocar(g)),dataz(nodos_a_retocar(g)));
            nueva_altura=consulta_malla_alternativa(datax(nodos_a_retocar(g)),dataz(nodos_a_retocar(g)),datax(nodos_carretera),datay(nodos_carretera),dataz(nodos_carretera),elradio/2);
%            if separacion<4 %Si está muy cerca de la carretera-> nuevo valor
%                 datay(nodos_a_retocar(g))=nueva_altura;
%            else %Si está un poco más lejos respetamos algo el valor original
               datay(nodos_a_retocar(g))=nueva_altura+respeto*(datay(nodos_a_retocar(g))-nueva_altura);
%            end
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