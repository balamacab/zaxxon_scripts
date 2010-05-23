function procesar_elementstxt_mt(partes_x,partes_z,mapear)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

if nargin==0
   partes_x=10;
   partes_z=10;
   mapear=0;
end
   hay_triangulos_pegados=0;

  fichero_de_nodos_con_altura='nodos_conaltura.txt';
  fichero_elements='elements.txt';
  id_conducible=111;
  id_noconducible=222;
  id_apoyo=333;

if hay_triangulos_pegados=='h'
  display('Uso: procesar_elementstxt_mt(partes_x,partes_z)')
  display('Optional paramters are number of cells for the grid')

  display('Salida:');
    display('--> salida\lis.txt ');
    display('--> salida\listado_tracks.txt');
    return;
end

system('del /Q lis_conducibles*.txt');
system('del /Q lis_noconducibles*.txt')

nac=obtener_nac();
%nac es el número de anchors de la carretera
%Si son 7824 la numeración de los enganches de la carretera llega desde 0 hasta
%nac-1=7823

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
    distancia=sqrt((x(h)-datax).^2+(z(h)-dataz).^2);  
    [minimo pos]=min(distancia);
    distancias(h)=minimo;
end


[nada1 nada2 nada3 id_superficie nada5 nada6 n1 n2 n3]=textread(fichero_elements,'%d %d %d %d %d %d %d %d %d');

tamanyo=length(n1);

limite_izquierdo=min(x);
limite_derecho=max(x);
fronterasx=linspace(limite_izquierdo-0.1,limite_derecho+0.1,partes_x+1); %Dividimos los triángulos conducibles en 10 zonas

limite_izquierdo=min(z);
limite_derecho=max(z);
fronterasz=linspace(limite_izquierdo-0.1,limite_derecho+0.1,partes_z+1); %Dividimos los triángulos conducibles en 10 zonas

for k=1:partes_z
	for h=1:partes_x
        g=(k-1)*partes_x+h;
	    nombre_fichero=sprintf('lis_conducibles_%02d-%02d.txt',h,partes_z-k+1);
	    fid_c(g)=fopen(nombre_fichero,'w');
	    nombre_fichero=sprintf('lis_noconducibles_%02d-%02d.txt',h,partes_z-k+1);
	    fid_nc(g)=fopen(nombre_fichero,'w');
	end
end


fid_apoyo=fopen('lis_apoyo.txt','w');

inicio_conducible='      <TerrainArea>\n        <Name>%s</Name>\n        <Selected>False</Selected>\n        <Driveable>True</Driveable>\n        <Collisions>True</Collisions>\n        <Renderable>True</Renderable>\n        <ShadowReceiver>True</ShadowReceiver>\n        <ReceiveLighting>True</ReceiveLighting>\n        <ActAsGround>True</ActAsGround>\n        <AlwaysRender>False</AlwaysRender>\n        <LODIn>0</LODIn>\n        <LODOut>2000</LODOut>\n        <MaterialBlends>\n          <MaterialBlend Material="WP\\Materials\\piedran" BlendingType="AnotherMaterial" BlendMaterial="WP\\Materials\\piedra">\n            <TerrainFaces>\n';

if mapear==1
	%0 es la textura 1_1, 1 es la 1_2, 2 es la 1_3
	inicio_noconducible=strcat('      <TerrainArea>\n        <Name>%s</Name>\n        <Selected>False</Selected>\n        <Driveable>False</Driveable>\n',...
    '	<Collisions>True</Collisions>\n        <Renderable>True</Renderable>\n        <ShadowReceiver>True</ShadowReceiver>\n',...
	'        <ReceiveLighting>True</ReceiveLighting>\n        <ActAsGround>True</ActAsGround>\n        <AlwaysRender>False</AlwaysRender>\n',...
	'        <LODIn>0</LODIn>\n        <LODOut>2000</LODOut>\n',...
	'        <MaterialBlends>\n          <MaterialBlend Material="WP\\Materials\\piedra" BlendingType="BackgroundImage" BlendBackgroundImageId="%d">\n',...
	'            <TerrainFaces>\n');
else
	inicio_noconducible=strcat('      <TerrainArea>\n        <Name>%s</Name>\n        <Selected>False</Selected>\n        <Driveable>False</Driveable>\n',...
    '	<Collisions>True</Collisions>\n        <Renderable>True</Renderable>\n        <ShadowReceiver>True</ShadowReceiver>\n',...
	'        <ReceiveLighting>True</ReceiveLighting>\n        <ActAsGround>True</ActAsGround>\n        <AlwaysRender>False</AlwaysRender>\n',...
	'        <LODIn>0</LODIn>\n        <LODOut>2000</LODOut>\n',...
	'        <MaterialBlends>\n          <MaterialBlend Material="WP\\Materials\\piedra" BlendingType="AnotherMaterial" BlendMaterial="WP\\Materials\\pelado">\n',...
	'            <TerrainFaces>\n');
end
	
for g=1:length(fid_c)
	columna=mod(g-1,partes_x);%Eje x
	fila=floor((g-1)/partes_x);     %Eje z
	nombre=sprintf('Drive %d-%d',columna+1,partes_z-fila);
	fprintf(fid_c(g),inicio_conducible,nombre);
end

for g=1:length(fid_nc)
	columna=mod(g-1,partes_x);%Eje x
	fila=floor((g-1)/partes_x);     %Eje z
	nombre=sprintf('N Drive %d-%d',columna+1,partes_z-fila);
	if mapear==1
		fprintf(fid_nc(g),inicio_noconducible,nombre,columna*partes_z+(partes_z-fila-1));
	else
		fprintf(fid_nc(g),inicio_noconducible,nombre);
	end
end

fprintf(fid_apoyo,inicio_noconducible,'Apoyo');
cuenta_conducibles=0;
cuenta_noconducibles=0;


if hay_triangulos_pegados==1
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

    n1=[n1_c;n1];
    n2=[n2_c;n2];
    n3=[n3_c;n3];
    escarretera=[escarretera;ceros];%Todos los generados se unen a carretera. Los de la malla no se une ninguno
    id_superficie=[identificador;id_superficie];
else
	escarretera=[n1<=nac n2<=nac n3<=nac];
end	

tramos=cargar_tramos();
for h=1:length(n1)
    
    punto_mediox=mean([x(n1(h)) x(n2(h)) x(n3(h))]);
    punto_medioz=mean([z(n1(h)) z(n2(h)) z(n3(h))]);
    
    if length(find(id_conducible==id_superficie(h)))>0
        zonax=sum(punto_mediox>fronterasx);
		zonaz=sum(punto_medioz>fronterasz);
		zona=(zonaz-1)*partes_x+zonax;
        fid=fid_c(zona);
    end
    if length(find(id_noconducible==id_superficie(h)))>0
        zonax=sum(punto_mediox>fronterasx);
		zonaz=sum(punto_medioz>fronterasz);
		zona=(zonaz-1)*partes_x+zonax;
        fid=fid_nc(zona);
    end
    if length(find(id_apoyo==id_superficie(h)))>0
        fid=fid_apoyo;
    end
    
    excepcion=0;


    [anchor1 anchor1B]=obtener_anchor(n1(h)-1,escarretera(h,1),y(n1(h)),distancias(n1(h)),sum(fid==fid_c)>0,tramos,nac);
    [anchor2 anchor2B]=obtener_anchor(n2(h)-1,escarretera(h,2),y(n2(h)),distancias(n2(h)),sum(fid==fid_c)>0,tramos,nac);
    [anchor3 anchor3B]=obtener_anchor(n3(h)-1,escarretera(h,3),y(n3(h)),distancias(n3(h)),sum(fid==fid_c)>0,tramos,nac);

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
	%Los siguientes casos no se dan si se usan los triángulos que dan continuidad a las normales
	if hay_triangulos_pegados==0
         % %Un triángulo no puede tocar ambos lados de la carretera
	    if (anchor1(1)=='T') && (strcmp(anchor1(1:3),anchor2(1:3))==1) && (abs(n1(h)-n2(h))>1),imprimir=0;end;
	    if (anchor2(1)=='T') && (strcmp(anchor2(1:3),anchor3(1:3))==1) && (abs(n2(h)-n3(h))>1),imprimir=0;end;
	    if (anchor1(1)=='T') && (strcmp(anchor1(1:3),anchor3(1:3))==1) && (abs(n1(h)-n3(h))>1),imprimir=0;end;
	end
	
	%Si un triángulo tiene dos anchors que pertenecen a carreteras diferentes, el anchor con numeración 0 debe convertirse en el último anchor de la carretera anterior
	%O equivalentemente el de los dos que tenga numeración alternativa debe emplearla
	if (anchor1(1)=='T') & (anchor2(1)=='T') & (strcmp(anchor1(2:3),anchor2(2:3))==0)
		if abs(str2num(anchor1(2:3))-str2num(anchor2(2:3)))<=1
			imprimir=0;
			if strcmp(anchor1,anchor1B)==0, display(sprintf('%s - %s',anchor1,anchor1B));anchor1=anchor1B; imprimir=1; end
			if strcmp(anchor2,anchor2B)==0, display(sprintf('%s - %s',anchor2,anchor2B));anchor2=anchor2B;  imprimir=1; end
		else
			imprimir=0;
		end
	end
	if (anchor2(1)=='T') & (anchor3(1)=='T') & (strcmp(anchor2(2:3),anchor3(2:3))==0)
		if abs(str2num(anchor2(2:3))-str2num(anchor3(2:3)))<=1
			imprimir=0;
			if strcmp(anchor2,anchor2B)==0, display(sprintf('%s - %s',anchor2,anchor2B));anchor2=anchor2B;  imprimir=1; end
			if strcmp(anchor3,anchor3B)==0, display(sprintf('%s - %s',anchor3,anchor3B));anchor3=anchor3B;  imprimir=1; end
		else
			imprimir=0;
		end
	end
    if (anchor3(1)=='T') & (anchor1(1)=='T') & (strcmp(anchor3(2:3),anchor1(2:3))==0)
		if abs(str2num(anchor3(2:3))-str2num(anchor1(2:3)))<=1
			imprimir=0;
			if strcmp(anchor1,anchor1B)==0, display(sprintf('%s - %s',anchor1,anchor1B));anchor1=anchor1B;  imprimir=1; end
			if strcmp(anchor3,anchor3B)==0, display(sprintf('%s - %s',anchor3,anchor3B));anchor3=anchor3B;  imprimir=1; end
		else
			imprimir=0;	
		end	
	end
	
	%Un triángulo no puede consistir en tres anchors de carretera
	if (anchor1(1)=='T') && (anchor2(1)=='T') && (anchor3(1)=='T'), imprimir=0;end;
    if imprimir==1

        fprintf(fid,'               <TerrainFace %s>\n                 <Anchor0 Props="%s" />\n                 <Anchor1 Props="%s" />\n                 <Anchor2 Props="%s" />\n               </TerrainFace>\n',argumento,anchor1,anchor2,anchor3);
        if sum(fid==fid_c)>0
            cuenta_conducibles=cuenta_conducibles+1;
            if mod(h,10000)==0
                mensaje=sprintf('Cond=%d\n',cuenta_conducibles);
                display(mensaje);
            end
        else
            cuenta_noconducibles=cuenta_noconducibles+1;
            if mod(h,10000)==0
                mensaje=sprintf('NoCond=%d\n',cuenta_noconducibles);
                display(mensaje);
            end
        end
    end
end


final='            </TerrainFaces>\n          </MaterialBlend>\n        </MaterialBlends>\n      </TerrainArea>\n';

for g=1:length(fid_c)
	fprintf(fid_c(g),final);
	fclose(fid_c(g));
end

for g=1:length(fid_nc)
	fprintf(fid_nc(g),final);
	fclose(fid_nc(g));
end

fprintf(fid_apoyo,final);
fclose(fid_apoyo);

system('del lis.txt');

fid=fopen('lis.txt','w');
fprintf(fid,'      <TerrainAreas count="%d">',length(fid_c)+length(fid_nc));
fclose(fid)

system('copy lis.txt+lis_conducibles*.txt+lis_noconducibles*.txt lis.txt/b');

fid=fopen('final.txt','w');
fprintf(fid,'      </TerrainAreas>');
fclose(fid)

system('copy lis.txt+final.txt salida\lis.txt/b');
message(16);

function area=elarea(a,b,c)
area=triangle_area([a;b;c]);
end




    function [anchor anchorB]= obtener_anchor(numero,escarretera,altura,distancia,esconducible,tramos,nac)
        % 0% de mezcla significa todo tierra, 1% todo césped
        altura_inicial=2375; 
        altura_final=2425;
        if altura>altura_final
            porcentaje=1;
        else
            if altura<altura_inicial
                porcentaje=0;
            else
                porcentaje=1-1*(altura_final-altura)/(altura_final-altura_inicial);
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
		else
			porcentaje=0.66;
        end
		anchorB='';
        if escarretera==1
			%display(sprintf('1)%d',numero));
			numero_original=numero;
			if numero_original>=nac/2 %si es de la parte derecha
				numero=numero-nac/2; %Lo "convertimos" momentáneamente en nodo de la parte izquierda
				%display(sprintf('2)%d',numero));
			end
			[track nodo_inicial frontera]=dame_nodo_inicial(numero,tramos); %Este cálculo solo sirve para parte izquierda
			if numero_original>=nac/2 %si es de la parte derecha
				numero=numero+(tramos(track+1,2)-tramos(track+1,1))+1; %Lo devolvemos a la parte derecha
				%display(sprintf('3)%d',numero));
			end
			%display(sprintf('4)%d\n',numero-nodo_inicial));
			anchor=sprintf('T%d %d" P="%.2f',track,numero-nodo_inicial,porcentaje);
			anchorB=anchor; %En los anchors de carretera no conflictivos, anchor y anchorB coinciden
			if frontera==1 
				% anchorB tiene la numeración más alta del track anterior, por si hace falta
				trackb=track-1;
				if numero_original>=nac/2;%Derecha
						anchorB=sprintf('T%d %d" P="%.2f',trackb,2*(tramos(trackb+1,2)-tramos(trackb+1,1))+1,porcentaje);   %último de la derecha del tramo anterior
				else
						anchorB=sprintf('T%d %d" P="%.2f',trackb,(tramos(trackb+1,2)-tramos(trackb+1,1)),porcentaje);		%último de la izquierda	del tramo anterior			
				end
			end
        else
            anchor=sprintf('A%d" P="%.2f',numero,porcentaje);
        end
    end

end

function tramos=cargar_tramos()
	tramos=load('tramos.mat');
	tramos=tramos.tramos;
	longitud_actual=tramos(end,2)+1;
	[numero_sons caminos]=look_for_father_or_sons('..\sons.txt');

	for h=1:numero_sons
		tramos_extra=load(strcat(char(caminos(h)),'\s10_split\tramos.mat'));
		tramos_extra=tramos_extra.tramos;
		longitud=tramos(end,2)+1;
		tramos=[tramos; tramos_extra+longitud];
		tama=size(tramos);
	end		
	save('temporal.mat','tramos');
end

function nac=obtener_nac()
    S=load('..\nac.mat');
    nac=S.nac;
	[numero_sons caminos]=look_for_father_or_sons('..\sons.txt');

	for h=1:numero_sons
		nac_extra=load(strcat(char(caminos(h)),'\nac.mat'));
		nac_extra=nac_extra.nac;
		nac=nac+nac_extra;
	end
	save('temporal2.mat','nac');
end	