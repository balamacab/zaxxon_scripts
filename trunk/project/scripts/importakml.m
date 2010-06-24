function importakml(ficherokml,optimize_choice,decimate_factor)
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

if (nargin<1) || (ficherokml=='h')
	disp('Use: importakml(''file.kml''');
	return;
end

if nargin==2
    disp('-----------------------------------------------');
	disp('Use: importakml(''file.kml'')');
	disp('Use: importakml(''file.kml'',''decimate'',2)');
	disp('If you want to use the previous version, call importakml_old');
	disp('-----------------------------------------------');
	return;
end

if nargin==1
	optimize_choice='keep';
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
	fid=fopen('..\mapeo.txt','r'); %Si existe no lo sobreescribimos, solo lo usamos
	if fid==-1
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
	else
		display('----------------------------------------------------------------------')
		display('                                                                     -')
		display('WARNING: Using existing ..\mapeo.txt. ');
		display('Delete it if you want to create a new one and run again this script')
		display('                                                                     -')
		display('----------------------------------------------------------------------')
		fclose(fid);
	end	
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

disakima=to(1):1:to(end);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Curva interpolada con akima metro a metro (disakima son un punto cada metro)
yakima=akima(to,y,disakima);
xakima=akima(to,x,disakima);

if (strcmp(optimize_choice,'keep')==1)
	seleccion=to;
else
	if (strcmp(optimize_choice,'decimate')==1) 
		indices_seleccion=1:decimate_factor:length(to);
		if indices_seleccion(end)~=length(to)
			indices_seleccion=[indices_seleccion length(to)];
		end
		seleccion=to(indices_seleccion);
	else
		if (strcmp(optimize_choice,'optimize')==1) 
			mascara=1+0*to;%Todos los puntos del kml son buenos en principio
			seleccion=simplificanodos(disakima,xakima,yakima,decimate_factor,to);
		end
	end
end
ajuste=ajusta(disakima,xakima,yakima,seleccion);
%Obtenemos puntos para visualizacióm
puntosbtb=ppval(ajuste,disakima);

figure
plot(puntosbtb(1,:),puntosbtb(2,:),'-r',x,y,'b+');
axis square

[controlA controlB controlC controlD]=saca_controlpoints(ajuste.P,ajuste.x);
graba_kml([controlA(1,:)],[controlA(2,:)],mapeo);

%plot(controlA(1,:),controlA(2,:),'o',controlB(1,:),controlB(2,:),'*',controlC(1,:),controlC(2,:),'b+',controlD(1,:),controlD(2,:),'r+');


%[alturas_nodos anguloy]=procesar_alturas(altura,to,t,disakima(indices_bp));
%plot(1:length(altura),altura,1:length(indices_bp),0*alturas_nodos,'o');
alturas_nodos=zeros(size(seleccion));
anguloy=zeros(size(seleccion));

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

function [nuevos_nodos]=simplificanodos(disakima,xakima,yakima,umbral,to)

%Consideramos tramos desde 5 nodos antes hasta 5 después
margen=5;
nuevos_nodos=to;
nelim=0;
%Empezamos por el final para que la numeración del nodo investigado no cambie
for g=length(to)-margen:-1:1+margen
	nodo_testeado=nuevos_nodos(g);
	nuevos_nodos_test=[nuevos_nodos(1:g-1) nuevos_nodos(g+1:end)];
	rango=round(nuevos_nodos_test(1)):1:floor(nuevos_nodos_test(end));%Distancias que empiezan en 0
	
	cv = ajusta(disakima(rango+1),xakima(rango+1),yakima(rango+1),nuevos_nodos_test);
	nuevos_valores=ppval(cv,rango);
	distancias=[xakima(rango+1)';yakima(rango+1)']-nuevos_valores;
	error_maximo=max(sqrt([1 1]*(distancias.*distancias)));
	if error_maximo<umbral		
		nuevos_nodos=nuevos_nodos_test;
		nelim=nelim+1;
	else 
		%No hacemos nada con el punto
    end
        if mod(g,2)==0	
	        mensaje=sprintf('%.2f Error: %f\n',g/length(to),error_maximo);
	        display(mensaje);
        end
end

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

function ajuste=ajusta(disakima,xakima,yakima,seleccion);
ajustex=ppfit(disakima,xakima,seleccion);
ajustey=ppfit(disakima,yakima,seleccion);
%Juntamos los dos ajustes en un solo pp
ajustex.coefs=[ajustex.coefs(:,:);ajustey.coefs(:,:)];
ajustex.dim=2;
%Convertimos el pp al formato octave
ajuste=convert_pp(ajustex);




function npp=convert_pp(pp)
%Convert pp (matlab format) to npp (octave format)
npp.x=pp.breaks(:);
npp.n=pp.pieces;
npp.k=pp.order;
npp.d=pp.dim;
npp.P=pp.coefs(:,:);


function graba_kml(x,y,mapeo)
fid=my_fopen('..\s2_elevation\inicio.kml','r');
inicio=fread(fid,inf);
inicio=char(inicio)';
my_fclose(fid);

fid=my_fopen('..\s2_elevation\final.kml','r');
final=fread(fid,inf);
my_fclose(fid);

fid=my_fopen('salida\nodes_coordinates.kml','w');
fwrite(fid,inicio);
for h=1:length(x)
			[pos1 pos3 pos2]=BTB_a_coor(x(h),0,y(h),mapeo);%Altura es el segundo
            fprintf(fid,'%f,%f,%f\n',pos1,pos2,0);
end
fwrite(fid,final);			
my_fclose(fid);