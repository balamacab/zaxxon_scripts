function  poner_muro(fichero_de_nodos,fichero_elements,id_conducible,id_noconducible,val_pred)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

altura_cambio=2675;
if nargin<5
    display('Parámetros:');
    display('1) Fichero de nodos/anchors de esos nodos (Ej: nodos_conaltura.txt');
    display('2) Fichero de elementos generado por gmsh (Ej: elements.txt');
    display('3) Número del grupo físico de elements    conducibles. Aparece en la 4ª columna del listado de elements (Ej: 111)');
    display('4) Número del grupo físico de elements NO conducibles. Aparece en la 4ª columna del listado de elements (Ej: 222)');
    display('5) Metros que avanza el predictor buscando el siguiente nodo. Ajustar hasta conseguir 0 omisiones');
    display(' ');
    display('Ejemplo: poner_muro(''nodos_conaltura.txt'',''elements.txt'',111,222,14)');
    display(' ');
    display('Salida: listado de nodos que deben definir el muro');
    display('--> salida/muro1.txt salida/muro2.txt');
    return;
end

[numero x z y]=textread(fichero_de_nodos,'%d %f %f %f');

[nada1 nada2 nada3 id_superficie nada5 nada6 n1 n2 n3]=textread(fichero_elements,'%d %d %d %d %d %d %d %d %d');

%trisurf([n1 n2 n3],x,y,z)
%trisurf([n1(find(id_superficie==id_noconducible)) n2(find(id_superficie==id_noconducible)) n3(find(id_superficie==id_noconducible))], x, y ,z);
malla1=zeros(1,length(numero));
malla2=zeros(1,length(numero));

%Marcamos qué nodos forman parte de la parte interna y externa del muro
for h=1:length(n1)
    if id_conducible==id_superficie(h)
        malla1(n1(h))=1;
        malla1(n2(h))=1;
        malla1(n3(h))=1;
    end
    if id_noconducible==id_superficie(h)
        malla2(n1(h))=1;
        malla2(n2(h))=1;
        malla2(n3(h))=1;
    end
end

interseccion=(malla1+malla2==2)
nodos_interseccion=numero(find(interseccion==1)); %Listado desordenado de los nodos que forman parte de ambas mallas

%A efectos de comprobación generamos un par de ficheros para gmsh
fid=fopen('salida\malla2.geo','w');
for h=1:length(malla1)
    if malla1(h)==1
        fprintf(fid,'Point(%d) = {%f, %f, %f, 20};\n',h+30000,x(h),y(h),z(h));
    end
end
fclose(fid);

fid=fopen('salida\malla1.geo','w');
for h=1:length(malla2)
    if malla2(h)==1
        fprintf(fid,'Point(%d) = {%f, %f, %f, 20};\n',h,x(h),y(h),z(h));
    end
end
fclose(fid);

fid=fopen('salida\interseccion.geo','w');
for h=1:length(nodos_interseccion)
    nodo=nodos_interseccion(h);
    fprintf(fid,'Point(%d) = {%f, %f, %f, 20};\n',nodo,x(nodo),y(nodo),z(nodo));
end
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Empezamos por uno y los ordenamos según su proximidad
aceptado=ordenar(nodos_interseccion,x,y,z,val_pred)

visible_anterior=sign(y(aceptado(1)));
for h=2:length(aceptado)
    visibilidad=sign(y(aceptado(h))-altura_cambio); %Si es positivo, es invisible
    if visibilidad>visible_anterior    %A partir de cambio 1 es invisible
        cambio1=h;
    end
    if visibilidad<visible_anterior 
        cambio2=h;                     %A partir de cambio2 es visible
    end
    visible_anterior=visibilidad;
end

if cambio1>cambio2
    invisible=[aceptado(cambio1:end) aceptado(1:cambio2)];
    visible=aceptado(cambio2:cambio1);
else
    invisible=aceptado(cambio1:cambio2);
    visible=[aceptado(cambio2:end) aceptado(1:cambio1)];
end


fid=fopen('salida\visibles.geo','w');
for h=1:length(visible)
    fprintf(fid,'Point(%d) = {%f, %f, %f, 20};\n',visible(h),x(visible(h)),0,z(visible(h)));
    if h>1
         fprintf(fid,'Line(%d) = {%d, %d};\n',h,visible(h),visible(h-1));
     end
end

fclose(fid);

% fid=fopen('inicio_muro.txt','r');
% inicio=fscanf(fid,'%s',inf);
% fclose(fid)

inicio1=strcat(...
'    <Wall RandomSeed="1118946147">\n',...
'      <Name>Wall%d</Name>\n',...
'      <Collisions>True</Collisions>\n',...
'      <ShadowReceiver>False</ShadowReceiver>\n',...
'      <ReceiveLighting>False</ReceiveLighting>\n',...
'      <Grounded>False</Grounded>\n',...
'      <IsTreeWall>True</IsTreeWall>',...
'      <nodes count="%d">\n',...
'        <OnlyOneNodeSelected>-1</OnlyOneNodeSelected>\n',...
'        <LineType>Straight</LineType>\n');

inicio2=strcat(...
'    <Wall RandomSeed="1118946147">\n',...
'      <Name>Wall%d</Name>\n',...
'      <nodes count="%d">\n',...
'        <OnlyOneNodeSelected>-1</OnlyOneNodeSelected>\n',...
'        <LineType>Straight</LineType>\n');

fid=fopen('final_muro1.txt','r');
final1=fread(fid,inf);
fclose(fid)

fid=fopen('final_muro2.txt','r');
final2=fread(fid,inf);
fclose(fid)

tam_wall=25; %Cada tam_wall nodos, un muro nuevo

fid=fopen('salida\muros.txt','w')
fprintf(fid,'  <Walls count="%d">\n',ceil(length(visible)/tam_wall)+ceil(length(invisible)/tam_wall));

contador=imprimir(fid,visible,x,y,z,inicio1,final1,tam_wall,0);
imprimir(fid,invisible,x,y,z,inicio2,final2,tam_wall,contador);

fprintf(fid,'  </Walls>\n');
fclose(fid);


function contador_ficheros=imprimir(fid,aceptado,x,y,z,inicio,final,tam_wall,contador_ficheros);

fprintf(fid,inicio,contador_ficheros,min(length(aceptado),tam_wall));
contador_ficheros=contador_ficheros+1;

cont_nodos=0;
for h=1:length(aceptado)
    imprimir=1;
    if h>1
        punto_a_punto(h)=norm([x(aceptado(h))-x(aceptado(h-1)) z(aceptado(h))-z(aceptado(h-1))]);
        if punto_a_punto(h)>30
            imprimir=0;
            fprintf(1,'Omitiendo punto en (%f,%f)\n',x(aceptado(h)),z(aceptado(h)));
        end
    end
    if imprimir==1
        fprintf(fid,'         <node NodeId="%d">\n           <Position x="%f" y="%f" z="%f" />\n',mod(cont_nodos,tam_wall),x(aceptado(h)),y(aceptado(h)),z(aceptado(h)));
        fprintf(fid,'           <ControlPoints AngleXZ="0" AngleY="0" EntryDistance="0" ExitDistance="0" />\n         </node>\n');
        cont_nodos=cont_nodos+1;
    end
    if (mod(cont_nodos,tam_wall)==0) && (length(aceptado)>h) %Si llevamos un múltiplo de tam_wall y todavía quedan, iniciamos un nuevo muro
        fwrite(fid,final);
        fprintf(fid,inicio,contador_ficheros,min(length(aceptado)-h+1,tam_wall));
        contador_ficheros=contador_ficheros+1;  
        cont_nodos=0;
        %El último nodo del anterior se repite en el nuevo
        fprintf(fid,'         <node NodeId="%d">\n           <Position x="%f" y="%f" z="%f" />\n',mod(cont_nodos,tam_wall),x(aceptado(h)),y(aceptado(h))-0.1,z(aceptado(h)));
        fprintf(fid,'           <ControlPoints AngleXZ="0" AngleY="0" EntryDistance="0" ExitDistance="0" />\n         </node>\n');
        cont_nodos=cont_nodos+1;
    end
end
fwrite(fid,final);



function aceptado=ordenar(nodos_interseccion,x,y,z,val_pred);
aceptado=zeros(1,length(nodos_interseccion));
usado=zeros(1,length(nodos_interseccion));
aceptado(1)=nodos_interseccion(1);
usado(1)=1;
actual=1;
while sum(aceptado>0)<length(aceptado)
    actual
    resto_nodos=nodos_interseccion(find(usado==0));
    if actual==1
        prediccion_x=x(aceptado(actual));
        prediccion_z=z(aceptado(actual));
    else
        vector_pred=[x(aceptado(actual))-x(aceptado(actual-1)) z(aceptado(actual))-z(aceptado(actual-1))];
        vector_pred=val_pred*vector_pred/norm(vector_pred);
        prediccion_x=x(aceptado(actual))+vector_pred(1);
        prediccion_z=z(aceptado(actual))+vector_pred(2);
    end
    distancias=sqrt((prediccion_x-x(resto_nodos)).^2+(prediccion_z-z(resto_nodos)).^2);
    actual=actual+1;
    [valor pos]=min(distancias)
    aceptado(actual)=resto_nodos(pos);
    
    usado(find(nodos_interseccion==aceptado(actual)))=1;
end

%         <node NodeId="0">
%           <Position x="-222.805" y="20" z="-46.68546" />
%           <ControlPoints AngleXZ="0" AngleY="0" EntryDistance="0" ExitDistance="0" />
%         </node>
%         <node NodeId="1">
%           <Position x="-189.8579" y="20" z="-51.52835" />
%           <ControlPoints AngleXZ="0" AngleY="0" EntryDistance="0" ExitDistance="0" />
%         </node>


