function read_grid(vergrafica)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

if nargin>0
    display('Uso: sin parámetros. Compruebe que la información en pantalla coincide con los parámetros usados con make_grid')
end


S=load('dimensiones.mat','num_filas','num_columnas','guarda_calentamiento');
num_filas=S.num_filas;
num_columnas=S.num_columnas;
guarda_calentamiento=S.guarda_calentamiento;

%Leer los kml
pos1=[];
pos2=[];
altura=[];
[errores,nadena]=system('dir salida\grid*relleno.kml /b');
numero_ficheros=length(findstr(nadena,'.')); %Hay tantos ficheros como puntos en nadena

pos1=zeros(num_filas*num_columnas,1);
pos2=zeros(num_filas*num_columnas,1);
altura=zeros(num_filas*num_columnas,1);

contador=1;
for g=1:numero_ficheros
    nombre=sprintf('salida\\grid%.3d_relleno.kml',g);
    [nada1 nada2 trozoy]=leer_datos(nombre);
    % De cada num_filas+guarda_calentamiento datos, los guarda_calentamiento primeros son para tirar
      for h=1:length(nada1)/(num_filas+guarda_calentamiento)
        nuevos1=nada1((h-1)*(num_filas+guarda_calentamiento)+guarda_calentamiento+1:h*(num_filas+guarda_calentamiento));	
        nuevos2=nada2((h-1)*(num_filas+guarda_calentamiento)+guarda_calentamiento+1:h*(num_filas+guarda_calentamiento));
        nuevos3=trozoy((h-1)*(num_filas+guarda_calentamiento)+guarda_calentamiento+1:h*(num_filas+guarda_calentamiento));

        pos1(contador:contador+length(nuevos1)-1)=nuevos1;
        pos2(contador:contador+length(nuevos2)-1)=nuevos2;
	nuevas_alturas=nuevos3;
	if length(find(nuevas_alturas==-9999))
                display('-------------------------------------------------')
		display(sprintf('ERROR: value -9999 found in file %s',nombre));
                display('---press any key to continue---------------------')
                pause
	end
        altura(contador:contador+length(nuevos3)-1)=nuevos3;
        contador=contador+length(nuevos3);
     end       
end


display('Leyendo ..\mapeo.txt')
[mapeo]=textread('..\mapeo.txt','%f');

contador=1;

longmin=pos1(1);
longmax=pos1(end);

%Dos coordenadas terrestres son iguales si satisfacen este criterio (valor no depurado)
%pasoslat=length(find(abs(pos1-pos1(1))<0.00002));
%pasoslong=length(find(abs(pos2-pos2(1))<0.00002));
pasoslat=num_filas;
pasoslong=num_columnas;

latmin=pos2(1);
latmax=pos2(end);

rangolong=linspace(longmin,longmax,pasoslong);
rangolat=linspace(latmin,latmax,pasoslat);

%if length(altura)~=(length(rangolong)*length(rangolat))
%  mensaje=sprintf('ERROR: There should be %d*%d=%d points but _relleno files have only %d',length(rangolong),length(rangolat),length(rangolong)*length(rangolat),length(altura));
%    display(mensaje);
%    return
%end

[xmin nada zmin]=coor_a_BTB(longmin,latmin,0,mapeo);
[xmax nada zmax]=coor_a_BTB(longmax,latmax,0,mapeo);

rangox=linspace(xmin,xmax,pasoslong);
rangoz=linspace(zmin,zmax,pasoslat);

display(sprintf('x=[%.1f,%.1f] (%.1fm) z=[%.1f,%.1f] (%.1fm)\n',xmin,xmax,rangox(2)-rangox(1),zmin,zmax,rangoz(2)-rangoz(1)));

contadorx=1;
alto=0;
[x y z]=coor_a_BTB(pos1,pos2,altura,mapeo);
M=reshape(y,length(rangoz),length(rangox));

datax=x;
datay=y;
dataz=z;
malla_regular=M;

save -binary 'salida\lamalla.mat' rangox rangoz malla_regular


data=[(100000+(1:length(datax)))' datax dataz datay];
m=size(data);
data=reshape(data',1,m(1)*m(2),1);
fid=my_fopen('datos_altura.geo','w')

fprintf(fid,'       Point(%d) = {%f, %f, %f, 1};\n',data);

my_fclose(fid);

message(2);

if nargin==1
   surf(rangox,rangoz,malla_regular);
end


end