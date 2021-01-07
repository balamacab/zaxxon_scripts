function [lista_pacenotes]=calcular_pacenotes(x,z,pendientes,angulos,distancias,sensibilidad,adelanto);
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

%-----------------------------------------------------------------------------------------
%                                          Parámetros de configuración

anchoint=5; %5*5=25m Puntos que definen el centro de la curva
ancho=21; %17*5=85m  Puntos que definen la curva completa

%sensibilidad=0.02-0.04

%-----------------------------------------------------------------------------------------
%                                          Suavizando

cambio_angulo=angulos*0;
cambio_angulo(1)=0;
cambio_angulo(2:end)=angulos(2:end)-angulos(1:end-1);
%cambio_angulo=-S.cambio_angulo;

%-----------------------------------------------------------------------------------------
%                                          Suavizando

filterorder=anchoint;
curvatura=cambio_angulo;
filtro=ones(filterorder,1)/filterorder; 
salida=filter(filtro,1,curvatura);
salida=salida((length(filtro)-1)/2:end);

%-----------------------------------------------------------------------------------------
%                                   Calculando máximos y mínimos

display('Caracterizando curvas');

[maxtab, mintab]=peakdet(salida,sensibilidad);
maximospositivos=find(maxtab(:,2)>0);
maxtab=maxtab(maximospositivos,:);
minimosnegativos=find(mintab(:,2)<0);
mintab=mintab(minimosnegativos,:);

figure
hold on 
plot(distancias(1:length(salida)),(180/pi)*salida);%,maxtab(:,1),salida(maxtab(:,1)),'+',mintab(:,1),salida(mintab(:,1)),'o');
	
%----------------------------------------------------------------------------------------
%                                    Juntar y ordenar máximos y mínimos

indices=[maxtab(:,1)' mintab(:,1)'];
magnitudes=[salida(maxtab(:,1)) salida(mintab(:,1))];

[B,IX] = sort(indices,2,'ascend');
indices=indices(IX);
magnitudes=magnitudes(IX);

plot(distancias(indices),(180/pi)*magnitudes,'xb');
%leyenda=sprintf('Blue -> %.0fm, Red -> %.0fm',anchoint*5,ancho*5);
%legend(leyenda);

%---------------------------------------------------------------------------------------
%                       Asignar pacenotes según la magnitud
  
figure;
axis('equal');
hold on;
 
plot(x,z,'or');
leyenda=sprintf('C->Angle turned in center (%.1fm)\nT->Angle turned in total (%.1fm)',anchoint*5,ancho*5);
legend(leyenda);

contador=0;
display('Procesando las curvas');

for h=1:length(magnitudes)
   if (indices(h)>1) & (indices(h)<length(angulos))
	magnitud=anchoint*magnitudes(h);
	girocentral=(180/pi)*magnitud;
	signo=sign(girocentral);
	girototal=dame_acumulado(salida,indices(h),(ancho-1)/2);
	
	nodo=indices(h);
	%Para poner el texto en pantalla
	posx=x(nodo)+10;
	posz=z(nodo);
        if (nodo-adelanto)>0, nodo=nodo-adelanto; else nodo=1; end

	[Tipo indice_pn flag]=asignar_pacenote(girocentral,girototal);
	
	tabla_codigos=[11 10 9 8 7 0 1 2 3 4]; %Derecha 5 primeros, izquierda 5 luego. De mayor a menor peligrosidad
	if strcmp(Tipo,'-')==0
		if signo>0
			Tipo=strcat(Tipo,' Right');
			codigo=tabla_codigos(indice_pn);
		else
			Tipo=strcat(Tipo,' Left');
			codigo=tabla_codigos(indice_pn+length(tabla_codigos)/2);
		end		
		contador=contador+1;		
                lista_pacenotes(contador).Nombre=Tipo;
		lista_pacenotes(contador).Tipo=codigo;
                lista_pacenotes(contador).flag=flag;
                lista_pacenotes(contador).nodo=nodo;                
		if distancias(nodo)-adelanto>0
			lista_pacenotes(contador).distancia=distancias(nodo)-adelanto;
		else
			lista_pacenotes(contador).distancia=0;
		end
		mensaje=sprintf('C=%.2f T=%.2f %s(%d)',girocentral,girototal,Tipo,flag);
		text(posx,posz,mensaje);
		plot(x(indices(h)-1),z(indices(h)-1),'o');%-1 porque las derivadas adelantan la posición de las cosas en el espacio
	end
    end
end
 
%--------------------------------------------------------------------------------------- 
mensaje=sprintf('Hay %d pacenotes',contador);
display(mensaje);


%---------------------------------------------------------------------------------------

function angulo=dame_angulo(x,y,z,h,distancia)
	if ((h-distancia)<1)||((h+distancia)>length(x))
		angulo=0;
	else
		punto_entrada=[x(h-distancia)  z(h-distancia)];
		punto_salida=[x(h+distancia)  z(h+distancia)];
		punto_central=[x(h) z(h)];
	
		vector_entrada=punto_central-punto_entrada;
		vector_entrada=vector_entrada/norm(vector_entrada,'fro');
		vector_salida=punto_salida-punto_central;
		vector_salida=vector_salida/norm(vector_salida,'fro');
		prodesc=dot(vector_entrada,vector_salida);
		angulo=acos(prodesc);
		angulo=360*angulo/(2*pi);
	end
end 

%---------------------------------------------------------------------------------------

function distancia=dame_distancia(inicio,fin,x,y,z)
	nac=length(x);
	distancia=0;
	for h=inicio+1:fin
		distancia_izq=sqrt((x(h)-x(h-1))^2+(y(h)-y(h-1))^2+(z(h)-z(h-1))^2)^(1/2);
		hd=h+nac/2;
		distancia_dcha=sqrt((x(hd)-x(hd-1))^2+(y(hd)-y(hd-1))^2+(z(hd)-z(hd-1))^2)^(1/2);
		distancia=distancia+min([distancia_izq distancia_dcha]);
	end
end

%---------------------------------------------------------------------------------------

function  [acumulado]=dame_acumulado(curvatura,h,ancho);
        signo=sign(curvatura(h));
        
        incremento=1;
        acumulado=curvatura(h)/2;
        while  (incremento<=ancho) && ((h+incremento)<=length(curvatura)) && (sign(curvatura(h+incremento))==signo) 
            acumulado=acumulado+curvatura(h+incremento);
            incremento=incremento+1;
        end
        acumulado_izquierda=acumulado;

        incremento=1;
        acumulado=curvatura(h)/2;
        while (incremento<=ancho) && ((h-incremento)>=1) && (sign(curvatura(h-incremento))==signo) 
            acumulado=acumulado+curvatura(h-incremento);
            incremento=incremento+1;
        end
        acumulado_derecha=acumulado;
		
		acumulado=(180/pi)*(acumulado_derecha+acumulado_izquierda);
end
%---------------------------------------------------------------------------------------
