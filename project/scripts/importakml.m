function importakml(ficherokml,tolerancia)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

invertir_tramo=0; %0 es no invertir el sentido del kml, 1 es invertirlo

if (nargin<2) || (ficherokml=='h')
	disp('Uso: importakml(''file.txt'',0.75)');
	disp('Donde el segundo parámetro es el error máximo en metros permitido al simplificar los nodos');
	disp('NOTA: se puede invertir el sentido del tramo cambiando la segunda línea de importakml.m');
	return;
end

%Por si acaso
pkg rebuild -auto communications;

[longitud latitud altura]=leer_datos(ficherokml);
if length(longitud)<1
	display('Check above errors!!!!!!!!!!!!')
	return
end

if invertir_tramo==1
	[duno,ddos]=size(longitud);
	if duno>ddos
		longitud=flipdim(longitud,1);
	else
		longitud=flipdim(longitud,2);
	end
	[duno,ddos]=size(latitud);
	if duno>ddos
		latitud=flipdim(latitud,1);
	else
		latitud=flipdim(latitud,2);
	end
	[duno,ddos]=size(altura);
	if duno>ddos
		altura=flipdim(altura,1);
	else
		altura=flipdim(altura,2);
	end
	
end

[x y nel]=calcoord(longitud,latitud,length(longitud),22);
x=x';
y=y';

%Eliminamos valores duplicados, algo que puede pasar si los datos vienen de un GPS
xyo = [x;y]; 
dfo = diff(xyo,1,2); 

%Cálculo basto de la longitud
distanciao = cumsum([0, sqrt([1 1]*(dfo.*dfo))]);  %La variable es la distancia
unicos=[1 1+find(diff(distanciao)>0)];

x=x(unicos);
y=y(unicos);
altura=altura(unicos);
longitud=longitud(unicos);
latitud=latitud(unicos);

[numero_padres caminos]=look_for_father_or_sons('..\father.txt');

if numero_padres==0  % Si no hay padre, generamos mapeo.txt. Si no lo hay, usamos el mapeo.txt existente
	x_centro=(max(x)+min(x))/2;
	x=x-x_centro;
	y_centro=(max(y)+min(y))/2;
	y=y-y_centro;

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Grabo mapeo.txt basado en 

	fid=my_fopen('..\mapeo.txt','w');

	%Esquinas inferior izquierda y superior derecha
	[minlat indiceminlat]=min(latitud);
	[minlong indiceminlong]=min(longitud);
	[maxlat indicemaxlat]=max(latitud);
	[maxlong indicemaxlong]=max(longitud);

	fprintf(fid,'%.10f\n%.10f\n%.10f\n%.10f\n',x(indiceminlong),y(indiceminlat),minlong,minlat);
	fprintf(fid,'%.10f\n%.10f\n%.10f\n%.10f\n',x(indicemaxlong),y(indicemaxlat),maxlong,maxlat);

	my_fclose(fid);
	[mapeo]=textread('..\mapeo.txt','%f');
else
	[mapeo]=textread(strcat(caminos(1),'\mapeo.txt'),'%f');
end


fid=my_fopen('salida\trazado.kml','w');

%una vez establecido el mapeo, pasamos a usarlo para los x y z

display('Grabando ficheros')

contador=1;
for h=1:length(x)    
			[lax nada laz]=coor_a_BTB(longitud(h),latitud(h),0,mapeo);
			x(h)=lax;
			y(h)=laz;
            [pos1 pos3 pos2]=BTB_a_coor(x(h),0,y(h),mapeo);%Altura es el segundo
            posic1(contador)=pos1;
            posic2(contador)=pos2;
            contador=contador+1;
            fprintf(fid,'%f,%f,%f\n',pos1,pos2,0);
    
end
my_fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

xy = [x;y]; df = diff(xy,1,2); 

%Cálculo basto de la longitud
to = cumsum([0, sqrt([1 1]*(df.*df))]);  %La variable es la distancia
cv = spline(to,xy);

%Cálculo más exacto de la longitud
total_de_puntos=round(max(to));
t=linspace(to(1),to(end),total_de_puntos);%Todo el recorrido dividido porciones de 1m
nuevosnodos=1:10:length(t);%Me puedo dejar fuera el último nodo
% if nuevosnodos(end)~=length(t)
	% nuevosnodos=[nuevosnodos length(t)];
% end

%Distancia, mejor medida
distancia = [0 cumsum(sqrt(sum(diff(ppval(cv,t),1,2).^2,1)))];
cv=spline(distancia(nuevosnodos),ppval(cv,distancia(nuevosnodos))); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
indices=to(1):1:to(end); %Metro a metro dibujo la curva
puntos=ppval(cv,indices);

indicesakima=to(1):1:to(end);
coord=to;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Curva interpolada con akima metro a metro (indicesakima son un punto cada metro)
yakima=akima(coord,y,indicesakima);
xakima=akima(coord,x,indicesakima);

%Vuelvo a ajustar la curva con splines de tipo akima
plot(xakima,yakima,'+r');
xaya=[xakima';yakima'];
cspl=spline(indicesakima,xaya); %cspl son coeficientes de spline para la curva akima
puntosdef=ppval(cspl,indices);  %puntosdef son los puntos de la interpolación spline, metro a metro

plot(puntosdef(1,:),puntosdef(2,:),'r',x,y,'+');%,puntos(1,:),puntos(2,:),'b');
%hold on

xaya=[xakima';yakima'];


minimo=4; %Partimos de un spline con nodos cada 4 metros

puntos_ruptura=zeros(length(xakima),1);
iniciales=1:minimo:length(puntos_ruptura)-1;
puntos_ruptura(iniciales)=1; %Partimos de un nodo cada minimo metros y vamos eliminando
puntos_ruptura(end)=1;
mascara=1+0*puntos_ruptura;
colores='bmg';

%Comprobamos la calidad del ajuste si usásemos todos los nodos (máscara está toda a 1).
indices=puntos_ruptura.*mascara;
nindices=find(indices==1);
cv = spline(indicesakima(nindices),xaya(:,nindices));
nuevos_valores=ppval(cv,indicesakima);
distancias=xaya-nuevos_valores;
[error_maximo posemax]=max(sqrt([1 1]*(distancias.*distancias)));

mensaje=sprintf('Error inicial: %.2f (%d,%d)',error_maximo,xaya(1,posemax),xaya(2,posemax)); %El error con un nodo cada minimo metros
display(mensaje);

if error_maximo>=tolerancia
    display('ERROR: The kml has a problem in the coordinates shown above. Repair it or use a bigger tolerance value (second parameter)');
    return
end


%iniciales es la posición inicial de los nodos
%puntos_ruptura tiene un 1 donde están los nodos iniciales
display('Simplificando nodos. Paso1');
[mascara nelim]=simplificanodos(mascara,iniciales,puntos_ruptura,indicesakima,xaya,tolerancia);
disp('Se han eliminado '), disp(nelim), disp('nodos');

%Nueva pasada


segunda_pasada=0;
if segunda_pasada==1
	puntos_ruptura=puntos_ruptura.*mascara;
	indices_bp=find(puntos_ruptura.*mascara==1);
	mascara=1+0*puntos_ruptura;
	iniciales=indices_bp; %Partimos de los nodos aceptados en el paso anterior
	display('Simplificando nodos. Paso2');
	[mascara nelim]=simplificanodos(mascara,iniciales,puntos_ruptura,indicesakima,xaya,1);
	disp('Se han eliminado '), disp(nelim), disp('nodos');
end

%Si los nodos están demasiado alejados, ponemos nodos intermedios para que en altura haya más resolución
%plot(diff(find(mascara.*puntos_ruptura==1)))

%Me aseguro de que los puntos inicial y final se conservan
mascara(1)=1;
puntos_ruptura(1)=1;
mascara(end)=1;
puntos_ruptura(end)=1;

salir=0;
while salir==0,
    indices_bp=find(puntos_ruptura.*mascara==1);
    separacion_nodos=diff(indices_bp);%separación en metros
    problemas=find(separacion_nodos>(minimo*20)); % Si hay más de 80 metros de separación, actuamos
	display(sprintf('-%d\n',length(problemas)));
	if length(problemas)==0
		salir=1;
	else %de uno en uno
		mascara(indices_bp(problemas(1))+10*minimo)=1; %Los nodos están espaciados minimo, por lo que en 10*minimo puntos_ruptura debería tener un 1
		%disp(puntos_ruptura(indices_bp(problemas(1)+10)));
	end
end


ajuste=spline(indicesakima(indices_bp),xaya(:,indices_bp));
puntosbtb=ppval(ajuste,indicesakima);

figure
plot(puntosbtb(1,:),puntosbtb(2,:),'r',x,y,'+',puntosbtb(1,indices_bp),puntosbtb(2,indices_bp),'o');
axis square

[controlA controlB controlC controlD]=saca_controlpoints(ajuste.P,ajuste.x);

plot(controlA(1,:),controlA(2,:),'o',controlB(1,:),controlB(2,:),'*',controlC(1,:),controlC(2,:),'b+',controlD(1,:),controlD(2,:),'r+');


[alturas_nodos anguloy]=procesar_alturas(altura,to,t,indicesakima(indices_bp));
plot(1:length(altura),altura,1:length(indices_bp),0*alturas_nodos,'o');

%WARNING Pongo las alturas a 0 porque un conjunto de alturas incoherente puede hacer que btb06 genere demasiados anchors (un gran salto en altura se tomaría como una gran distancia entre nodos)
imprime_track(controlA,controlB,controlC,controlD,0*alturas_nodos,0*anguloy);

display('Creating salida\Venue.xml')
system('copy Venue_start.txt+salida\nodes.xml+Venue_end.txt salida\Venue.xml/b');
display('salida\nodes.xml copied to ..\Venue folder')
system('copy salida\nodes.xml ..\Venue\./b'); 
procedencia='importakml'; 
save('..\venue\procedencia.mat','procedencia');


message(1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5

function imprime_track(controlA,controlB,controlC,controlD,alturas_nodos,angulover)
	
	fid=my_fopen('salida\nodes.xml','w');
	fprintf(fid,'      <nodes count=\"%d\">\n        %s\n        %s\n',length(controlA)+1,'<OnlyOneNodeSelected>1</OnlyOneNodeSelected>','<LineType>BezierSpline</LineType>');
	for h=1:length(controlA)+1
		altura=alturas_nodos(h);
		anguloy=-angulover(h);
		if h<=length(controlA)
			complejo=-j*(controlB(1,h)-controlA(1,h))-(controlB(2,h)-controlA(2,h));
			angulo=angle(complejo);
			exdis=abs(complejo);
		end
		if h==1
			
			imprime_nodo(fid,h-1,controlA(1,h),controlA(2,h),altura,angulo,anguloy,0,exdis);
		elseif h==(length(controlA)+1)
			complejo=-j*(controlD(1,h-1)-controlC(1,h-1))-(controlD(2,h-1)-controlC(2,h-1));
			angulo=angle(complejo);
			endis=abs(complejo);
			imprime_nodo(fid,h-1,controlD(1,h-1),controlD(2,h-1),altura,angulo,anguloy,endis,0);
		else
			complejo=-j*(controlD(1,h-1)-controlC(1,h-1))-(controlD(2,h-1)-controlC(2,h-1));
			angulo=angle(complejo);
			endis=abs(complejo);
			imprime_nodo(fid,h-1,controlA(1,h),controlA(2,h),altura,angulo,anguloy,endis,exdis);
        end

	end
    fprintf(fid,'      </nodes>');
    my_fclose(fid);
end


function imprime_nodo(fid,h,Px,Pz,Py,AXZ,AY,EnD,ExD);
	
	fprintf(fid,'        <node NodeId=\"%d\">\r\n',h);
	fprintf(fid,'          <Position x=\"%f\" y=\"%f\" z=\"%f\" />\r\n',Px,Py,Pz);
	fprintf(fid,'          <ControlPoints AngleXZ=\"%f\" AngleY=\"%f\" EntryDistance=\"%f\" ExitDistance=\"%f\" />\r\n',AXZ,AY,EnD,ExD);
	fprintf(fid,'        </node>\r\n');

end

function [mascara nelim]=simplificanodos(mascara,iniciales,puntos_ruptura,indicesakima,xaya,umbral)

azar=desorden(length(iniciales)-2);
azar=azar+1;

for g=2:length(iniciales)-1
	h=iniciales(azar(g-1));
	mascara(h)=0;
	indices=puntos_ruptura.*mascara;
	nindices=find(indices==1);
	cv = spline(indicesakima(nindices),xaya(:,nindices));
	nuevos_valores=ppval(cv,indicesakima);
	distancias=xaya-nuevos_valores;
	error_maximo=max(sqrt([1 1]*(distancias.*distancias)));
	if error_maximo<umbral		
		%Borramos ese punto
	else
		mascara(h)=1; %Ese nodo hace falta
    end
        if mod(g,200)==0	
	        mensaje=sprintf('%.2f Error: %f\n',g/length(iniciales),error_maximo);
	        display(mensaje);
        end
end
mascara(1)=1;
mascara(end)=1;

nelim=sum(puntos_ruptura)-sum(puntos_ruptura.*mascara);
mensaje=sprintf('Eliminados %d nodos',nelim);
end


function [alturas_nodos anguloy]=procesar_alturas(alturas,to,t,distancias);
	figure
        axis square
    %ajuste=spline(to,alturas);
    %alturas_regulares=ppval(ajuste,t);
	alturas_regulares=akima(to,alturas,t);
	alturas_regulares=sgolayfilt(alturas_regulares,3,19);%Están separados 1m, más o menos
	ajuste=spline(t,alturas_regulares);
	plot(to,alturas,t,alturas_regulares);
    numpuntos=length(alturas_regulares);

    separacion=t(2)-t(1);
    inc_altura=alturas_regulares(2)-alturas_regulares(1);
    angulos(1)=angle(separacion+j*inc_altura);

    separacion=t(numpuntos)-t(numpuntos-1);
    inc_altura=alturas_regulares(numpuntos)-alturas_regulares(numpuntos-1);
    angulos(numpuntos)=angle(separacion+j*inc_altura);

    for h=2:numpuntos-1
	    separacion=t(h+1)-t(h-1);
	    inc_altura=alturas_regulares(h+1)-alturas_regulares(h-1);
	    angulos(h)=angle(separacion+j*inc_altura);
    end
	
	angulos=unwrap(angulos);
	ajuste_angulos=spline(t,angulos);

	anguloy=ppval(ajuste_angulos,distancias);
	alturas_nodos=ppval(ajuste,distancias);
end



function lista=desorden(n)
lista=zeros(1,n);
for h=1:n
   posicion=randint(1,1,n-(h-1))+1;
   huecos=find(lista==0);
   lista(huecos(posicion))=h;  
end

end
