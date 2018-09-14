function ponerpn(ficherotrk,ficherodls,anticipacion)
%ficherodls='129pacenotes.dls';
[vector coordenadas dist]=leetrk(ficherotrk);
if nargin==2
  anticipacion=0;%Metros de antelacion
end
tx=vector(:,1);
tz=vector(:,2);
x=coordenadas(:,1);
z=coordenadas(:,2);
distancia=dist;

%-----------------------------------------------------------------------------------------
%                              Remuestreamos para obtener muestras cada 5m 

equidistantes=min(distancia):5:max(distancia)-5;

%figure;%hold on;
metodo='spline';

x=interp1(distancia,x,equidistantes,metodo);
z=interp1(distancia,z,equidistantes,metodo);

vx=[0 diff(x)];
vz=[0 diff(z)];
complejo=vx+j*vz;
angulos=angle(complejo);
angulos=unwrap(angulos);
for h=1:length(angulos)%
	if mod(h,500)==0
		mensaje=sprintf('%.2f',angulos(h));
		display(mensaje);
	end	
end
%complejo=[0 complejo];
%angulos=[0 angulos];

%angulos=interp1(distancia,angulos,equidistantes,metodo);

%-----------------------------------------------------------------------------------------
%                              Calcular pendiente
ty=vector(:,3);

pendiente=atan(ty./abs(complejo));
%plot(distancia,pendiente);

%-----------------------------------------------------------------------------------------
%                              Salvamos

%save 'driveline.mat' x z angulos equidistantes pendiente;
%S=load('driveline.mat');
S.x=x;S.z=z;S.pendiente=pendiente;S.angulos=angulos;S.equidistantes=equidistantes;

matriz=leerdls(ficherodls);
colcodigo=matriz(:,1);
filasvalidas=find((colcodigo>=21).*(colcodigo<=24));
matriz=matriz(filasvalidas,:);
%Nos quedamos solo con los elementos en el rango 21-24
%matriz=[ 21 0 80.000000;  %START          
% 23 0 1500.000000;           %CHECKPOINT 
% 23 0 3000.000000;           %CHECKPOINT
% 22 0 5630.000000;           %FINISH 
% 24 0 5700.000000]           %EXIT
 
resultado=procesarpn(S.x,S.z,S.pendiente,-S.angulos,S.equidistantes,0.04,0);

fid=fopen(ficherodls,'r');
texto=fread(fid,8);
inicio1=fread(fid,16*7+4+12);
longitud=inicio1(85);
inicio_datos=ftell(fid);
%for h=1:4 %Inicio, 2 checkpoints y final    
%    cod1(h)=fread(fid,1,'integer*4');
%    cod2(h)=fread(fid,1,'integer*4');
%    punto(h)=fread(fid,1,'single');
%end
fclose(fid);

fid=fopen(ficherodls,'r');
todo=fread(fid,inf);
fclose(fid);
%fprintf(1,'%d %d\n',[(1:length(todo))' todo]');

[mm,nn]=size(matriz);
for h=1:length(resultado)
    matriz(mm+h,:)=[resultado(h).Tipo 0 resultado(h).distancia-anticipacion];
end
[mm,nn]=size(matriz);

%ftell is zero-based
fid=fopen(['salida/' ficherodls],'w');
todo(85+9)=floor(mm/256);
todo(85+8)=mod(mm,256);

fwrite(fid,todo(1:inicio_datos));%
%fclose(fid);return
for h=1:mm 
        fwrite(fid,matriz(h,1),'uint32');
        fwrite(fid,matriz(h,2),'uint32');
        fwrite(fid,matriz(h,3),'single');
end
fwrite(fid,todo(inicio_datos+longitud*12+1:end));
fclose(fid);


