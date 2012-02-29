function check_kmls(vergrafica)
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
	 %plot(altura(1:contador-1));
	 %pause;
     cadena=sprintf('%s === %.1f\t\t%.1f\n',nombre,min(altura(1:(contador-1))),max(altura(1:(contador-1))));
     display(cadena)
end




end
