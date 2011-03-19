function  poner_muro(LODOut)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

fichero_de_nodos='nodos_conaltura.txt';
fichero_elements='elements.txt';
id_conducible=111;
id_noconducible=222;
if (nargin>1)
    display('Example: poner_muro() o poner_muro(300)');
    display(' being 300 the LOD out of the walls');
    display(' ');
    display('Salida: listado de nodos que deben definir el muro');
    display('--> salida/muros.txt');
    return;
end
if nargin==0
   LODOut=1; %POr defecto 5m de LODOut
end

display('Leyendo ficheros');

[numero x z y]=textread(fichero_de_nodos,'%d %f %f %f');

[nada1 nada2 nada3 id_superficie nada5 nada6 n1 n2 n3]=textread(fichero_elements,'%d %d %d %d %d %d %d %d %d');

display('Calculando');

%trisurf([n1 n2 n3],x,y,z)
%trisurf([n1(find(id_superficie==id_noconducible)) n2(find(id_superficie==id_noconducible)) n3(find(id_superficie==id_noconducible))], x, y ,z);
malla1=zeros(1,length(numero));
malla2=zeros(1,length(numero));

edges_list=[];
contador=1;
for h=1:length(n1)
	%Marcamos qué nodos forman parte de la parte interna y externa del muro
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
	
	%Creamos un listado de "edges" o líneas que forman las faces de la parte no conducible
	if id_noconducible==id_superficie(h)
		%Debo anotar 3 edges. El número menor en primer lugar
		edges_list(contador,1)=min(n1(h),n2(h));
		edges_list(contador,2)=max(n1(h),n2(h));
		edges_list(contador+1,1)=min(n2(h),n3(h));
		edges_list(contador+1,2)=max(n2(h),n3(h));
		edges_list(contador+2,1)=min(n3(h),n1(h));
		edges_list(contador+2,2)=max(n3(h),n1(h));
		contador=contador+3;
	end
end

interseccion=((malla1+malla2)==2);
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

%Solo interesan los edges que sean contorno, que son los que solo pertenecen a un triángulo y que por tanto no están duplicados

[edges_list(:,1) indices]=sort(edges_list(:,1));
edges_list(:,2)=edges_list(indices,2);
diferentes=unique(edges_list(:,1));
for h=1:length(diferentes)
    [indices]=find(diferentes(h)==edges_list(:,1));
    edges_list(indices,2)=sort(edges_list(indices,2));
end

accepted=ones(length(edges_list),1);
for h=1:length(edges_list)-1
	if accepted(h)==1
		if (edges_list(h+1,1)==edges_list(h,1)) && (edges_list(h+1,2)==edges_list(h,2)) %Si son el mismo edge es que no es un edge-contorno
			accepted(h)=0; 
			accepted(h+1)=0; 
		end
	end
end
size(edges_list);
accepted;

contour_edges=[];
contador=1;
for h=1:length(accepted)
	if accepted(h)==1
		contour_edges(contador,:)=edges_list(h,:);
		contador=contador+1;
	end
end


display('Acabando')

%Empezamos por un nodo que pertenezca a ambas superfices, la 111 y la 222
inicial=nodos_interseccion(1);

ordenados(1)=inicial;
contador=1;
nuevo=-1;
size(contour_edges);
edge_usado=zeros(length(contour_edges),1);
while (nuevo~=inicial) 
	%Buscamos el edge al que pertenece el punto
	 pos1=find(ordenados(contador)==contour_edges(:,1));
	 pos2=find(ordenados(contador)==contour_edges(:,2));
	 if length(pos1)>0
		for g=1:length(pos1)
			if edge_usado(pos1(g))==0
				pos=pos1(g);
				columna=2;
			end
		end
     end
     if length(pos2)>0
	 	for g=1:length(pos2)
			if edge_usado(pos2(g))==0
				pos=pos2(g);
				columna=1;
			end
        end
     end
     
	 contador=contador+1;
	 nuevo=contour_edges(pos,columna); %Anotamos ese punto como siguiente en el contorno
	 edge_usado(pos)=1;
	 ordenados(contador)=nuevo;
end

fid=fopen('salida\ordenados.geo','w');
for h=1:length(ordenados)
    fprintf(fid,'Point(%d) = {%f, %f, %f, 20};\n',ordenados(h),x(ordenados(h)),0,z(ordenados(h)));
    if h>1
         fprintf(fid,'Line(%d) = {%d, %d};\n',h,ordenados(h),ordenados(h-1));
     end
end

fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inicio2=strcat(...
'    <Wall RandomSeed="1118946147">\r\n',...
'      <Name>Wall%d</Name>\r\n',...
'      <OverrideLOD>True</OverrideLOD>\r\n',...
'      <LODIn>0</LODIn>\r\n',...
'      <LODOut>%d</LODOut>\r\n',...
'      <nodes count="%d">\r\n',...
'        <OnlyOneNodeSelected>-1</OnlyOneNodeSelected>\r\n',...
'        <LineType>Straight</LineType>\r\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



tam_wall=25; %Cada tam_wall nodos, un muro nuevo

fid=fopen('final_muro2.txt','r');final2=fread(fid,inf);fclose(fid);

fid=fopen('salida\muros.txt','w');
contador=0;
listado=ordenados;
sentido_curva(x(listado)',z(listado)');
if ((sentido_curva(x(listado)',z(listado)')==1))%Si es de sentido horario y es la larga, la reconvertimos
      listado=fliplr(flipud(listado));
end
anyadidos=imprimir(fid,listado,x,y,z,inicio2,final2,tam_wall,contador,LODOut);
contador=contador+anyadidos;
fclose(fid);

fid=fopen('salida\muros.txt','r');
contenido=fread(fid,inf);
char_contenido=char(contenido)';
fclose(fid);

fid=fopen('salida\muros.txt','w');
cad_inicial=sprintf('  <Walls count="%d">',contador);
cad_final='  </Walls>';
fprintf(fid,'%s\r\n %s\r\n %s\r\n',cad_inicial,char_contenido,cad_final);
fclose(fid);

message(13);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function contador_ficheros=imprimir(fid,aceptado,x,y,z,inicio,final,tam_wall,contador_ficheros,LODOut);

fprintf(fid,inicio,contador_ficheros,LODOut,min(length(aceptado),tam_wall));
contador_ficheros=contador_ficheros+1;

cont_nodos=0;
for h=1:length(aceptado)
    imprimir=1;
    
    if imprimir==1
        fprintf(fid,'         <node NodeId="%d">\r\n           <Position x="%f" y="%f" z="%f" />\r\n',mod(cont_nodos,tam_wall),x(aceptado(h)),y(aceptado(h)),z(aceptado(h)));
        fprintf(fid,'           <ControlPoints AngleXZ="0" AngleY="0" EntryDistance="0" ExitDistance="0" />\r\n         </node>\r\n');
        cont_nodos=cont_nodos+1;
    end
    if (mod(cont_nodos,tam_wall)==0) && (length(aceptado)>h) %Si llevamos un múltiplo de tam_wall y todavía quedan, iniciamos un nuevo muro
        fwrite(fid,final);
        fprintf(fid,inicio,contador_ficheros,LODOut,min(length(aceptado)-h+1,tam_wall));
        contador_ficheros=contador_ficheros+1;  
        cont_nodos=0;
        %El último nodo del anterior se repite en el nuevo
        fprintf(fid,'         <node NodeId="%d">\r\n           <Position x="%f" y="%f" z="%f" />\r\n',mod(cont_nodos,tam_wall),x(aceptado(h)),y(aceptado(h))-0.1,z(aceptado(h)));
        fprintf(fid,'           <ControlPoints AngleXZ="0" AngleY="0" EntryDistance="0" ExitDistance="0" />\r\n         </node>\r\n');
        cont_nodos=cont_nodos+1;
    end
end
fwrite(fid,final);





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


