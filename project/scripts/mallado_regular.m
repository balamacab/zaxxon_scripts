function mallado_regular(separacion,ndivisiones,transfinite)
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
    display('mallado_regular(12,3,1)');
    display('Arguments: width of driveable zone in meters, number of panels for that zone, use transfinite');
    return;
end

B=inf;
if nargin==2
	transfinite=0;
end

[numero_sons caminos]=look_for_father_or_sons('..\sons.txt',1);
[numero_father caminos]=look_for_father_or_sons('..\father.txt',1);
if numero_sons>0, 
	tipo='FATHER';
elseif numero_father>0
	tipo='SON';
else
	tipo='NORMAL';
end

display('Usando el fichero anchors.mat ya creado...');
S=load('..\anchors.mat');
x=S.x;
y=S.y;
z=S.z;

longitud=length(x); nac=longitud;
save '..\nac.mat' nac;


fid_kml=my_fopen('salida\mesh.kml','w');
abrir_kml(fid_kml);
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

%Si no es un hijo, insertamos el Field
insertar=0;
%if strcmp(tipo,'SON')==0, insertar=1; end;
%inserta_field(fid,longitud,insertar);

grabar_puntos(fid_kml,x(1:longitud/2),z(1:longitud/2));
grabar_puntos(fid_kml,x(longitud/2+1:end),z(longitud/2+1:end));

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
	ida=descarta_lazos_enormes(ida);
	%Recorremos la parte derecha buscando lazos
	vuelta=busca_lazos(punto_derecha);
    vuelta=descarta_lazos_enormes(vuelta);

%Unimos los puntos que pueden ponerse con transfinite
fprintf(fid,'offset_a=newp+2;\n');
for h=1:nac/2
	fprintf(fid,'Point(offset_a+%d) = {%f, %f, %f, cl2};\n',h,punto_izquierda(h,1),punto_izquierda(h,3),0);        
	if (h>1) && (ida(h)==1) && (ida(h-1)==1)
		fprintf(fid,'Line(offset_a+%d) = {offset_a+%d,offset_a+%d};\n',h,h-1,h);
	end	
end
grabar_puntos(fid_kml,punto_izquierda(find(ida==1),1),punto_izquierda(find(ida==1),3));

for h=1:nac/2
	fprintf(fid,'Point(offset_a+%d) = {%f, %f, %f, cl2};\n',h+nac/2,punto_derecha(h,1),punto_derecha(h,3),0);
	if h>1	&& (vuelta(h)==1) && (vuelta(h-1)==1)
		fprintf(fid,'Line(offset_a+%d) = {offset_a+%d,offset_a+%d};\n',h+nac/2,h-1+nac/2,h+nac/2);
	end
end
grabar_puntos(fid_kml,punto_derecha(find(vuelta==1),1),punto_derecha(find(vuelta==1),3));


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

fprintf(fid,'Ntra=newl;\n');
for h=1:length(cambios)
  poner_division(fid,h,cambios(h),ndivisiones);
end

id_offset=sprintf('%05d',10000*rand());
fprintf(fid,'Nsup%s=news;\n',id_offset);
for h=1:length(cambios)-1
	if frontera(cambios(h))==empieza_regular %Entramos en una zona regular
		malla_regular(fid,cambios(h),cambios(h+1),h,contador,id_offset);
	else                                           %Entramos en una zona irregular
		malla_irregular(fid,cambios(h),cambios(h+1),h,contador,id_offset,transfinite);
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
fprintf(fid,'Ntra=newl;\n');
for h=1:length(cambios)
  poner_division(fid,h,cambios(h)+nac/2,ndivisiones);
end

for h=1:length(cambios)-1
	if frontera(cambios(h))==empieza_regular
		malla_regular(fid,cambios(h)+nac/2,cambios(h+1)+nac/2,h,contador,id_offset);
	else
		malla_irregular(fid,cambios(h)+nac/2,cambios(h+1)+nac/2,h,contador,id_offset,transfinite);
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

cerrar_kml(fid_kml);
my_fclose(fid_kml);

%Si solo hay un track, metemos los thresholds en el propio anchors_carretera.geo
if strcmp(tipo,'NORMAL')==1 
	make_thresholds_active('salida\anchors_carretera.geo');
end

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

function malla_irregular(fid,inicio,final,linea_izda,id_superficie,id_offset,transfinite)

		linea_dcha=linea_izda+1;
		
		puntoIA=inicio;
		puntoDA=final;
		puntoIB=inicio;
		puntoDB=final;
		fprintf(fid,'Delete {\n');
		fprintf(fid,'    Point{offset_a+%d:offset_a+%d};\n',puntoIA+1,puntoDA-1);
		fprintf(fid,'}\n');

		fprintf(fid,'l1=newl; Line(l1) = {offset_a+%d,offset_a+%d};\n',puntoIA,puntoDA);
		if transfinite==1
			fprintf(fid,'Transfinite Line(l1) = %d Using Progression 1;\n',puntoDA-puntoIA+1);
		end
		fprintf(fid,'l2=newl;Line Loop (l2)={l1,Ntra+%d,-(offsetp+%d):-(offsetp+%d),-(Ntra+%d)};\n',linea_dcha,puntoDB,puntoIB+1,linea_izda);
		
		fprintf(fid,'Plane Surface (Nsup%s+%d)={l2};\n',id_offset,id_superficie);
		if transfinite==1
			fprintf(fid,'Transfinite Surface (Nsup%s+%d)={offset_a+%d,offset_a+%d,offsetp+%d,offsetp+%d};\n',id_offset,id_superficie,puntoIA,puntoDA,puntoDB,puntoIB);
		end
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


function abrir_kml(fid)

fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom">\n<Document>\n	<name>mesh.kml</name>\n	<Style id="sn_ylw-pushpin">\n		<LineStyle>\n			<color>7f00ffff</color>\n			<width>4</width>\n		</LineStyle>\n		<PolyStyle>\n			<color>7f00ff00</color>\n		</PolyStyle>\n	</Style>\n');	

end




function grabar_puntos(fid,x,z)

fprintf(fid,'<Placemark>\n		<name>Route</name>\n		<description>Road and driveable zone</description>\n	<styleUrl>#sn_ylw-pushpin</styleUrl>\n<LineString>			<coordinates>\n');

[numero_padres caminos]=look_for_father_or_sons('..\father.txt');

if numero_padres==0  % Si no hay padre, generamos mapeo.txt. Si no lo hay, usamos el mapeo.txt existente
	[mapeo]=textread('..\mapeo.txt','%f');
else
	[mapeo]=textread(strcat(caminos(1),'\mapeo.txt'),'%f');
end

for h=1:length(x)    
            [pos1 pos3 pos2]=BTB_a_coor(x(h),0,z(h),mapeo);%Altura es el segundo
            fprintf(fid,'%f,%f,%f\r\n',pos1,pos2,0);
    
end
fprintf(fid,'</coordinates>\n		</LineString>\n</Placemark>\n');
end


function cerrar_kml(fid)

fprintf(fid,'</Document>\n</kml>\n');

end


function inserta_field(fid,longitud,insertar)
	fprintf(fid,'If (%d)\n',insertar);
    fprintf(fid,'  Field[offsetp+1] = Attractor;\n');
    fprintf(fid,'  Field[offsetp+1].NodesList = {offsetp+1:offsetp+%d};\n',longitud);

    fprintf(fid,'  Field[offsetp+2] = Threshold;\n');
    fprintf(fid,'  Field[offsetp+2].IField = offsetp+1;\n');
    fprintf(fid,'  Field[offsetp+2].LcMin = 20;\n');
    fprintf(fid,'  Field[offsetp+2].LcMax = 2000;\n');
    fprintf(fid,'  Field[offsetp+2].DistMin = 1;\n');
    fprintf(fid,'  Field[offsetp+2].DistMax = 10000;\n');
    fprintf(fid,'  Field[offsetp+2].StopAtDistMax = 0;\n');
    fprintf(fid,'  Mesh.CharacteristicLengthExtendFromBoundary = 0;\n');
	
	fprintf(fid,'  Background Field=offsetp+2;\n');
	fprintf(fid,'EndIf\n');
end

function salida=descarta_lazos_enormes(datos)
    tamanyo_limite_de_lazo=200; %Un lazo que comprenda más de 200 puntos no es un lazo (mas o menos es 1Km)
	inicio=true;
    for h=1:length(datos)
	    if datos(h)==1
		    if inicio==true %seguimos con el 1 anterior
		        ini_pos=h;
			else            %cerramos un lazo
			    if (h-ini_pos)>tamanyo_limite_de_lazo
			        datos(ini_pos:h)=ones(size(datos(ini_pos:h)));
				end
			end
			inicio=true;
		end
		if datos(h)==0
		    inicio=false;
		end
    end
	salida=datos;
end
