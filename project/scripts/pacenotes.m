function pacenotes()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.


display('Leyendo ficheros')

%K0=4748.297, 476.4687, 2387.083, -0.2157628, -0.9757504, 0.03684066, 6.732297, 0
fid=fopen('driveline.ini','r')
contador=1;

fgets(fid);
linea=fgets(fid);
total=sscanf(linea,'COUNT=%d');

datos=zeros(total,9);

while ~feof(fid)
	linea=fgets(fid);
	if mod(contador,100)==0
		mensaje=sprintf('%d-%s',contador,linea);
		display(mensaje);
	end
	datos(contador,:)=sscanf(linea,'K%d=%f, %f, %f, %f, %f, %f, %f, %d')
	contador=contador+1;
	%[num x z y tx tz ty distancia_recorrida nada]=textread('driveline.ini','K%d=%f, %f, %f, %f, %f, %f, %f, %d');
end
fclose(fid)

display('Calculando curvaturas')


%-----------------------------------------------------------------------------------------
%                                         calculando giros 
tx=datos(:,5);
tz=datos(:,6);

complejo=tx+j*tz;
angulos=angle(complejo);
angulos=unwrap(angulos);
for h=1:length(angulos)%
	if mod(h,500)==0
		mensaje=sprintf('%.2f',angulos(h));
		display(mensaje);
	end	
end

%-----------------------------------------------------------------------------------------
%                              Remuestreamos para obtener muestras cada 5m 

x=datos(:,2);
z=datos(:,3);

%distancia = cumsum(sqrt([0;diff(x)].^2 + [0;diff(z)].^2));
distancia=datos(:,8);

equidistantes=min(distancia):5:max(distancia)-5;

%figure;
%hold on;
metodo='linear';

%plot(x,z,'b-');
x=interp1(distancia,x,equidistantes,metodo);
z=interp1(distancia,z,equidistantes,metodo);
%plot(x,z,'ro');
%figure;
%hold on;
%plot(distancia,angulos);
angulos=interp1(distancia,angulos,equidistantes,metodo);
%plot(equidistantes,angulos,'r');

%-----------------------------------------------------------------------------------------
%                              Calcular pendiente
%figure
ty=datos(:,7);

pendiente=atan(ty./abs(complejo));
%plot(distancia,pendiente);

%-----------------------------------------------------------------------------------------
%                              Salvamos

save -mat-binary 'driveline.mat' x z angulos equidistantes pendiente;
