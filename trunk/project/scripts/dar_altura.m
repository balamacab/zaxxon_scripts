function dar_altura(filtrado,pendiente_limite,pend_minima,intervalo,interactivo)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.
%silent_functions(1);

fichero_nodos='nodos.mat';
fichero_anchors='porcentajes.mat';

if (nargin<3) || (filtrado=='h')
    display('Uso:  dar_altura(9,0.2,-0.2)');
    display('donde el primer parámetro debe ser impar y es el factor de suavizado en altura (más suave cuanto mayor sea)');
    display('El segundo y tercer parámetros son las pendientes máxima y mínima permitidas (antes de suavizar)');
    return;
end

if (nargin==3)
    metodo=2;
    intervalo=25;
 else
    if intervalo==0
       metodo=1;
    else
       metodo=2;
    end
end

if nargin<5
   interactivo=1;
end

if mod(filtrado,2)==0
    display('The first parameter must be odd');
    return;
end

nodos=load(fichero_nodos);     %posición absoluta de los nodos que definen el spline
anchors_porcentaje=load(fichero_anchors); %nac anchors como distancia entre nodos

display('Leyendo ..\anchors.mat');
anchors=load('..\anchors.mat');

display('Leyendo alturas_track1.mat');
alturas1=load('alturas_track1.mat');
alturas_track1=alturas1.alturas_track1;
alturas_track1=reshape(alturas_track1,length(alturas_track1),1);



%%%%%%%%%%%%%%%%%%%% Detectar posición de nodos respecto de anchors
%%%%%%%%%%%%%%%%%%%% ----------------------------------------------

tree.Anchor=anchors_porcentaje.tree;
for h=1:length(tree.Anchor)/2
        elnodo(h)=tree.Anchor(h).StartNode  ;
        elporcentaje(h)=tree.Anchor(h).StartPercentage ;
        if elporcentaje(h)==0
            posicion_nodo(elnodo(h)+1)=h;
        end
end

x=anchors.x;
y=anchors.y;
z=anchors.z;

nac=length(x);
%%%%%%%%%%%%%%%%%%%% Cálculo de ángulos
%%%%%%%%%%%%%%%%%%%% ----------------------------------------------
 
x_puntos_medios=0.5*(x(1:nac/2)+x(nac/2+1:end));
z_puntos_medios=0.5*(z(1:nac/2)+z(nac/2+1:end));

anguloy=zeros(length(x)/2,1);

%%%%%%%%%%%%%%%%%%%% ----------------------------------------------
  xy = [x_puntos_medios;z_puntos_medios]; 
  ddf = diff(xy,1,2); 

  %Cálculo basto de la longitud
  ladistan = cumsum([0, sqrt([1 1]*(ddf.*ddf))]);  %La variable es la distancia
  
try 
    %alturas_suavizadas=sgolayfilt(alturas_track1,5,9);
	[nadaa]=milowess([ladistan',alturas_track1],0.04,0);
	alturas_suavizadas=nadaa(:,3);
	if length(alturas_suavizadas)<length(alturas_track1)
	    alturas_suavizadas=[alturas_suavizadas(1); alturas_suavizadas];
	end
catch
    alturas_suavizadas=alturas_track1;
end
%%%%%%%%%%%%%%%%%%%% ----------------------------------------------

[alturas_suavizadas distancia_recorrida]=suavizar(x,y,z,alturas_suavizadas,pendiente_limite,pend_minima,nac);

alturas_suavizadas_i=alturas_suavizadas;

filtro_final=ones(1,filtrado)/filtrado;
alturas_suavizadas2=filter(filtro_final,1,[alturas_suavizadas(1)*ones(1,(length(filtro_final)+1)) alturas_suavizadas' alturas_suavizadas(end)*ones(1,(length(filtro_final)+1)/2)]);
alturas_suavizadas(1:end)=alturas_suavizadas2(1.5*(length(filtro_final)+1):end-1);



%plot(distancia_recorrida,alturas_track1,'k',distancia_recorrida,alturas_suavizadas_i,'or');

if interactivo==1
    [alturas_suavizadas]=editar_altura(x,y,z,distancia_recorrida,alturas_suavizadas,alturas_track1);
end	
hold on
if metodo==1
    disp('Method 1');
    plot(distancia_recorrida,alturas_suavizadas,'r','linewidth',2);
	legend('Mountain','Method 1','Edited');
	clear separacion;
	for h=1:length(alturas_suavizadas)
		if (h>1) && (h<length(alturas_suavizadas))
			separacion=norm(x_puntos_medios(h+1)-x_puntos_medios(h-1)+j*(z_puntos_medios(h+1)-z_puntos_medios(h-1)));
			inc_altura=alturas_suavizadas(h+1)-alturas_suavizadas(h-1);
			anguloy(h)=angle(separacion+j*inc_altura);
		end
	end
else
    disp('Method 2');
    plot(distancia_recorrida,alturas_suavizadas,'r');
    [alturas_suavizadas anguloy]=interpola(x_puntos_medios,z_puntos_medios,alturas_suavizadas,intervalo,distancia_recorrida);
    plot(distancia_recorrida,alturas_suavizadas,'-b','linewidth',2);
    legend('Mountain','Method 1','Edited','Method 2');
end
alturas=alturas_suavizadas(posicion_nodo);
angulosy=anguloy(posicion_nodo);

save('track0.mat','anguloy','alturas','alturas_suavizadas');

%Retocamos de alguna forma los nodos
tree.node=nodos.tree;

for h=1:length(tree.node)
    tree.node(h).Position.y=alturas(h);
    tree.node(h).ControlPoints.AngleY=-angulosy(h);
end


xml_write('salida\nodes.xml',tree);
system('copy Venue_start.txt+salida\nodes.xml+Venue_end.txt salida\Venue.xml/b');

display('salida\nodes.xml copied to ..\Venue folder');
system('copy salida\nodes.xml ..\Venue\./b');
procedencia='dar_altura'; 
save('..\venue\procedencia.mat','procedencia');

message(6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xml_write(fichero,tree)
    fid=my_fopen(fichero,'w');
    fprintf(fid,'    <nodes count=\"%d\">\n      <OnlyOneNodeSelected>1</OnlyOneNodeSelected>\n        <LineType>BezierSpline</LineType>\n',length(tree.node));
    for h=1:length(tree.node)
        fprintf(fid,'        <node NodeId="%d">\n',h-1);
        fprintf(fid,'          <Position x="%f" y="%f" z="%f" />\n',tree.node(h).Position.x,tree.node(h).Position.y,tree.node(h).Position.z);
        fprintf(fid,'          <ControlPoints AngleXZ="%f" AngleY="%f" EntryDistance="%f" ExitDistance="%f" />\n        </node>\n',tree.node(h).ControlPoints.AngleXZ,tree.node(h).ControlPoints.AngleY,tree.node(h).ControlPoints.EntryDistance,tree.node(h).ControlPoints.ExitDistance);
    end
    fprintf(fid,'    </nodes>\n'); 
    my_fclose(fid);
end

function [alturas_suavizadas distancia_recorrida]=suavizar(x,y,z,alturas_suavizadas,pendiente_limite,pend_minima,nac)

distancia_recorrida=0*alturas_suavizadas;
for h=1:length(alturas_suavizadas)
    if (h<length(alturas_suavizadas))
        pend_maxima=pendiente_limite;%*limitador(h);
        
        separacion_izq=abs(x(h+1)-x(h)+j*(z(h+1)-z(h)));
        h_dcha=h+nac/2;
        separacion_dcha=abs(x(h_dcha+1)-x(h_dcha)+j*(z(h_dcha+1)-z(h_dcha)));
        separacion(h)=min([separacion_dcha separacion_izq]);
        distancia_recorrida(h+1)=distancia_recorrida(h)+separacion(h);
        inc_altura_maximo=(separacion(h))*pend_maxima;
        inc_altura_minimo=(separacion(h))*pend_minima;
        
        inc_altura=alturas_suavizadas(h+1)-alturas_suavizadas(h);
        if inc_altura>inc_altura_maximo
            alturas_suavizadas(h+1)=alturas_suavizadas(h)+inc_altura_maximo;
        end
        if inc_altura<=inc_altura_minimo
            alturas_suavizadas(h+1)=alturas_suavizadas(h)+inc_altura_minimo; %qUE BAJE UN PELÍN
        end
    end
end


function [altura angulo]=interpola(x,y,alturas_in,intervalo,distancia)
  %if length(alturas_in)<length(x);
  %   alturas_in(end+1)=alturas_in(end);
  %end
  alturas_in=alturas_in';
  xy = [x;y]; 
  %df = diff(xy,1,2); 

  %Cálculo basto de la longitud
  %distancia = cumsum([0, sqrt([1 1]*(df.*df))]);  %La variable es la distancia
  cv = spline(distancia,xy);

%Un nodo cada X m para calcular los splines de altura
  %intervalo=50;

%Interpolamos con un spline que tiene un nodo cada 20m
  pasos=round(distancia(end)/intervalo);

  c_altura = spline(distancia,alturas_in);
  d=linspace(0,distancia(end),pasos);
  alturas_muestreadas=ppval(c_altura,d);
  usar_akima=1;
  if usar_akima==0
	  c_altura = spline(d,alturas_muestreadas);
	%Obtenemos el valor de altura dado por el spline para los puntos medios de la carretera
	  altura=ppval(c_altura,distancia);
	  angulo=0;
	  c_derivada=c_altura;	
	  c_derivada.P(:,4)=c_altura.P(:,3);
	  c_derivada.P(:,3)=2*c_altura.P(:,2);
	  c_derivada.P(:,2)=3*c_altura.P(:,1);
	  c_derivada.P(:,1)=0; %Coeficiente A
	  pendiente=ppval(c_derivada,distancia);
  else
	[altura pendiente]=akima(d,alturas_muestreadas,distancia);
  end
  % figure,plot(distancia,pendiente,'-b',distancia,pendiente_akima,'r-');
  % figure,plot(distancia,altura,'-b',distancia,altura_akima,'r-',d,alturas_muestreadas,'+b');
  % figure
  angulo=atan(pendiente);
  %figure,plot(distancia,angulo);figure,plot(distancia,altura);pause
end

end
