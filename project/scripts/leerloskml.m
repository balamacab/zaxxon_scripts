function [x y z]=leerloskml()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

%Leer los kml
pos1=[];
pos2=[];
altura=[];
[errores,nadena]=system('dir salida\datos*relleno.kml /b');
numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena

for g=1:numero_ficheros
	nombre=sprintf('salida\\datos%.3d_relleno.kml',g);
	%[nada1 nada2 trozoy]=textread(nombre,'%f,%f,%f ');	
	[nada1 nada2 trozoy]=leer_datos(nombre);	
%     matriz=dlmread(nombre,', ');
%     nada1=matriz(:,1);
%     nada2=matriz(:,2);
%     trozoy=matriz(:,3);
    pos1=[pos1;nada1];
    pos2=[pos2;nada2];
    altura=[altura;trozoy];       
end

[mapeo]=textread('..\mapeo.txt','%f');

for h=1:length(pos1)
     [x(h) y(h) z(h)]=coor_a_BTB(pos1(h),pos2(h),altura(h),mapeo);
end

datax=x;
datay=y;
dataz=z;

save 'salida\lamalla.mat' datax datay dataz


fid=fopen('datos_altura.geo','w')

for h=1:length(datax)
    fprintf(fid,'       Point(%d) = {%f, %f, %f, 1};\n',100000+h,datax(h),dataz(h),datay(h));%%Les pongo altura cero para que me ayuden a hacer el mallado
end

fclose(fid);

end
