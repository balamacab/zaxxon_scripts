function [alturas_suavizadas]=editar_altura(x,y,z,distancia_recorrida,alturas_suavizadas,alturas_track1)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

nac=length(x);

figure
hold on
plot(x(1:nac/2),z(1:nac/2));
plot(x(nac/2+1:end),z(nac/2+1:end));

for ddd=0:100:distancia_recorrida(end)
	[valor h]=min(abs(distancia_recorrida-ddd));
	if (h<1), h=1;, end
    plot(0.5*(x(h)+x(h+nac/2)),0.5*(z(h)+z(h+nac/2)),'+');
    text(x(h)+20,z(h),sprintf('%.0f',ddd/100));
end
title('One mark x100m')
axis 'equal'

putenv("GNUTERM","wxt");
fig=figure;
grid
hold on;
alturas_suavizadas_iniciales=alturas_suavizadas;

try
    fid=fopen('retoques.txt','r');
    retoques=fscanf(fid,'%d %d %d %f ',inf);
    fclose(fid);
	existia_fichero=1;
catch 
    existia_fichero=0;
end
if existia_fichero==1
    fid=my_fopen('retoques.txt','r');
    while ~feof(fid)
          try 
              numpoints=fscanf(fid,'%d ',1);
              puntos=[];
              for h=1:numpoints
			          n_puntos=fscanf(fid,'%f',2);
                puntos(h,1)=n_puntos(1);
                puntos(h,2)=n_puntos(2);
              end
              
	      [valor pos]=min(abs(distancia_recorrida-puntos(1,1)));
		inicio=pos;
        	  [valor pos]=min(abs(distancia_recorrida-puntos(end,1)));
		final=pos;
		coefr=spline(puntos(:,1),puntos(:,2));
		amplitudes=ppval(coefr,distancia_recorrida(inicio:final));
                %amplitudes=akima(puntos(:,1),puntos(:,2),distancia_recorrida(inicio:final));
		alturas_suavizadas(inicio:final)=amplitudes;
          end
    end
    my_fclose(fid);
end

salir=0;

while (salir==0)
    clf;
    plot(distancia_recorrida,alturas_track1,'-r',distancia_recorrida,alturas_suavizadas_iniciales,'-b',distancia_recorrida,alturas_suavizadas,'-k'); 
	hold on
	
	legend('Mountain (red)','Autofit (blue)','Edited (black)');
    fflush(stdout);
    display('        e-> end             n-> new segment');
    do
	opcion=input('','s');
    until (length(opcion)>0)
    if strcmp(opcion,'n')==1    
	
	puntos=pedir_coordenadas_spline();
	
	if (length(puntos)>2)
	  [valor pos]=min(abs(distancia_recorrida-puntos(1,1)));
		inicio=pos;
	  [valor pos]=min(abs(distancia_recorrida-puntos(end,1)));
		final=pos;
		coefr=spline(puntos(:,1),puntos(:,2));
		amplitudes=ppval(coefr,distancia_recorrida(inicio:final));
                %amplitudes=akima(puntos(:,1),puntos(:,2),distancia_recorrida(inicio:final));
		alturas_suavizadas(inicio:final)=amplitudes;

		fid=fopen('retoques.txt','a');
		fprintf(fid,'%d ',length(puntos(:,1)));
		for h=1:length(puntos(:,1))
			fprintf(fid,'%.1f %.1f ',puntos(h,1),puntos(h,2));
		end
		fprintf(fid,'\r\n');
		fclose(fid);
      	else
	  display('No points')
	end
    end
    if strcmp(opcion,'e')==1
          salir=1;
    end
endwhile



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function puntos=pedir_coordenadas_spline()
		salir=0;
		contador=1;
                puntos=[];
		do
			display('Left click to add point. FROM LEFT TO RIGHT. Right click to finish')
			[x y boton]=ginput(1);
			if (boton==3) %Bot�n derecho
				salir=1;			       
			else
			  if (contador==1) 
                                puntos(contador,1)=x;
			        puntos(contador,2)=y;
                                %zum=axis();
				%plot(x,y,'+');
                                %axis(zum);
				contador=contador+1;
        		  else
			    if (puntos(contador-1,1)<x)
                                puntos(contador,1)=x;
			        puntos(contador,2)=y;
                                %zum=axis();
				%plot(x,y,'+');
                                %axis(zum);
				contador=contador+1;
			    end
                          end
			end
		until (salir==1)	
end


function salida=recta(puntos,x);
	x0=puntos(1);
	y0=puntos(2);
	x1=puntos(3);
	y1=puntos(4);
	salida=y0+(x-x0)*(y1-y0)/(x1-x0);
end

end
