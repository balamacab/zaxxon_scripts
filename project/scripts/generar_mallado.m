function generar_mallado(fichero_entrada,renovar,offset1,separacion)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

if nargin<4
    display('IMPORTANTE: Depure la carretera en planta para evitar que existan solapes en las curvas m�s cerradas');
    display('IMPORTANTE: deje una �nica surface en el Venue.xml de partida');
    display('Genere a partir de la carretera un terreno con una �nica etapa de ancho 0.1m');    
    display('Trocee el fichero Venue.xml generado de la siguiente manera:');
    display('---> pre_anchorsyfaces.xml');
    display('---> anchors_paso1.xml');
    display('---> post_anchorsyfaces.xml');
    display(' ');
    display('Una vez troceado llame a generar_mallado con los siguientes argumentos:');
    display('1) Fichero de entrada (Ej: anchors_paso1.xml)');
    display('2) 1 si    desea renovar el fichero anchors.mat que se usa en las siguientes fases');
    display('   0 si NO desea renovar el fichero anchors.mat que se usa en las siguientes fases (usar para regeneraci�n de ficheros)');
    display('3) >0 si    desea puntos de apoyo para dise�ar la malla en gmsh (el valor introducido se emplear� como inicio de la numeraci�n de esos puntos. Ej: 30000)');
    display('   =0 si NO desea puntos de apoyo para dise�ar la malla en gmsh');
    display('4) separacion en metros del centro de la carretera (Ej: 35) a la que se quiere los puntos de apoyo para generar la malla en gmsh');
    %display('5) fichero .geo que se quiere a�adir');    
    display(' ');
    display('Ejemplo: generar_mallado(''..\venue\anchors_paso1.xml'',1,30000,26)');
    display(' ');
    display('Salida:');
    display('-> anchors.mat (si as� se ha pedido)');    
    display('-> anchors_carretera.geo');    
    %display('-> mallado.geo (anchors_carretera.geo mezclado con contorno.geo)');
    display(' ');
    display('Con la salida se debe generar una malla en gmsh, a partir de la cual se generar�n dos ficheros:')
    display('-> nodos.txt (la nueva lista de anchors de los Terrains)');
    display('-> elements.txt (la lista de tri�ngulos del terreno)');
    display(' ');
    display('Los nodos se procesan con procesar_nodostxt');
    display('Los tri�ngulos se procesan con procesar_elementstxt');    
    return;
end

if renovar==1
    display('Renovando valores (generando ..\anchors.mat...)');
    
    [tree] = leer_anchors(fichero_entrada,'Position');%'anchors_paso1.xml'
    
    for h=1:length(tree.TerrainAnchor)
        x(h)=tree.TerrainAnchor(h).Position.ATTRIBUTE.x  ;
        y(h)=tree.TerrainAnchor(h).Position.ATTRIBUTE.y  ;
        z(h)=tree.TerrainAnchor(h).Position.ATTRIBUTE.z  ;
        if h>1
            if (x(h)==x(h-1)) && (z(h)==z(h-1))
                display('Duplicado')
            end
        end
    end
    save '..\anchors.mat' x y z tree;
else
    display('Usando el fichero anchors.mat ya creado...');
    S=load('..\anchors.mat');
    x=S.x;
    y=S.y;
    z=S.z;
end

longitud=length(x);

nac=longitud
save '..\nac.mat' nac

% x=(x(1:longitud/2)+x(longitud/2+1:end))/2;
% y=(y(1:longitud/2)+y(longitud/2+1:end))/2;
% z=(z(1:longitud/2)+z(longitud/2+1:end))/2;
% 
% longitud=length(x);

fid=fopen('salida\anchors_carretera.geo','w');

fprintf(fid,'cl1=20;\ncl2=10;\ncl4=120;\ncl5=200;\ncl3=250;\n');


offset=0;

for u=1:longitud
    fprintf(fid,'Point(%d) = {%f, %f, %f, cl1};\n',offset+u,x(u),z(u),0);
end

for u=1:longitud/2-1
    fprintf(fid,'Line(%d) = {%d, %d};\n',offset+u,offset+u,offset+u+1);
end

fprintf(fid,'Line(%d) = {%d, %d};\n',offset+longitud/2,offset+longitud/2,offset+longitud);

for u=longitud-1:-1:longitud/2+1
    fprintf(fid,'Line(%d) = {%d, %d};\n',offset+longitud+longitud/2-u,offset+u+1,offset+u);
end

fprintf(fid,'Line(%d) = {%d, %d};\n',offset+longitud+1,offset+longitud/2+1,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Malla cercana a la carretera

x=(x(1:longitud/2)+x(longitud/2+1:end))/2;
y=(y(1:longitud/2)+y(longitud/2+1:end))/2;
z=(z(1:longitud/2)+z(longitud/2+1:end))/2;


% x=x(1:1:end);
% y=y(1:1:end);
% z=z(1:1:end);

longitud=length(x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if offset1>0
    display('Generando puntos de apoyo');
    for h=2:length(x)-1
        vector_adelante=[x(h)-x(h-1) 0 z(h)-z(h-1)];
        vector_atras=[x(h)-x(h+1) 0 z(h)-z(h+1)];
        if (norm(vector_adelante)>0) && (norm(vector_atras)>0)
            vector_adelante=vector_adelante/norm(vector_adelante);
            vector_atras=vector_atras/norm(vector_atras);
            
            h
            vector_derecha1=-cross([vector_adelante],[0 1 0]);
            vector_derecha2=+cross([vector_atras],[0 1 0]);
            v_derecha=vector_derecha1+vector_derecha2;
            v_derecha=v_derecha/norm(v_derecha);

            punto_derecha(h,:)=[x(h) 0 z(h)]+separacion*v_derecha;
            punto_derecha1(h,:)=[x(h) 0 z(h)]+separacion*vector_derecha1;
            punto_derecha2(h,:)=[x(h) 0 z(h)]+separacion*vector_derecha2;
            punto_izquierda(h,:)=[x(h) 0 z(h)]-separacion*v_derecha;
            valido(h)=1;
            fprintf(fid,'Point(%d) = {%f, %f, %f, cl2};\n',h*2+offset1,punto_izquierda(h,1),punto_izquierda(h,3),0);
            fprintf(fid,'Point(%d) = {%f, %f, %f, cl2};\n',h*2+offset1+1,punto_derecha(h,1),punto_derecha(h,3),0);
            distancias=sqrt((punto_izquierda(h,1)-x).^2+(punto_izquierda(h,3)-z).^2);
            
            tamlazo=min([h-1 150]); %Buscamos puntos antiguos que est�n m�s pr�ximos al actual que el anterior
            if (h>tamlazo) & (h>5)
                distancias=sqrt((punto_izquierda(h,1)-punto_izquierda(h-tamlazo:h-1,1)).^2+(punto_izquierda(h,3)-punto_izquierda(h-tamlazo:h-1,3)).^2);
                [minimoi(h) posi(h)]=min(distancias);
                if posi(h)~=tamlazo
                    ida(h-tamlazo+posi(h):h)=0; %Borramos todos los puntos hechos desde el punto de cruce hasta aqu�
                    entrepuntos_ida(h-tamlazo+posi(h):h)=0;
                else
                    ida(h)=h*2+offset1;
                    entrepuntos_ida(h)=minimoi(h);
                end
                distancias=sqrt((punto_derecha(h,1)-punto_derecha(h-tamlazo:h-1,1)).^2+(punto_derecha(h,3)-punto_derecha(h-tamlazo:h-1,3)).^2);
                [minimov(h) posv(h)]=min(distancias);
                if posv(h)~=tamlazo
                    vuelta(h-tamlazo+posv(h):h)=0; %Borramos todos los puntos hechos desde el punto de cruce hasta aqu�
                    entrepuntos_vuelta(h-tamlazo+posv(h):h)=0;
                else
                    vuelta(h)=h*2+offset1+1;
                    entrepuntos_vuelta(h)=minimov(h);
                end
            else
                ida(h)=h*2+offset1;
                vuelta(h)=h*2+offset1+1;
                entrepuntos_ida(h)=0;
                entrepuntos_vuelta(h)=0;
            end
        else
            valido(h)=0;
        end
    end
end

%Si los puntos est�n separados menos de 7 metros, son diezmables. Para eso
%sirve entrepuntos

h_final=length(ida);
while ida(h_final)==0
    h_final=h_final-1;
end

h_inicial=1;
while vuelta(h_inicial)==0
    h_inicial=h_inicial+1;
end


diezmado=3;
if offset1>0
    fprintf(fid,'Spline(%d)={',offset1);
    contador_diezmados=0;
    for h=2:h_final-1
        if (ida(h)>0)
            if (contador_diezmados==diezmado) || (entrepuntos_ida(h)>6.5)
                fprintf(fid,'%d, ',ida(h));
                contador_diezmados=0;
            else
                contador_diezmados=contador_diezmados+1
            end
        end

    end
    fprintf(fid,'%d',ida(h_final));
    fprintf(fid,'};\n');

    contador_diezmados=0;
    fprintf(fid,'Spline(%d)={',offset1+1);
    for h=length(x)-1:-1:h_inicial+1
        if vuelta(h)>0
            if (contador_diezmados==diezmado) || (entrepuntos_vuelta(h)>6.5)
                fprintf(fid,'%d, ',vuelta(h));
                contador_diezmados=0;
            else
                contador_diezmados=contador_diezmados+1;
            end
        end

    end
    fprintf(fid,'%d',vuelta(h_inicial));
    fprintf(fid,'};\n');
end

fclose(fid)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
