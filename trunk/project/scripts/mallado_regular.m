function mallado_regular(separacion,ndivisiones,B)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

  fichero_entrada='..\Venue\anchors_s1.xml';

  if (nargin<2)||(separacion=='h')
    display('mallado_regular(12,3)');
    display('mallado_regular(12,3,7)');
    display('Arguments: width of driveable zone in meters, number of panels for that zone, size of regular meshes');
    return;
end

if nargin==2
	B=inf;
end

%[numero_hijos caminos]=look_for_father_or_sons('..\sons.txt');

display('Usando el fichero anchors.mat ya creado...');
S=load('..\anchors.mat');
x=S.x;
y=S.y;
z=S.z;

longitud=length(x); nac=longitud;
save '..\nac.mat' nac;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fid=my_fopen('salida\anchors_carretera.geo','w');
fid2=my_fopen('salida\phys111.txt','w');
fprintf(fid,'cl1=20;\ncl2=10;\ncl4=120;\ncl5=200;\ncl3=250;\n');

fprintf(fid,'offsetp=newreg-1;\n');

for u=1:longitud
    fprintf(fid,'Point(offsetp+%d) = {%f, %f, %f, cl1};\n',u,x(u),z(u),0);
end

for u=1:longitud/2-1
    fprintf(fid,'Line(offsetp+%d) = {offsetp+%d, offsetp+%d};\n',u+1,u,u+1);
end

for u=longitud/2+1:longitud-1
    fprintf(fid,'Line(offsetp+%d) = {offsetp+%d, offsetp+%d};\n',u+1,u,u+1);
end

fprintf(fid,'Line(offsetp+%d) = {offsetp+%d, offsetp+%d};\n',longitud+2,longitud/2,longitud);
fprintf(fid,'Line(offsetp+%d) = {offsetp+%d, offsetp+%d};\n',longitud+3,longitud/2+1,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ida=ones(nac,1);
vuelta=ones(nac,1);

    display('Generando puntos de apoyo');
    for h=1:nac/2
        vector_derecha=[x(h+nac/2)-x(h) 0 z(h+nac/2)-z(h)]; %Derecha menos izquierda -> va hacia la derecha
        vector_derecha=vector_derecha/norm(vector_derecha);
        punto_izquierda(h,:)=[x(h) 0 z(h)]-separacion*vector_derecha;
        punto_derecha(h,:)=[x(h+nac/2) 0 z(h+nac/2)]+separacion*vector_derecha;
	end
	
	%Recorremos la parte izquierda buscando lazos
    ida=busca_lazos(punto_izquierda);
	
	%Recorremos la parte derecha buscando lazos
	vuelta=busca_lazos(punto_derecha);
    

%Unimos los puntos que pueden ponerse con transfinite
fprintf(fid,'offset_a=newp+2;\r\n');
for h=1:nac/2
	fprintf(fid,'Point(offset_a+%d) = {%f, %f, %f, cl2};\n',h,punto_izquierda(h,1),punto_izquierda(h,3),0);        
	if (h>1) && (ida(h)==1) && (ida(h-1)==1)
		fprintf(fid,'Line(offset_a+%d) = {offset_a+%d,offset_a+%d};\n',h,h-1,h);
	end	
end

for h=1:nac/2
	fprintf(fid,'Point(offset_a+%d) = {%f, %f, %f, cl2};\n',h+nac/2,punto_derecha(h,1),punto_derecha(h,3),0);
	if h>1	&& (vuelta(h)==1) && (vuelta(h-1)==1)
		fprintf(fid,'Line(offset_a+%d) = {offset_a+%d,offset_a+%d};\n',h+nac/2,h-1+nac/2,h+nac/2);
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

contador=1;
empieza_regular=1;
empieza_irregular=-1;

cambios=diff(ida); % 0->1, aparecerá un 1 que debe ser movido hacia la derecha. 1->0 saldrá un -1, que debe quedarse donde está

frontera=zeros(nac/2,1);
frontera(find(cambios==1)+1)=empieza_regular;
frontera(find(cambios==-1))=empieza_irregular;
if length(ida)>5
	if sum(ida(1:5))==5
		frontera(1)=empieza_regular;	
	else
		frontera(1)=empieza_irregular;	
	end
else
		frontera(1)=empieza_regular;	
end	
frontera(end)=empieza_irregular;%da igual

frontera=inserta_divisiones(frontera,B);

cambios=find(abs(frontera)>0);

%Unimos (transversalmente) los puntos quedaron en los extremos de los lazos eliminados con sus correspondientes anchors de carretera

fprintf(fid,'Ntra=newl;\r\n');
for h=1:length(cambios)
  poner_division(fid,h,cambios(h),ndivisiones);
end

id_offset=sprintf('%05d',10000*rand());
fprintf(fid,'Nsup%s=news;\r\n',id_offset);
for h=1:length(cambios)-1
	if frontera(cambios(h))==empieza_regular %Entramos en una zona regular
		malla_regular(fid,cambios(h),cambios(h+1),h,contador,id_offset);
	else                                           %Entramos en una zona irregular
		malla_irregular(fid,cambios(h),cambios(h+1),h,contador,id_offset);
	end
	listado_superficies(contador)=contador;
	contador=contador+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cambios=diff(vuelta); % 0->1, aparecerá un 1 que debe ser movido hacia la derecha. 1->0 saldrá un -1, que debe quedarse donde está

frontera=zeros(nac/2,1);
frontera(find(cambios==1)+1)=empieza_regular;
frontera(find(cambios==-1))=empieza_irregular;
if length(vuelta)>5
	if sum(vuelta(1:5))==5
		frontera(1)=empieza_regular;	
	else
		frontera(1)=empieza_irregular;	
	end
else
		frontera(1)=empieza_regular;	
end	
frontera(end)=empieza_irregular;

frontera=inserta_divisiones(frontera,B);

cambios=find(abs(frontera)>0);

%Unimos (transversalmente) los puntos quedaron en los extremos de los lazos eliminados con sus correspondientes anchors de carretera
fprintf(fid,'Ntra=newl;\r\n');
for h=1:length(cambios)
  poner_division(fid,h,cambios(h)+nac/2,ndivisiones);
end

for h=1:length(cambios)-1
	if frontera(cambios(h))==empieza_regular
		malla_regular(fid,cambios(h)+nac/2,cambios(h+1)+nac/2,h,contador,id_offset);
	else
		malla_irregular(fid,cambios(h)+nac/2,cambios(h+1)+nac/2,h,contador,id_offset);
	end
	listado_superficies(contador)=contador;
	contador=contador+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

punto_extremoA=[punto_izquierda(1,1) punto_izquierda(1,3)]+[(punto_izquierda(1,1)-punto_izquierda(2,1)) (punto_izquierda(1,3)-punto_izquierda(2,3))];
punto_extremoB=[punto_izquierda(nac/2,1) punto_izquierda(nac/2,3)]+[(punto_izquierda(nac/2,1)-punto_izquierda(nac/2-1,1)) (punto_izquierda(nac/2,3)-punto_izquierda(nac/2-1,3))];
punto_extremoC=[punto_derecha(1,1) punto_derecha(1,3)]+[(punto_derecha(1,1)-punto_derecha(2,1)) (punto_derecha(1,3)-punto_derecha(2,3))];
punto_extremoD=[punto_derecha(nac/2,1) punto_derecha(nac/2,3)]+[(punto_derecha(nac/2,1)-punto_derecha(nac/2-1,1)) (punto_derecha(nac/2,3)-punto_derecha(nac/2-1,3))];

fprintf(fid,'p1=newp;Point (p1) = {%f, %f, %f, cl2};\n',punto_extremoA(1),punto_extremoA(2),0);%Extremo izquierdo inicial
fprintf(fid,'p2=newp;Point (p2) = {%f, %f, %f, cl2};\n',punto_extremoC(1),punto_extremoC(2),0);%Extremo derecho inicial
fprintf(fid,'l1=newl;Line (l1) = {p1,p2};\n');
fprintf(fid,'l2=newl;Line (l2) = {p1,offset_a+%d};\n',1);
fprintf(fid,'l3=newl;Line (l3) = {p2,offset_a+%d};\n',nac/2+1);


fprintf(fid,'p1=newp;Point (p1) = {%f, %f, %f, cl2};\n',punto_extremoB(1),punto_extremoB(2),0);%Extremo izquierdo final
fprintf(fid,'p2=newp;Point (p2) = {%f, %f, %f, cl2};\n',punto_extremoD(1),punto_extremoD(2),0);%Extremo derecho final
fprintf(fid,'l1=newl;Line (l1) = {p1,p2};\n');
fprintf(fid,'l2=newl;Line (l2) = {p1,offset_a+%d};\n',nac/2);
fprintf(fid,'l3=newl;Line (l3) = {p2,offset_a+%d};\n',nac);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%fprintf(fid,'Physical Surface (111)={')
for g=1:length(listado_superficies)-1
	fprintf(fid2,'Nsup%s+%d,',id_offset,listado_superficies(g));
end
fprintf(fid2,'Nsup%s+%d',id_offset,listado_superficies(end));


my_fclose(fid)
my_fclose(fid2)

message(18);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function malla_regular(fid,inicio,final,linea_izda,id_superficie,id_offset)
		linea_dcha=linea_izda+1;
		
		puntoIA=inicio; %Punto de apoyo, arriba a la izquierda
		puntoDA=final;  %Punto de apoyo, arriba a la derecha
		puntoIB=inicio;         %Punto de carretera, abajo a la izquierda
		puntoDB=final;          %Punto de carretera, abajo a la derecha
		
		fprintf(fid,'l1=newl; Line Loop (l1)={offset_a+%d:offset_a+%d,Ntra+%d,-(offsetp+%d):-(offsetp+%d),-(Ntra+%d)};\n',puntoIA+1,puntoDA,linea_dcha,puntoDB,puntoIB+1,linea_izda);
		
		fprintf(fid,'Transfinite Line{offset_a+%d:offset_a+%d}=2;\n',puntoIA+1,puntoDA);
		fprintf(fid,'Plane Surface (Nsup%s+%d)={l1};\n',id_offset,id_superficie);
		fprintf(fid,'Transfinite Surface (Nsup%s+%d)={offset_a+%d,offset_a+%d,offsetp+%d,offsetp+%d};\n',id_offset,id_superficie,puntoIA,puntoDA,puntoDB,puntoIB);
end

function malla_irregular(fid,inicio,final,linea_izda,id_superficie,id_offset)
        linea_dcha=linea_izda+1;
		
		puntoIA=inicio;
		puntoDA=final;
		puntoIB=inicio;
		puntoDB=final;
		
		fprintf(fid,'l1=newl; Line(l1) = {offset_a+%d,offset_a+%d};\n',puntoIA,puntoDA);
		
		fprintf(fid,'l2=newl;Line Loop (l2)={l1,Ntra+%d,-(offsetp+%d):-(offsetp+%d),-(Ntra+%d)};\n',linea_dcha,puntoDB,puntoIB+1,linea_izda);
		
		fprintf(fid,'Plane Surface (Nsup%s+%d)={l2};\n',id_offset,id_superficie);

end

function poner_division(fid,numero,posicion,ndivisiones)
		fprintf(fid,'Line(Ntra+%d) = {offset_a+%d,offsetp+%d};\n',numero,posicion,posicion);
        fprintf(fid,'Transfinite Line{Ntra+%d}=%d Using Progression 1;\n',numero,ndivisiones+1);
end


function frontera=inserta_divisiones(frontera,B)
%En el patrón de entrada hay 1, -1 y 0. Entre un 1 y el -1 siguiente insertamos 1s cada B posiciones

contador=0;
for h=1:length(frontera)
	if (frontera(h)==1)
		contador=0;
		poniendo_divisiones=1;
	end
	if (frontera(h)==-1)
		contador=0;
		poniendo_divisiones=0;
	end
	if (poniendo_divisiones==1) & (mod(contador,B)==0)
		frontera(h)=1;
	end
	contador=contador+1;
end


end