function procesar_nodostxt_agr(amp_ruido)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.


fichero_entrada='nodos.txt';

if nargin>1
    display('Puede tener como par�metro de entrada la amplitud m�xima de ruido deseada en las alturas generadas')
    display('Lee nodos.txt y le da altura seg�n lamalla.mat y lamalla2.mat');
    display(' ');
    display('Ejemplo: procesar_nodostxt([0 0.5])');    
    display(' ');
    display('Salida:');
    display('-> listado_anchors.txt (es el listado de anchors que se incorporar� tal cual al Venue.xml)');
    display('-> nodos_conaltura.txt (es un listado de nodos y alturas �til para procesar_elementstxt.m)');
    display('-> prueba.geo (archivo que permite comprobar en gmsh que los nodos generados son correctos)');
    return
end
if nargin==0
   amp_ruido=[0 0];
else if length(amp_ruido)==1
         amp_ruido=[0 amp_ruido];
     end
end

[numero x z y]=textread(fichero_entrada,'%d %f %f %f');

%Los nodos no tienen altura, as� que hay que cargar los datos de los xml
%para interpolar la altura en ese punto de la malla

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[numero_padres caminos]=look_for_father_or_sons('..\father.txt');

if numero_padres==0  
	[mapeo]=textread('..\mapeo.txt','%f');
else
	[mapeo]=textread(strcat(caminos(1),'\mapeo.txt'),'%f');
end

x_deseados=x;
z_deseados=z;

[pos1 pos3 pos2]=BTB_a_coor(x_deseados,0,z_deseados,mapeo);%Altura es el segundo

%Los datos LiDAR mantienen las coordenadas originales, as� que hay que pasar los datos a ese sistema de coordenadas
fid=fopen('deseados.txt','w');

tamanyo=length(numero);
for h=1:tamanyo
  fprintf(fid,'%f %f\r\n',pos1(h),pos2(h));
end
fclose(fid);

y=elevar_agr('deseados.txt')';
if length(y)!=tamanyo
    display('ERROR FOUND');
	display('ERROR FOUND');
	return
end

if find(isnan(y)==1)
    display('SOME POINTS OF THE MESH WILL HAVE A WRONG ALTITUDE. CHECK THAT YOUR MESH DOESN''T EXCEED AVAILABLE DATA');
end

try
	if sum(datay==NaN)>1
		display('Valores err�neos');
		return;
	end
catch
	display('...')
end

datan=[(1:tamanyo)' x y z];
data=[x y z];

m=size(datan);
datan=reshape(datan',1,m(1)*m(2),1);
m=size(data);
data=reshape(data',1,m(1)*m(2),1);


fid=my_fopen('salida\listado_anchors.txt','w');
fid2=my_fopen('salida\nodos_conaltura.txt','w');

fprintf(fid,'     <TerrainAnchors count="%d">\n',tamanyo);
fprintf(fid,'       <TerrainAnchor>\n         <Position x="%f" y="%f" z="%f" />\n       </TerrainAnchor>\n',data);
fprintf(fid2,'%d %f %f %f\n',datan);
fprintf(fid,'     </TerrainAnchors>\n');

my_fclose(fid);
my_fclose(fid2);


datan=[(1:tamanyo)' x z y];
m=size(datan);
datan=reshape(datan',1,m(1)*m(2),1);


fid=my_fopen('prueba.geo','w');
fprintf(fid,'       Point(%d) = {%f, %f, %f, 1};\n',datan);
my_fclose(fid);

datax=x;
datay=y;
dataz=z;
save('salida\anchors_originales.mat','datax','datay','dataz');

msh_to_obj('salida\nodos_conaltura.txt','elements.txt');
message(22)


function [indices indicesfuera]=comprobar_rangos(rangox,rangoz,x,z)

dentrodelrango=(x>=min(rangox)).*(x<=max(rangox)).*(z>=min(rangoz)).*(z<=max(rangoz));
indices=find(dentrodelrango==1);
indicesfuera=find(dentrodelrango==0);
