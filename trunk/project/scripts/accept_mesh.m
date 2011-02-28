function accept_mesh()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

  id_conducible=111;
  id_noconducible=222;
  id_apoyo=333;
if nargin>1
    display('Los Identificadores de las superficies físicas CONDUCIBLE, NO CONDUCIBLE y DE APOYO, deben ser 111, 222 y 333 respectivamente')
    display('Uso: accept_mesh()');
    return;
end
if nargin==0
	usando_plywrite=0;
end

if (exist('..\..\agr')==7) || (exist('..\..\lidar')==7)
	accept_mesh_agr();
	return
end

display('Leyendo datos entrada (nac.mat y salida\anchors_originales.mat)')

S=load('..\nac.mat');
nac=S.nac;

nodos=load('salida\anchors_originales.mat');
x=nodos.datax;
y=double(nodos.datay);
z=nodos.dataz;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
display('Leyendo elements')
%[nada1 nada2 nada3 id_superficie nada5 nada6 n1 n2 n3]=textread('elements.txt','%d %d %d %d %d %d %d %d %d');
fid=fopen('elements.txt');
contents=fread(fid,inf);
fclose(fid);
cadena=char(contents)';
todo=sscanf(cadena,'%d',inf);
numtags=todo(3);
tam_registro=numtags+6;
id_superficie=todo(4:tam_registro:end);
n1=todo((numtags+4):tam_registro:end);
n2=todo((numtags+5):tam_registro:end);
n3=todo((numtags+6):tam_registro:end);
id_particular=todo(5:tam_registro:end);

vertex.x = x';
vertex.y = y';
vertex.z = z';

faces=[n1 n2 n3];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

display('Leyendo ..\anchors.mat')
nodos=load('..\anchors.mat'); 
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nodos_finales=[x;y;z]'; %Punto de partida

display('Remapeamos')

%Remapeamos los nodos para garantizar que los anchors de carretera están al principio y ordenados como deben
%En la posición i de mapeo1 se encontrará el número de nodo final para lo que en el fichero 1 es el nodo i
[mapeo nodos_finales]=remapear([vertex.x;vertex.y;vertex.z]',nodos_finales);

%Con el patrón de remapeo obtenido cambiamos la numeración de los triángulos
new_faces=triangulos_remapeados(mapeo,faces);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% fid=my_fopen('salida\prueba.geo','w')

% for h=1:tamanyo
    % fprintf(fid,'       Point(%d) = {%f, %f, %f, 1};\n',h,x(h),z(h),y(h));
% end
% my_fclose(fid)

system('copy salida\listado_anchors.txt ..\s6_hairpins\salida\.');
system('copy salida\nodos_conaltura.txt ..\s6_hairpins\salida\.');
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

fid=my_fopen('salida\elements.txt','w');
for h=1:length(new_faces)
    fprintf(fid,'%d %d %d %d %d %d %d %d %d\n',h,2,3,id_superficie(h),id_particular(h),0,new_faces(h,1),new_faces(h,2),new_faces(h,3));
end
my_fclose(fid);

fid=my_fopen('salida\elements.txt','r');
contents=fread(fid,inf);
my_fclose(fid);
cadena=char(contents)';

fid=my_fopen('salida\test.msh','w');
fprintf(fid,'$MeshFormat\n2.1 0 8\n$EndMeshFormat\n$Nodes\n');
fprintf(fid,'%d\n',tamanyo);
indices=(1:tamanyo)';
fprintf(fid,'%d %f %f %f\n',[indices x z y]');
fprintf(fid,'$EndNodes\n$Elements\n');
fprintf(fid,'%d\n',length(new_faces));
fprintf(fid,'%s',cadena);
fprintf(fid,'$EndElements');
fclose(fid)

message(11);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    function [mapeo1 nodos_finales]=remapear(Pts1,nodos_finales);
    mapeo1=[];
    for h=1:length(Pts1)
        if mod(h,50)==0
            mensaje=sprintf('%.3f\r',h/length(Pts1));
	    display(mensaje);
        end
        distancias1=abs(Pts1(h,1)-nodos_finales(:,1))+abs(Pts1(h,3)-nodos_finales(:,3));
        [valor pos]=min(distancias1);
        if valor<0.02 %Menos de 2cm-> mismo nodo
            mapeo1(h)=pos;%display(sprintf('%d,',h));
        else
            nodos_finales=[nodos_finales; Pts1(h,:)];
            mapeo1(h)=length(nodos_finales);
        end
    end
    end
	
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
