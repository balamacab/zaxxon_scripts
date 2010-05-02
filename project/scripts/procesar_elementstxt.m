function procesar_elementstxt(hay_triangulos_pegados)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.


  fichero_de_nodos_con_altura='salida\nodos_conaltura.txt';
  fichero_elements='salida\elements.txt';
  id_conducible=111;
  id_noconducible=222;
  id_apoyo=333;

if hay_triangulos_pegados=='h'
  display('Uso: procesar_elementstxt(0)')
  display('El parámetro indica si queremos pequeños triángulos pegados a la superficie de la carretera (0->no queremos)')

  display('Salida:');
    display('--> salida\lis.txt ');
    return;
end


S=load('..\nac.mat')
nac=S.nac;
%nac es el número de anchors de la carretera
%Si son 7824 la numeración de los enganches de la carretera llega desde 0 hasta
%nac-1=7823

display(sprintf('Leyendo fichero %s',fichero_de_nodos_con_altura));
[numero x y z]=textread(fichero_de_nodos_con_altura,'%d %f %f %f');
temp=y;
y=z;
z=temp;

%Calculamos la distancia de todos los anchors a la carretera. Distancia
%solo en horizontal (considerando x y z)
%Para los nac primeros anchors no se calcula nada, porque son los de la
%carretera
datax=x(1:nac);
dataz=z(1:nac);
distancias=zeros(length(x),1);
for h=nac+1:length(x)
    if mod(h,50)==0
        mensaje=sprintf('%.2f\n',h/length(x));
        display(mensaje);
    end
    distancia=sqrt((x(h)-datax).^2+(z(h)-dataz).^2);  
    [minimo pos]=min(distancia);
    distancias(h)=minimo;
end

display(sprintf('Leyendo fichero %s',fichero_elements));
[nada1 nada2 nada3 id_superficie nada5 nada6 n1 n2 n3]=textread(fichero_elements,'%d %d %d %d %d %d %d %d %d');

tamanyo=length(n1);

fid_cb=fopen('lis_conduciblesb.txt','w');%Hasta 3610 metros la mezcla de texturas es una
fid_ca=fopen('lis_conduciblesa.txt','w');%A partir de los 3610 la mezcla es otra
fid_nc=fopen('lis_noconducibles.txt','w');
fid_apoyo=fopen('lis_apoyo.txt','w');

inicio_conducible_bajos='      <TerrainArea>\n        <Name>%s</Name>\n        <Selected>False</Selected>\n        <Driveable>True</Driveable>\n        <Collisions>True</Collisions>\n        <Renderable>True</Renderable>\n        <ShadowReceiver>True</ShadowReceiver>\n        <ReceiveLighting>True</ReceiveLighting>\n        <ActAsGround>True</ActAsGround>\n        <AlwaysRender>False</AlwaysRender>\n        <LODIn>0</LODIn>\n        <LODOut>2000</LODOut>\n        <MaterialBlends>\n          <MaterialBlend Material="PPPack\\Materials\\ground_tierra002" BlendingType="AnotherMaterial" BlendMaterial="Default\\Materials\\Ground\\Grass\\Grass002">\n            <TerrainFaces>\n';
inicio_conducible_altos='      <TerrainArea>\n        <Name>%s</Name>\n        <Selected>False</Selected>\n        <Driveable>True</Driveable>\n        <Collisions>True</Collisions>\n        <Renderable>True</Renderable>\n        <ShadowReceiver>True</ShadowReceiver>\n        <ReceiveLighting>True</ReceiveLighting>\n        <ActAsGround>True</ActAsGround>\n        <AlwaysRender>False</AlwaysRender>\n        <LODIn>0</LODIn>\n        <LODOut>2000</LODOut>\n        <MaterialBlends>\n          <MaterialBlend Material="PPPack\\Materials\\ground_tierra2048" BlendingType="AnotherMaterial" BlendMaterial="PPPack\\Materials\\montanya">\n            <TerrainFaces>\n';
inicio_noconducible='      <TerrainArea>\n        <Name>%s</Name>\n        <Selected>False</Selected>\n        <Driveable>False</Driveable>\n        <Collisions>True</Collisions>\n        <Renderable>True</Renderable>\n        <ShadowReceiver>True</ShadowReceiver>\n        <ReceiveLighting>True</ReceiveLighting>\n        <ActAsGround>True</ActAsGround>\n        <AlwaysRender>False</AlwaysRender>\n        <LODIn>0</LODIn>\n        <LODOut>2000</LODOut>\n        <MaterialBlends>\n          <MaterialBlend Material="PPPack\\Materials\\montanya" BlendingType="AnotherMaterial" BlendMaterial="PPPack\\Materials\\monte2048">\n            <TerrainFaces>\n';

fprintf(fid_ca,inicio_conducible_altos,'Conducible_alto');
fprintf(fid_cb,inicio_conducible_bajos,'Conducible_bajo');
fprintf(fid_nc,inicio_noconducible,'NoConducible');
fprintf(fid_apoyo,inicio_noconducible,'Apoyo');
cuenta_conducibles=0;
cuenta_noconducibles=0;

%Añado los pequeños triángulos planos pegados a la carretra
% fid_p=fopen('elements_paso1.xml')
% todo=fread(fid_p,inf);
% fclose(fid_p);
% 
% fwrite(fid_c,todo);

%Genero a mano los triángulos que hay en elements_paso1.xml
%por coherencia en la numeración dejo un valor N al que luego hay que
%restarle 1
%escarretera identifica los anchors que son de carretera: "T0 X"
contador=1;
for h=1:nac/2-1
    %T0 0 = A0 = T0 1
    n1_c(contador,1)=h;
    n2_c(contador,1)=h;
    n3_c(contador,1)=h+1;
    escarretera(contador,:)=[1 0 1];
    contador=contador+1;
    %A0 = T0 1 = A1
    n1_c(contador,1)=h;
    n2_c(contador,1)=h+1;
    n3_c(contador,1)=h+1;
    escarretera(contador,:)=[0 1 0];
    contador=contador+1;    
end
   
for h=nac/2+1:nac-1
    %T0 0 = A0 = T0 1
    n1_c(contador,1)=h;
    n2_c(contador,1)=h;
    n3_c(contador,1)=h+1;
    escarretera(contador,:)=[1 0 1];
    contador=contador+1;
    %A0 = T0 1 = A1
    n1_c(contador,1)=h;
    n2_c(contador,1)=h+1;
    n3_c(contador,1)=h+1;
    escarretera(contador,:)=[0 1 0];
    contador=contador+1;    
end

ceros=zeros(length(n1),3);
identificador=ones(length(n1_c),1)*id_conducible; %Los nodos pegados a la carretera son conducibles

%Unimos los triángulos recién generados y los que vienen de elements.txt

if hay_triangulos_pegados==1
    n1=[n1_c;n1];
    n2=[n2_c;n2];
    n3=[n3_c;n3];
    escarretera=[escarretera;ceros];%Todos los generados se unen a carretera. Los de la malla no se une ninguno
    id_superficie=[identificador;id_superficie];
else
	escarretera=[n1<=nac n2<=nac n3<=nac];%Está por comprobar que dimensionalmente es así
end	



for h=1:length(n1)
    
    punto_medio=mean([y(n1(h)) y(n2(h)) y(n3(h))]);
    
    if length(find(id_conducible==id_superficie(h)))>0
        if punto_medio<3600
            fid=fid_cb;
        else
            fid=fid_ca;
        end
    end
    if length(find(id_noconducible==id_superficie(h)))>0
        fid=fid_nc;
    end
    if length(find(id_apoyo==id_superficie(h)))>0
        fid=fid_apoyo;
    end
    
    excepcion=0;

    %if ((n1(h)==1)||(n2(h)==1)||(n3(h)==1))
    %    fprintf('No va')
    %end
    anchor1=obtener_anchor(n1(h)-1,escarretera(h,1),y(n1(h)),distancias(n1(h)),(fid==fid_ca)||(fid==fid_cb));
    anchor2=obtener_anchor(n2(h)-1,escarretera(h,2),y(n2(h)),distancias(n2(h)),(fid==fid_ca)||(fid==fid_cb));
    anchor3=obtener_anchor(n3(h)-1,escarretera(h,3),y(n3(h)),distancias(n3(h)),(fid==fid_ca)||(fid==fid_cb));
    if (anchor1(1)=='T')
        if n1(h)<=nac/2
            argumento='LR="Left"';
        else
            argumento='LR="Right"';
        end
    else 
        if (anchor2(1)=='T')
            if n2(h)<=nac/2
                argumento='LR="Left"';
            else
                argumento='LR="Right"';
            end
        else
            if (anchor3(1)=='T')
                if n3(h)<=nac/2
                    argumento='LR="Left"';
                else
                    argumento='LR="Right"';
                end
            else
                argumento='Selected="False"';
            end
        end
    end
	imprimir=1;
	%Un triángulo no puede tocar ambos lados de la carretera
	if (anchor1(1)=='T') && (anchor2(1)=='T') && (n1(h)<=nac/2) && (n2(h)>nac/2),imprimir=0;end;
    if (anchor2(1)=='T') && (anchor1(1)=='T') && (n2(h)<=nac/2) && (n1(h)>nac/2),imprimir=0;end;
	if (anchor2(1)=='T') && (anchor3(1)=='T') && (n2(h)<=nac/2) && (n3(h)>nac/2),imprimir=0;end;
	if (anchor3(1)=='T') && (anchor2(1)=='T') && (n3(h)<=nac/2) && (n2(h)>nac/2),imprimir=0;end;
	if (anchor1(1)=='T') && (anchor3(1)=='T') && (n1(h)<=nac/2) && (n3(h)>nac/2),imprimir=0;end;
	if (anchor3(1)=='T') && (anchor1(1)=='T') && (n3(h)<=nac/2) && (n1(h)>nac/2),imprimir=0;end;

	%Un triángulo no puede consistir en tres anchors de carretera
	if (anchor1(1)=='T') && (anchor2(1)=='T') && (anchor3(1)=='T'), imprimir=0;end;
	
    if imprimir==1

        fprintf(fid,'               <TerrainFace %s>\n                 <Anchor0 Props="%s" />\n                 <Anchor1 Props="%s" />\n                 <Anchor2 Props="%s" />\n               </TerrainFace>\n',argumento,anchor1,anchor2,anchor3);
        if (fid==fid_ca) || (fid==fid_cb)
            cuenta_conducibles=cuenta_conducibles+1;
            if mod(h,200)==0
                mensaje=sprintf('Cond=%d\n',cuenta_conducibles);
                display(mensaje);
            end
        else
            cuenta_noconducibles=cuenta_noconducibles+1;
            if mod(h,200)==0
                mensaje=sprintf('NoCond=%d\n',cuenta_noconducibles);
                display(mensaje);
            end
        end
    end
end


final='            </TerrainFaces>\n          </MaterialBlend>\n        </MaterialBlends>\n      </TerrainArea>\n';
fprintf(fid_cb,final);
fprintf(fid_ca,final);
fprintf(fid_nc,final);
fprintf(fid_apoyo,final);

fclose(fid_ca);
fclose(fid_cb);
fclose(fid_nc);
fclose(fid_apoyo);

system('del lis.txt');

fid=fopen('lis.txt','w');
fprintf(fid,'      <TerrainAreas count="%d">',3);
fclose(fid)

system('copy lis.txt+lis_conduciblesa.txt+lis_conduciblesb.txt+lis_noconducibles.txt lis.txt/b');

fid=fopen('final.txt','w');
fprintf(fid,'      </TerrainAreas>');
fclose(fid)

system('copy lis.txt+final.txt salida\lis.txt/b');


function area=elarea(a,b,c)
area=triangle_area([a;b;c]);
end



%     function porcentaje=mezclado_por_altura(altura)
%         %de 2800 a 4300 metros
%         %de 0 a .95+()        
%         porcentaje=0.95-0.95*(4300-altura)/(4300-2800);
%         %porcentaje=0;
%     end

    function anchor = obtener_anchor(numero,escarretera,altura,distancia,esconducible)
        % 0% de mezcla significa todo tierra, 1% todo césped
        altura_inicial=375; %según los mapas de altura del Pikes Peak a partir de los 3610 metros ya no hay vegetación
        altura_final=425;
        if altura>altura_final
            porcentaje=0;
        else
            if altura<altura_inicial
                porcentaje=1;
            else
                porcentaje=0+1*(altura_final-altura)/(altura_final-altura_inicial);
            end
        end

        if esconducible==1 % En la zona conducible pasamos de 0 a 1 entre los metros de distancia 5 y 10
            porcentaje=1; %CAMBIO: SI ES CONDUCIBLE NO HACEMOS CASO DE LA ALTURA
            if distancia<5
                porcentaje=0;
            else if distancia>10
                    porcentaje=1*porcentaje; %No más césped que el que corresponda por altura
                else %Entre 10 y 20 metros
                    porcentaje=0+porcentaje*(distancia-5)/5; %No más césped que el que corresponda por altura
                end
            end
        end
        if escarretera==1
            anchor=sprintf('T0 %d" P="%.2f',numero,porcentaje);
        else
            anchor=sprintf('A%d" P="%.2f',numero,porcentaje);
        end
    end

end
