function pacenotes_a()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.


display('Leyendo anchors');

S=load('..\anchors.mat');
nac=length(S.x);

x=0.5*(S.x(1:nac/2)+S.x(nac/2+1:end));
z=0.5*(S.z(1:nac/2)+S.z(nac/2+1:end));
y=0.5*(S.y(1:nac/2)+S.y(nac/2+1:end));
x=x';
y=y';
z=z';

tx=[0;diff(x)];
tz=[0;diff(z)];

%-----------------------------------------------------------------------------------------
%                                         calculando giros 

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

distancia = cumsum(sqrt([0;diff(x)].^2 + [0;diff(z)].^2));

equidistantes=min(distancia):5:max(distancia)-5;

metodo='linear';


x=interp1(distancia,x,equidistantes,metodo);
z=interp1(distancia,z,equidistantes,metodo);

angulos=interp1(distancia,angulos,equidistantes,metodo);


%-----------------------------------------------------------------------------------------
%                              Calcular pendiente
%figure

ty=[0;diff(y)];
pendiente=atan(ty./abs(complejo));

%-----------------------------------------------------------------------------------------
%                              Salvamos

save -mat-binary 'driveline.mat' x z angulos equidistantes pendiente;
