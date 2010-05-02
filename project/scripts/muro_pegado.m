function  muro_pegado(tam_wall,desplazamiento)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.


if (nargin~=2)
    display('Ejemplo: muro_pegado(20,1.0)');
    display('donde el primer parámetro es el número de nodos que forman cada muro y el segundo el desplazamiento en metros hacia afuera de la carretera');
    display('Salida:');
    display('--> salida/muros_pegados.txt');
    return;
end

display('Leyendo ficheros');

S=load('..\nac.mat');
nac=S.nac;
S=load('..\anchors.mat');
x=S.x;
y=S.y;
z=S.z;

[x y z]=separar(x,y,z,desplazamiento);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

inicio1=strcat(...
'    <Wall RandomSeed="1118946147">\r\n',...
'      <Name>Pegado%d</Name>\r\n',...
'      <Collisions>True</Collisions>\r\n',...
'      <ShadowReceiver>False</ShadowReceiver>\r\n',...
'      <ReceiveLighting>False</ReceiveLighting>\r\n',...
'      <Grounded>False</Grounded>\r\n',...
'      <IsTreeWall>True</IsTreeWall>',...
'      <nodes count="%d">\r\n',...
'        <OnlyOneNodeSelected>-1</OnlyOneNodeSelected>\r\n',...
'        <LineType>Straight</LineType>\r\n');

inicio2_izda=strcat(...
'    <Wall RandomSeed="1118946147">\r\n',...
'      <Name>Pegado%d_izda</Name>\r\n',...
'      <nodes count="%d">\r\n',...
'        <OnlyOneNodeSelected>-1</OnlyOneNodeSelected>\r\n',...
'        <LineType>Straight</LineType>\r\n');

inicio2_dcha=strcat(...
'    <Wall RandomSeed="1118946147">\r\n',...
'      <Name>Pegado%d_dcha</Name>\r\n',...
'      <nodes count="%d">\r\n',...
'        <OnlyOneNodeSelected>-1</OnlyOneNodeSelected>\r\n',...
'        <LineType>Straight</LineType>\r\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid=my_fopen('final_muro2_invertido.txt','r');
final2i=fread(fid,inf);
my_fclose(fid)

fid=my_fopen('final_muro2.txt','r');
final2=fread(fid,inf);
my_fclose(fid)



fid=my_fopen('salida\muros_izda.txt','w')
fprintf(fid,'  <Walls count="%d">\r\n',ceil(((nac/2)*(1+(1/tam_wall)))/tam_wall));

contador=imprimir(fid,1:nac/2,x,y,z,inicio2_izda,final2,tam_wall,0);

fprintf(fid,'  </Walls>\r\n');
my_fclose(fid);

fid=my_fopen('salida\muros_dcha.txt','w')
fprintf(fid,'  <Walls count="%d">\r\n',ceil(((nac/2)*(1+(1/tam_wall)))/tam_wall));

contador2=imprimir(fid,nac/2+1:nac,x,y,z,inicio2_dcha,final2i,tam_wall,0);

fprintf(fid,'  </Walls>\r\n');
my_fclose(fid);

display(sprintf('En total hay %d muros (izda+dcha)',contador+contador2))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load 'inicio_sobject.dat'
%load 'final_sobject.dat'

fid=my_fopen('inicio_sobject_i.txt','r');
inicio_sobject_i=fscanf(fid,'%c');
my_fclose(fid)

fid=my_fopen('inicio_sobject_d.txt','r');
inicio_sobject_d=fscanf(fid,'%c');
my_fclose(fid)

fid=my_fopen('final_sobject.txt','r');
final_sobject=fscanf(fid,'%c');
my_fclose(fid)



fid=my_fopen('salida\sobjects_izda.txt','w')

contador=imprimir_sobject(fid,1:nac/2,x,y,z,inicio_sobject_i,final_sobject,tam_wall,0,0);

my_fclose(fid);

fid=my_fopen('salida\sobjects_dcha.txt','w')

contador2=imprimir_sobject(fid,nac/2+1:nac,x,y,z,inicio_sobject_d,final_sobject,tam_wall,0,1);

my_fclose(fid);

display(sprintf('En total hay %d muros (izda+dcha)',contador+contador2))



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function contador_ficheros=imprimir(fid,aceptado,x,y,z,inicio,final,tam_wall,contador_ficheros);

fprintf(fid,inicio,contador_ficheros,min(length(aceptado),tam_wall));
contador_ficheros=contador_ficheros+1;

cont_nodos=0;
recorrido=1:length(aceptado);
for h=recorrido
    imprimir=1;
    if h>1
        punto_a_punto(h)=norm([x(aceptado(h))-x(aceptado(h-1)) z(aceptado(h))-z(aceptado(h-1))]);
        if punto_a_punto(h)>30
            imprimir=0;
            fprintf(1,'Omitiendo tramo en (%f,%f)\r\n',x(aceptado(h)),z(aceptado(h)));
        end
    end
    
    if imprimir==1
        fprintf(fid,'         <node NodeId="%d">\r\n           <Position x="%f" y="%f" z="%f" />\r\n',mod(cont_nodos,tam_wall),x(aceptado(h)),y(aceptado(h)),z(aceptado(h)));
        fprintf(fid,'           <ControlPoints AngleXZ="0" AngleY="0" EntryDistance="0" ExitDistance="0" />\r\n         </node>\r\n');
        cont_nodos=cont_nodos+1;
    end
    if (mod(cont_nodos,tam_wall)==0) && (length(aceptado)>h) %Si llevamos un múltiplo de tam_wall y todavía quedan, iniciamos un nuevo muro
        fwrite(fid,final);
        fprintf(fid,inicio,contador_ficheros,min(length(aceptado)-h+1,tam_wall));
        contador_ficheros=contador_ficheros+1;  
        cont_nodos=0;
        %El último nodo del anterior se repite en el nuevo
        fprintf(fid,'         <node NodeId="%d">\r\n           <Position x="%f" y="%f" z="%f" />\r\n',mod(cont_nodos,tam_wall),x(aceptado(h)),y(aceptado(h)),z(aceptado(h)));
        fprintf(fid,'           <ControlPoints AngleXZ="0" AngleY="0" EntryDistance="0" ExitDistance="0" />\r\n         </node>\r\n');
        cont_nodos=cont_nodos+1;
    end
end
fwrite(fid,final);

end


function contador_ficheros=imprimir_sobject(fid,aceptado,x,y,z,inicio,final,tam_wall,contador_ficheros,invertir);

fprintf(fid,inicio,contador_ficheros,min(length(aceptado),tam_wall));
contador_ficheros=contador_ficheros+1;

cont_nodos=0;
if invertir==0
  paso=1;
  recorrido=1:paso:length(aceptado);
 else
  paso=-1;
  recorrido=length(aceptado):paso:1;
end
for h=recorrido
    imprimir=1;
    if h>1
        punto_a_punto(h)=norm([x(aceptado(h))-x(aceptado(h-1)) z(aceptado(h))-z(aceptado(h-1))]);
        if punto_a_punto(h)>30
            imprimir=0;
            fprintf(1,'Omitiendo tramo en (%f,%f)\r\n',x(aceptado(h)),z(aceptado(h)));
        end
    end
    
    if imprimir==1
        fprintf(fid,'         <node NodeId="%d">\r\n           <Position x="%f" y="%f" z="%f" />\r\n',mod(cont_nodos,tam_wall),x(aceptado(h)),y(aceptado(h)),z(aceptado(h)));
        fprintf(fid,'           <ControlPoints AngleXZ="0" AngleY="0" EntryDistance="0" ExitDistance="0" />\r\n         </node>\r\n');
        cont_nodos=cont_nodos+1;
    end
    if (mod(cont_nodos,tam_wall)==0) && (length(aceptado)>h) %Si llevamos un múltiplo de tam_wall y todavía quedan, iniciamos un nuevo muro
        fwrite(fid,final);
        fprintf(fid,inicio,contador_ficheros,min(length(aceptado)-h+1,tam_wall));
        contador_ficheros=contador_ficheros+1;  
        cont_nodos=0;
        %El último nodo del anterior se repite en el nuevo
        fprintf(fid,'         <node NodeId="%d">\r\n           <Position x="%f" y="%f" z="%f" />\r\n',mod(cont_nodos,tam_wall),x(aceptado(h)),y(aceptado(h))-0.1,z(aceptado(h)));
        fprintf(fid,'           <ControlPoints AngleXZ="0" AngleY="0" EntryDistance="0" ExitDistance="0" />\r\n         </node>\r\n');
        cont_nodos=cont_nodos+1;
    end
end
fwrite(fid,final);

end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function aceptado=ordenar_b(nodos_interseccion,n1,n2,n3,id_superficie,id_conducible,id_noconducible,x,z)
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
        
        if length(pos)==0
            display('Proceso detenido');		
	        break;
        end
	
        aceptado(actual)=resto_nodos(pos(1));%Para el primer punto hay dos opciones
	usado(find(nodos_interseccion==aceptado(actual)))=1;
	if mod(actual,100)==0
		mensaje=sprintf('%.2f\r\n',actual/length(nodos_interseccion));
		display(mensaje);
	end
end

aceptado=aceptado(find(aceptado>0));
aceptado(end+1)=nodos_interseccion(1); %Unir principio y final

end

function [xd yd zd]=separar(x,y,z,desplazamiento)
  nac=length(x);
  x_izda_dcha=[x(nac/2+1:end)-x(1:nac/2)];  
  y_izda_dcha=[y(nac/2+1:end)-y(1:nac/2)];  
  z_izda_dcha=[z(nac/2+1:end)-z(1:nac/2)];  
  modulos=(x_izda_dcha.*x_izda_dcha+y_izda_dcha.*y_izda_dcha+z_izda_dcha.*z_izda_dcha).^(1/2);
  x_izda_dcha=x_izda_dcha./modulos;
  y_izda_dcha=y_izda_dcha./modulos;
  z_izda_dcha=z_izda_dcha./modulos;
  x(1:nac/2)=x(1:nac/2)-desplazamiento*x_izda_dcha;
  y(1:nac/2)=y(1:nac/2)-desplazamiento*y_izda_dcha;
  z(1:nac/2)=z(1:nac/2)-desplazamiento*z_izda_dcha;
  x(nac/2+1:end)=x(nac/2+1:end)+desplazamiento*x_izda_dcha;
  y(nac/2+1:end)=y(nac/2+1:end)+desplazamiento*y_izda_dcha;
  z(nac/2+1:end)=z(nac/2+1:end)+desplazamiento*z_izda_dcha;
  xd=x; yd=y; zd=z;
end


end
