function procesar_nodostxt(fichero_entrada,conectarse_a_carretera,malla_regular,radio_de_suavizado)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

if nargin<3
    display('Par�metros de entrada:')
    display('1) Fichero que contiene los nodos generados por gmsh (Ej: nodos.txt)');
    display('2) 0 respetar la altura de los anchors del terreno que "coinciden" (separados 0.01) con los de la carretera (saca ese dato de anchors.mat)')    
    display('   1 retocar la altura de los anchors del terreno que coinciden con los de la carretera, seg�n los datos de la monta�a')
    display('3) 1 si los datos de altura vienen en formato cuadr�cula. 0 En otro caso')
    display('4) Radio de suavizado en metros (Ej: 20) a la hora de calcular alturas (si <3 se usa el punto m�s pr�ximo en lugar de suavizado)')
    display(' ');
    display('Adem�s se leen los ficheros nac.mat, anchors.mat y lamalla.mat');    
    display(' ');
    display('Ejemplo: procesar_nodostxt(''nodos.txt'',0,1,20)');    
    display(' ');
    display('Salida:');
    display('-> listado_anchors.txt (es el listado de anchors que se incorporar� tal cual al Venue.xml)');
    display('-> nodos_conaltura.txt (es un listado de nodos y alturas �til para procesar_elementstxt.m)');
    display('-> prueba.geo (archivo que permite comprobar en gmsh que los nodos generados son correctos)');
    return
end
%nac es 7824, el n�mero de anchors en el track

[numero x z y]=textread(fichero_entrada,'%d %f %f %f');

%Los nodos no tienen altura, as� que hay que cargar los datos de los xml
%para interpolar la altura en ese punto de la malla

S=load('..\nac.mat');
nac=S.nac;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[datax datay dataz]=leerloskml();
malla=load('lamalla.mat');
datax=malla.datax;
datay=malla.datay;
dataz=malla.dataz;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%conectarse_a_carretera=0; %Los primeros anchors son los de la carretera. Si nos vamos a conectar a ella directamente (T0 x) no hace falta calcular la altura de esos anchors
                          %Si no supi�ramos conectarnos (Ax) habr�a que calcular
                          %las alturas
                          % conectarse_a_carretera==1 -> Sabemos conectarnos
                          % conectarse_a_carretera==0 -> No sabemos
%radio_de_suavizado=20; %Poner menor que tres para que no haya suavizado


if (conectarse_a_carretera==0)
    display('Respetando altura de anchors pr�ximos a carretera...');
    S=load('..\anchors.mat');
    tree=S.tree;
    %[tree treeName] = xml_read('anchors_paso1.xml');
    for h=1:length(tree.TerrainAnchor) %Para los anchors 
        cx(h)=tree.TerrainAnchor(h).Position.ATTRIBUTE.x  ;
        cy(h)=tree.TerrainAnchor(h).Position.ATTRIBUTE.y  ;
        cz(h)=tree.TerrainAnchor(h).Position.ATTRIBUTE.z  ;
    end
    if malla_regular==1
        y1=interp2(malla.rangox,malla.rangoz,malla.malla_regular,x(nac+1:end),z(nac+1:end));
    else
        y1=consulta_malla_alternativa(x(nac+1:end),z(nac+1:end),datax,datay,dataz,radio_de_suavizado);   %%%%%%%%%%%%%Anchors con altura de carretera
    end
    %La altura de los nac primeros nodos se obtiene a partir de la
    %pendiente (peralte) de la carretera en esos puntos
    %y=[cy(1:nac)'; y1]
    altura_anchors_carretera=dar_altura_nac(cx,cy,cz,nac,0.1);%Por defecto est�n a 10cm de la carretera
    y=[altura_anchors_carretera; y1];
else
    display('Recalculando altura de anchors pr�ximos a carretera...');
    if malla_regular==1
        y=interp2(malla.rangox,malla.rangoz,malla.malla_regular,x,z);
    else
        y=consulta_malla_alternativa(x,z,datax,datay,dataz,radio_de_suavizado);                          %%%%%%%%%%%%%Anchors con altura de monta�a
    end
end

if sum(datay==NaN)>1
    display('Valores err�neos');
    return;
end

tamanyo=length(numero);

fid=fopen('salida\listado_anchors.txt','w');
fid2=fopen('salida\nodos_conaltura.txt','w');

fprintf(fid,'     <TerrainAnchors count="%d">\n',tamanyo);
for h=1:tamanyo
    fprintf(fid,'       <TerrainAnchor>\n         <Position x="%f" y="%f" z="%f" />\n       </TerrainAnchor>\n',x(h),y(h),z(h));
    fprintf(fid2,'%d %f %f %f\n',h,x(h),z(h),y(h));
end
fprintf(fid,'     </TerrainAnchors>\n');

fclose(fid);
fclose(fid2);

fid=fopen('prueba.geo','w')

for h=1:tamanyo
    fprintf(fid,'       Point(%d) = {%f, %f, %f, 1};\n',h,x(h),z(h),y(h));
end

datax=x;
datay=y;
dataz=z;
save('salida\anchors_originales.mat','datax','datay','dataz');

fclose(fid);


function alturas=dar_altura_nac(cx,cy,cz,nac,distancia)
%La posici�n real de los anchors de carretera est� movi�ndose 10cm
%(distancia) hacia el anchor opuesto

for h=1:nac/2
    vector_entrante=[cx(h+nac/2)-cx(h) cz(h+nac/2)-cz(h)];
    unitario_entrante=vector_entrante/norm(vector_entrante);
    x_real(h)=cx(h)+distancia*unitario_entrante(1);
    z_real(h)=cz(h)+distancia*unitario_entrante(2);
end

for h=nac/2+1:nac
    vector_entrante=[cx(h-nac/2)-cx(h) cz(h-nac/2)-cz(h)];
    unitario_entrante=vector_entrante/norm(vector_entrante);
    x_real(h)=cx(h)+distancia*unitario_entrante(1);
    z_real(h)=cz(h)+distancia*unitario_entrante(2);
end

for h=1:nac/2
    vector_saliente=[x_real(h+nac/2)-x_real(h) cy(h+nac/2)-cy(h) z_real(h+nac/2)-z_real(h)];
    unitario_saliente=vector_saliente/norm(vector_saliente);
    %tangente=alturaY/distanciaXZ;
    tangente=unitario_saliente(2)/sqrt(unitario_saliente(1)^2+unitario_saliente(3)^2);
    if tangente~=0
        mensaje=sprintf('El anchor se sube %.3fm',distancia*tangente);
        display(mensaje);
    end
    %altura=distancia*tangente;
    alturas(h)=cy(h)+distancia*tangente;
end

for h=nac/2+1:nac
    vector_saliente=[x_real(h-nac/2)-x_real(h) cy(h-nac/2)-cy(h) z_real(h-nac/2)-z_real(h)];
    unitario_saliente=vector_saliente/norm(vector_saliente);
    %tangente=alturaY/distanciaXZ;
    tangente=unitario_saliente(2)/sqrt(unitario_saliente(1)^2+unitario_saliente(3)^2);
    if tangente~=0
        mensaje=sprintf('El anchor se sube %.3fm',distancia*tangente);
        display(mensaje);
    end
    %altura=distancia*tangente;
    alturas(h)=cy(h)+distancia*tangente;
end

alturas=alturas';