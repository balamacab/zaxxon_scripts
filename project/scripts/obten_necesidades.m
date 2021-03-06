function altura=obten_necesidades(limite)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

if nargin<1
    display('Par�metros:')
    display('1) Radio en el que un punto antiguo se da por aceptable')
    return
end
%Obtiene las coordenadas de los puntos de la malla con mala definicion

[mapeo]=textread('..\mapeo.txt','%f');
[numero x z y]=textread('nodos.txt','%d %f %f %f');

try
    S=load('lamalla.mat');
    datax=S.datax;
    datay=S.datay;
    dataz=S.dataz;
catch
    datax=[];
    datay=[];
    dataz=[];
end

%limite=15;% Proximidad entre dos puntos para aceptar que ese punto ya lo tenemos

altura=x'*0;

fid=fopen('salida\necesidades.txt','w');
fid2=fopen('salida\necesidades.geo','w');
for h=1:length(x)
        if mod(h,100)==0
            fprintf(1,'%.2f\n',h/length(x));
        end
        if length(datax)>0 %Miramos a ver si ya tenemos datos
            distancias1=sqrt((x(h)-datax).^2+(z(h)-dataz).^2);
            [valor1,pos1]=min(distancias1);
        else %Hace falta conseguir alturas para todos los puntos
            valor1=inf; %Valor1 es la distancia m�s peque�a a un punto que ya tenemos
        end
        if valor1>limite
            [pos1 pos3 pos2]=BTB_a_coor(x(h),0,z(h),mapeo);%Altura es el segundo
            fprintf(fid2,'       Point(%d) = {%f, %f, %f, 1};\n',h,x(h),z(h),y(h));
            fprintf(fid,'%f,%f,%f\n',pos1,pos2,0);
        end
end
fclose(fid);
fclose(fid2);

%[pos1 pos2 nada]=textread('salida\necesidades.txt','%f,%f,%f\n')
matriz=dlmread('salida\necesidades.txt');
pos1=matriz(:,1);
pos2=matriz(:,2);
nada=matriz(:,3);

fid=fopen('inicio.kml','r');
inicio=fread(fid,inf);
fclose(fid);

fid=fopen('final.kml','r');
final=fread(fid,inf);
fclose(fid);

tandas=ceil(length(pos1)/500);
contador=1;
for h=1:tandas
    nombre=sprintf('salida\\datos%.3d.kml',h);
    fid=fopen(nombre,'w')
    fwrite(fid,inicio);
    tamanyo=min([length(pos1)-(h-1)*500 500]);
    for g=1:tamanyo
        fprintf(fid,'%f,%f,%f\n',pos1(contador),pos2(contador),nada(contador));
        contador=contador+1;
    end
    fwrite(fid,final);
    fclose(fid);
end