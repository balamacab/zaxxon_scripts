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
    display('Ejemplo: poner_muro() o poner_muro(300)');
    display(' being 300 the LOD out of the walls');
    display(' ');
    display('Salida: listado de nodos que deben definir el muro');
    display('--> salida/muros.txt');
    return;
end
if nargin==0
   LODOut=5; %POr defecto 5m de LODOut
end

display('Leyendo ficheros');

[numero x z y]=textread(fichero_de_nodos,'%d %f %f %f');

[nada1 nada2 nada3 id_superficie nada5 nada6 n1 n2 n3]=textread(fichero_elements,'%d %d %d %d %d %d %d %d %d');

display('Calculando');

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

display('Acabando')

%Empezamos por uno y los ordenamos según su proximidad
%ordenados=ordenar(nodos_interseccion,x,y,z,val_pred)
  [ordenados saltos]=ordenar_b(nodos_interseccion,n1,n2,n3,id_superficie,id_conducible,id_noconducible,x,z);

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

%fid=fopen('final_muro1.txt','r');
%final1=fread(fid,inf);
%fclose(fid)

tam_wall=25; %Cada tam_wall nodos, un muro nuevo
pos_saltos=find(saltos==1);
if length(pos_saltos)==0
    pos_saltos=[1 length(saltos)]; %Un único tramo
else
    pos_saltos(1)=1;
	pos_saltos(end)=1;
end

%La ruta más larga va en un sentido, las cortas en otro (de la larga no se puede salir si estás dentro, a las cortas no se debe poder entrar si estás fuera)
longitud_muro=0;
for h=1:length(pos_saltos)/2;	
    inicio=pos_saltos(h*2-1);
	final=pos_saltos(h*2);
	if (final-inicio)>longitud_muro
		muro_largo=h;
		longitud_muro=final-inicio;
	end
end	


fid=fopen('final_muro2.txt','r');final2=fread(fid,inf);fclose(fid);

fid=fopen('salida\muros.txt','w');
contador=0;
for h=1:length(pos_saltos)/2;	
    inicio=pos_saltos(h*2-1);
	final=pos_saltos(h*2);
	%listado=[ordenados(inicio:final) ordenados(inicio)]; %Si queremos cerrar las superficies
	listado=ordenados(inicio:final);
	sentido_curva(x(listado)',z(listado)');
	h==muro_largo;
	if ((sentido_curva(x(listado)',z(listado)')==1) & (h==muro_largo)) || (((sentido_curva(x(listado)',z(listado)')==0) & (h~=muro_largo)))%Si es de sentido horario y es la larga, la reconvertimos
      listado=fliplr(flipud(listado));
    end
    anyadidos=imprimir(fid,listado,x,y,z,inicio2,final2,tam_wall,contador,LODOut);
	contador=contador+anyadidos;
end
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

%-----------------------Muro invertido

fid=fopen('final_muro2_invertido.txt','r');final2=fread(fid,inf);fclose(fid);

fid=fopen('salida\muros_invertidos.txt','w');

contador=0;
for h=1:length(pos_saltos)/2;	
    inicio=pos_saltos(h*2-1);
	final=pos_saltos(h*2);
	listado=[ordenados(inicio:final) ordenados(inicio)];
    anyadidos=imprimir(fid,listado,x,y,z,inicio2,final2,tam_wall,contador,LODOut);
	contador=contador+anyadidos;
end
fclose(fid);

fid=fopen('salida\muros_invertidos.txt','r');
contenido=fread(fid,inf);
fclose(fid);

fid=fopen('salida\muros_invertidos.txt','w');
char_contenido=char(contenido)';
cad_inicial=sprintf('  <Walls count="%d">\r\n',contador);
cad_final='  </Walls>\r\n';
fprintf(fid,'%s',strcat(cad_inicial,char_contenido,cad_final));
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


function [aceptado saltos]=ordenar_b(nodos_interseccion,n1,n2,n3,id_superficie,id_conducible,id_noconducible,x,z)
saltos=zeros(1,length(nodos_interseccion));
aceptado=zeros(1,length(nodos_interseccion));
usado=zeros(1,length(nodos_interseccion));
aceptado(1)=nodos_interseccion(1);
usado(1)=1; %Máscara de usados en nodos_interseccion
actual=1; %Contador

indice_conducibles=find(id_superficie==id_conducible);
elementos_conducibles=[n1(indice_conducibles) n2(indice_conducibles) n3(indice_conducibles)];
indice_noconducibles=find(id_superficie==id_noconducible);
elementos_noconducibles=[n1(indice_noconducibles) n2(indice_noconducibles) n3(indice_noconducibles)];

while sum(aceptado>0)<length(aceptado)
	resto_nodos=nodos_interseccion(find(usado==0));
	elements_implicados1=(elementos_conducibles(:,1)==aceptado(actual));
	elements_implicados2=(elementos_conducibles(:,2)==aceptado(actual));
	elements_implicados3=(elementos_conducibles(:,3)==aceptado(actual));
	%Lista de triángulos que tienen al nodo actual como uno de sus nodos
	c_implicados=find(elements_implicados1.+elements_implicados2.+elements_implicados3);

	elements_implicados1=(elementos_noconducibles(:,1)==aceptado(actual));
	elements_implicados2=(elementos_noconducibles(:,2)==aceptado(actual));
	elements_implicados3=(elementos_noconducibles(:,3)==aceptado(actual));
	%Lista de triángulos que tienen al nodo actual como uno de sus nodos
	nc_implicados=find(elements_implicados1.+elements_implicados2.+elements_implicados3);

%El nodo que buscamos tiene que pertenecer al mismo tiempo al resto de nodos, a los triángulos conducibles implicados y a los no conducibles
	  
	%Lista de nodos implicados por la parte conducible
	  lista=[];
          for h=1:length(c_implicados)
	    lista=[lista elementos_conducibles(c_implicados(h),1)];
	    lista=[lista elementos_conducibles(c_implicados(h),2)];
	    lista=[lista elementos_conducibles(c_implicados(h),3)];
          end
          lista_c=lista;

	  lista=[];
          for h=1:length(nc_implicados)
	    lista=[lista elementos_noconducibles(nc_implicados(h),1)];
	    lista=[lista elementos_noconducibles(nc_implicados(h),2)];
	    lista=[lista elementos_noconducibles(nc_implicados(h),3)];
          end
          lista_nc=lista;

          [C IC INC]=intersect(lista_c,lista_nc);
          
          [C IA pos]=intersect(lista_c(IC),resto_nodos);  

	actual=actual+1;
	
	if length(pos)==0  %No hemos encontrado un nodo común a los dos triángulos que pertenezca también a la frontera
		display('Jump');		
		pos=1; %We jump to another segment
		salto(actual-1)=1; %Marcamos tanto el último nodo del anterior, como el primero del actual
		salto(actual)=1;
	end

	aceptado(actual)=resto_nodos(pos(1));%Para el primer punto hay dos opciones
	usado(find(nodos_interseccion==aceptado(actual)))=1;
	if mod(actual,1000)==0
		mensaje=sprintf('%.2f\r\n',actual/length(nodos_interseccion));
		display(mensaje);
	end
end

aceptado=aceptado(find(aceptado>0));
%aceptado(end+1)=nodos_interseccion(1); %Unir principio y final
