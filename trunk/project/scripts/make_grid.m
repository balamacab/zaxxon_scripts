function altura=make_grid(xmin,xmax,zmin,zmax,pasoenmetros,tamfichero)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

if (nargin==5)||(nargin==2)
  tamfichero=200000; %Por defecto se agrupan los datos en tamfichero puntos por kml
end
if nargin==3
  tamfichero=zmin;
end
if ((nargin~=5)&&(nargin~=6)&&(nargin~=2)&&(nargin~=3))||(xmin=='h')
    display('Par�metros:')
    display('1) X min')
    display('2) X max')
    display('3) Z min (coordenada Z en BTB, pero Y en gmsh)')
    display('4) Z max (coordenada Z en BTB, pero Y en gmsh)')
    display('5) Distancia en metros entre los puntos de la rejilla')
    display('6) Datos por fichero. Si se va a usar BTBLofty se recomienda no superar los 30000')
    return
end
%Obtiene las coordenadas de los puntos de la malla con mala definicion

if (nargin==2)||(nargin==3)
	pasoenmetros=xmax;
	[longitud latitud altura]=leer_datos(xmin);
	[mapeo]=textread('..\mapeo.txt','%f');
	[lax nada laz]=coor_a_BTB(longitud,latitud,0,mapeo);
	xmin=min(lax)-pasoenmetros;
	xmax=max(lax)+pasoenmetros;
	zmin=min(laz)-pasoenmetros;
	zmax=max(laz)+pasoenmetros;
end

if (xmin>=xmax)||(zmin>=zmax)
    display('ERROR: check parameters and make xmin < xmax, zmin < zmax')
end


display('Leyendo fichero ..\mapeo.txt')
[mapeo]=textread('..\mapeo.txt','%f');

%fid=my_fopen('salida\necesidades.txt','w');
%fid2=my_fopen('salida\necesidades.geo','w');

%display('Grabando ficheros')

guarda_calentamiento=0;
columnas=xmin:pasoenmetros:xmax;
num_columnas=length(columnas);
filas=zmin:pasoenmetros:zmax;
num_filas=length(filas);

contador=1;
posic1=zeros(length(columnas)*length(filas),1);
posic2=zeros(length(columnas)*length(filas),1);

for x=columnas
    if mod(contador,100)==0
        display(sprintf('%d',contador));
    end
    for z=filas
            [pos1 pos3 pos2]=BTB_a_coor(x,0,z,mapeo);%Altura es el segundo
            %fprintf(fid2,'       Point(%d) = {%f, %f, %f, 1};\n',contador,x,z,0);
            posic1(contador)=pos1;
            posic2(contador)=pos2;
            contador=contador+1;
            %fprintf(fid,'%f,%f,%f\n',pos1,pos2,0);
    end
end
%my_fclose(fid);
%my_fclose(fid2);

pos1=posic1;
pos2=posic2;
nada=0*pos1;

fid=my_fopen('inicio.kml','r');
inicio=fread(fid,inf);
inicio=char(inicio)';
my_fclose(fid);

fid=my_fopen('final.kml','r');
final=fread(fid,inf);
my_fclose(fid);

%N�mero de datos por columna real
columna_real=guarda_calentamiento+num_filas;
%Tama�o de fichero real en n�mero de puntos para que contenga un n�mero entero de columnas
ncol_fichero=floor(tamfichero/columna_real);
tamfichero=ncol_fichero*columna_real;

tandas=ceil(num_columnas/ncol_fichero);
contador=1;
for h=1:tandas
    nombre=sprintf('salida\\grid%.3d.kml',h);
    fid=my_fopen(nombre,'w');
    nombre_interno=sprintf('grid%.3d.kml',h);
    parte_inicial=strrep(inicio,'zaxxonisthebest',nombre_interno);
    fprintf(fid,'%s',parte_inicial);

    tamanyo=min([num_columnas-(h-1)*ncol_fichero ncol_fichero]);
    for k=1:tamanyo %numero de columnas en este fichero
        repite(fid,pos1(contador),pos2(contador),guarda_calentamiento);
        recorrido=1:num_filas;
        if mod(k,2)==0
            recorrido=fliplr(flipud(recorrido));
        end
        for g=recorrido
            fprintf(fid,'%f,%f,%f ',pos1(contador+g-1),pos2(contador+g-1),-9999);
            %contador=contador+1;
        end
        contador=contador+length(recorrido);
    end
    fwrite(fid,final);
    my_fclose(fid);
end
nombre=sprintf('salida\\grid%.3d.kml',tandas+1);
while (exist(nombre)==2)
	delete(nombre);
	display(sprintf('Deleting file %s',nombre));
	tandas=tandas+1;
	nombre=sprintf('salida\\grid%.3d.kml',tandas+1);
endwhile

    alternada=1;
    save('dimensiones.mat','num_filas','num_columnas','guarda_calentamiento','alternada');

message(20);	

    function repite(fid,longi,lati,repe)
    for g=1:repe
        fprintf(fid,'%f,%f,%f ',longi,lati,0);
    end
