function juntar_mallas()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.


fichero1='salida\i.ply';
id1=111;
fichero2='salida\c.ply';
id2=111;
fichero3='salida\n.ply';
id3=222;
%fichero4='salida\a.ply'
%id4=333;

if nargin>0
    display('Uso: juntar_mallas()');	
    display('Se van a juntar los ficheros i.ply, c.ply y n.ply que hay en el directorio salida')
    return;
end

nargin=6;

display('Leemos ficheros')

S=load('..\nac.mat');
nac=S.nac;

%Cargamos los anchors que van junto a la carretera. Su numeración es
%intocable
display('Leyendo ..\anchors.mat')
nodos=load('..\anchors.mat'); %Antes ponía ..\anchors.mat, pero entonces la altura siempre es la de la carretera, no puede ser la de la montaña
x=nodos.x(1:nac);
x_izquierda=x(1:nac/2);
x_derecha=x(nac/2+1:end);
y=double(nodos.y(1:nac));
y_izquierda=y(1:nac/2);
y_derecha=y(nac/2+1:end);
z=nodos.z(1:nac);
z_izquierda=z(1:nac/2);
z_derecha=z(nac/2+1:end);

[numero_sons caminos]=look_for_father_or_sons('..\sons.txt');

for h=1:numero_sons
	nodos_extra=load(strcat(char(caminos(h)),'\anchors.mat'));
	nac=length(nodos_extra.x);
	x_extra=nodos_extra.x;
	x_extra_izquierda=x_extra(1:nac/2);
    x_extra_derecha=x_extra(nac/2+1:end);
    y_extra=double(nodos_extra.y);
	y_extra_izquierda=y_extra(1:nac/2);
    y_extra_derecha=y_extra(nac/2+1:end);
    z_extra=nodos_extra.z;
	z_extra_izquierda=z_extra(1:nac/2);
    z_extra_derecha=z_extra(nac/2+1:end);
	
	x_izquierda=[x_izquierda x_extra_izquierda];
	x_derecha=[x_derecha x_extra_derecha];
	y_izquierda=[y_izquierda y_extra_izquierda];
	y_derecha=[y_derecha y_extra_derecha];
	z_izquierda=[z_izquierda z_extra_izquierda];
	z_derecha=[z_derecha z_extra_derecha];
end	
x=[x_izquierda x_derecha];
y=[y_izquierda y_derecha];
z=[z_izquierda z_derecha];

display('Leemos ficheros')

display('1');
[tri1,Pts1] = mileer(fichero1,'tri');

display('2');
[tri2,Pts2] = mileer(fichero2,'tri');

if nargin==6
    display('3');
    [tri3,Pts3] = mileer(fichero3,'tri');
end

if nargin==8
    display('4');
    [tri4,Pts4] = mileer(fichero4,'tri');
end

nodos_finales=[x;y;z]'; %Punto de partida

display('Remapeamos')

%En la posición i de mapeo1 se encontrará el número de nodo final para lo que en el fichero 1 es el nodo i

[mapeo1 nodos_finales]=remapear(Pts1,nodos_finales);
[mapeo2 nodos_finales]=remapear(Pts2,nodos_finales);

if nargin==6
    [mapeo3 nodos_finales]=remapear(Pts3,nodos_finales);
end
if nargin==8
    [mapeo4 nodos_finales]=remapear(Pts4,nodos_finales);
    %save('mezclado.mat','nodos_finales','mapeo1','mapeo2','mapeo3','mapeo4');
else
    %save('mezclado.mat','nodos_finales','mapeo1','mapeo2','mapeo3');
end

display('Generando los triángulos')

%Triángulos conducibles Pts1 y Pts2
Ntri1=triangulos_remapeados(mapeo1,tri1);
Ntri2=triangulos_remapeados(mapeo2,tri2);

if nargin==6
    Ntri3=triangulos_remapeados(mapeo3,tri3);
else
    Ntri3=[];
end

if nargin==8
    Ntri4=triangulos_remapeados(mapeo4,tri4);
else
    Ntri4=[];
end

Ntri=[Ntri1;Ntri2;Ntri3;Ntri4];

%figure, trisurf ( Ntri, nodos_finales(:,1), nodos_finales(:,2), nodos_finales(:,3) );

Ntri_c=[Ntri1;Ntri2]; %Los dos primeros deben ser obligatoriamente los conducibles

display('Grabamos ficheros')

data1=Ntri_c(:,1);
data2=Ntri_c(:,2);
data3=Ntri_c(:,3);
save('salida\conducibles_originales.mat','data1','data2','data3');

datax=nodos_finales(:,1);
datay=nodos_finales(:,2);
dataz=nodos_finales(:,3);
save('salida\anchors_originales.mat','datax','datay','dataz');


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

x=nodos_finales(:,1);
y=nodos_finales(:,2);
z=nodos_finales(:,3);
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

fid=my_fopen('salida\prueba.geo','w')

for h=1:tamanyo
    fprintf(fid,'       Point(%d) = {%f, %f, %f, 1};\n',h,x(h),z(h),y(h));
end

my_fclose(fid)

system('copy salida\listado_anchors.txt ..\s6_hairpins\salida\.');
system('copy salida\nodos_conaltura.txt ..\s6_hairpins\salida\.');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

fid=my_fopen('salida\elements.txt','w');
for h=1:length(Ntri)
    if h<=length(Ntri1)
        id=id1;
    else if h<=(length(Ntri1)+length(Ntri2))
            id=id2;
        else if h<=(length(Ntri1)+length(Ntri2)+length(Ntri3))
                id=id3;
            else
                id=id4;
            end
        end
    end
    fprintf(fid,'%d %d %d %d %d %d %d %d %d\n',h,0,0,id,0,0,Ntri(h,1),Ntri(h,2),Ntri(h,3));
end
my_fclose(fid);

message(11);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

    function [mapeo1 nodos_finales]=remapear(Pts1,nodos_finales);
    mapeo1=[];
    for h=1:length(Pts1)
        if mod(h,5000)==0
            mensaje=sprintf('%.3f\r',h/length(Pts1));
	    display(mensaje);
        end
        distancias1=abs(Pts1(h,1)-nodos_finales(:,1))+abs(Pts1(h,3)-nodos_finales(:,3));
        [valor pos]=min(distancias1);
        if valor<0.02 %Menos de 2cm-> mismo nodo
            mapeo1(h)=pos;
        else
            nodos_finales=[nodos_finales; Pts1(h,:)];
            mapeo1(h)=length(nodos_finales);
        end
    end
    end

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
    
    function Ntri1=triangulos_remapeados(mapeo1,tri1);
         dim1=size(tri1);
		 dim1=dim1(1);
         rango=1:dim1;
         Ntri1=[mapeo1(tri1(rango,1))' mapeo1(tri1(rango,2))' mapeo1(tri1(rango,3))'];
         %for h=1:length(tri1)
         %   Ntri1(h,:)=[mapeo1(tri1(h,1)) mapeo1(tri1(h,2)) mapeo1(tri1(h,3))];
         %end
    end


end
