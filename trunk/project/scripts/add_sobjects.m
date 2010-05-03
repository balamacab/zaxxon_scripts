function  add_sobjects(tam_wall)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

if (nargin~=1)
    display('Ejemplo: add_sobjects(20)');
    display('donde el parámetro es el número de nodos que forman cada muro');
    display('Salida:');
    display('--> salida/sobjects_L y sobjects_S');
    return;
end

display('Leyendo ficheros');

S=load('..\nac.mat');
nac=S.nac;
S=load('..\anchors.mat');
x1=S.x;
y1=S.y;
z1=S.z;

fid=fopen('sobjects.txt','r');
posiciones=fscanf(fid,'%c %d,%d,%f,%f \n',inf);
fclose(fid);
tipo=char(posiciones(1:5:end));
inicios=posiciones(2:5:end);
finales=posiciones(3:5:end);
ancho_inicial=posiciones(4:5:end);
ancho_final=posiciones(5:5:end);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fid=my_fopen('inicio_sobject_L.txt','r');
inicio_sobject_L=fscanf(fid,'%c');
my_fclose(fid)

fid=my_fopen('inicio_sobject_S.txt','r');
inicio_sobject_S=fscanf(fid,'%c');
my_fclose(fid);

fid=my_fopen('final_sobject.txt','r');
final_sobject=fscanf(fid,'%c');
my_fclose(fid);

fid_L=my_fopen('salida\sobjects_L.txt','w');
fid_S=my_fopen('salida\sobjects_S.txt','w');

cuenta_total=0;
for h=1:length(tipo)
	anchos=linspace(ancho_inicial(h),ancho_final(h),finales(h)-inicios(h)+1);
	[x y z]=separar(x1,y1,z1,inicios(h),finales(h),anchos);
	if (inicios(h)<=nac/2)
		invertir=0; %Está en la izquierda
	else
		invertir=1; %Está en la derecha
	end
	if strcmp(tipo(h),'L')==1
		contador=imprimir_sobject(fid_L,inicios(h):finales(h),x,y,z,inicio_sobject_L,final_sobject,tam_wall,0,invertir,anchos);
	end
	if strcmp(tipo(h),'S')==1	
		contador=imprimir_sobject(fid_S,inicios(h):finales(h),x,y,z,inicio_sobject_S,final_sobject,tam_wall,0,invertir,anchos);
	end	
	cuenta_total=cuenta_total+contador;
	end
end
my_fclose(fid_L);
my_fclose(fid_S);

display(sprintf('En total hay %d sobjects',cuenta_total))



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function contador_ficheros=imprimir_sobject(fid,aceptado,x,y,z,inicio,final,tam_wall,contador_ficheros,invertir,anchos);

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



function [xd yd zd]=separar(x,y,z,inicio,final,anchos)
  nac=length(x);
  inicio=mod(inicio-1,nac/2)+1;
  final=mod(final-1,nac/2)+1;
  
  
  x_izda_dcha=[x(nac/2+1:end)-x(1:nac/2)];  
  y_izda_dcha=[y(nac/2+1:end)-y(1:nac/2)];  
  z_izda_dcha=[z(nac/2+1:end)-z(1:nac/2)];  
  modulos=(x_izda_dcha.*x_izda_dcha+y_izda_dcha.*y_izda_dcha+z_izda_dcha.*z_izda_dcha).^(1/2);
  x_izda_dcha=x_izda_dcha./modulos;
  y_izda_dcha=y_izda_dcha./modulos;
  z_izda_dcha=z_izda_dcha./modulos;
  
  desplazamiento=zeros(size(modulos));

  desplazamiento(inicio:final)=(anchos-modulos(inicio:final))/2;
  x(1:nac/2)=x(1:nac/2)-desplazamiento(1:nac/2).*x_izda_dcha;
  y(1:nac/2)=y(1:nac/2)-desplazamiento(1:nac/2).*y_izda_dcha;
  z(1:nac/2)=z(1:nac/2)-desplazamiento(1:nac/2).*z_izda_dcha;
  x(nac/2+1:end)=x(nac/2+1:end)+desplazamiento(1:nac/2).*x_izda_dcha;
  y(nac/2+1:end)=y(nac/2+1:end)+desplazamiento(1:nac/2).*y_izda_dcha;
  z(nac/2+1:end)=z(nac/2+1:end)+desplazamiento(1:nac/2).*z_izda_dcha;
  xd=x; yd=y; zd=z;
end

