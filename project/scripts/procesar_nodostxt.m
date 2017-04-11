function alturas=procesar_nodostxt(amp_ruido,datos_entrada,fichero_salida)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

if (exist('..\..\agr')==7) || (exist('..\..\lidar')==7)
	alturas=procesar_nodostxt_agr(amp_ruido,datos_entrada,fichero_salida)
	return
end

if nargin>3
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
   fichero_entrada='nodos.txt';
   fichero_salida='salida\nodos_conaltura.txt';
   [numero x z y]=textread(fichero_entrada,'%d %f %f %f');
else
    if length(amp_ruido)==1
         amp_ruido=[0 amp_ruido];
    end
    if nargin==1
        fichero_entrada='nodos.txt';
        fichero_salida='salida\nodos_conaltura.txt';
        [numero x z y]=textread(fichero_entrada,'%d %f %f %f');
    else
        numero=datos_entrada(:,1);
        x=datos_entrada(:,2);
        z=datos_entrada(:,3);
        y=datos_entrada(:,4);
    end
end






%Los nodos no tienen altura, as� que hay que cargar los datos de los xml
%para interpolar la altura en ese punto de la malla


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[datax datay dataz]=leerloskml();
malla=load('lamalla.mat');

try
    mallaB=load('lamalla2.mat');
catch
    display('No se ha encontrado una segunda malla');
end


display('Recalculando altura de anchors pr�ximos a carretera...');
x_deseados=x;
z_deseados=z;
[indices indicesfuera]=comprobar_rangos(malla.rangox,malla.rangoz,x_deseados,z_deseados);
y(indices)=z_interp2(malla.rangox,malla.rangoz,malla.malla_regular,x_deseados(indices),z_deseados(indices));
if length(indices)<length(x_deseados) %Si alg�n dato no ha sido obtenido de la malla principal, tratamos de sacarlo de la secundaria
	display('Buscando alturas para datos que caen fuera del mallado rectangular principal. Se usar� ''lamalla2.mat''');
	indices=indicesfuera;
	y(indices)=z_interp2(mallaB.rangox,mallaB.rangoz,mallaB.malla_regular,x_deseados(indices),z_deseados(indices));
end

y=double(y);
alturas=y;

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

tamanyo=length(numero);


datan=[(1:tamanyo)' x y z];

data=[x y z];

m=size(datan);
datan=reshape(datan',1,m(1)*m(2),1);
m=size(data);
data=reshape(data',1,m(1)*m(2),1);


fid=my_fopen('salida\listado_anchors.txt','w');
fid2=my_fopen(fichero_salida,'w');

fprintf(fid,'     <TerrainAnchors count="%d">\n',tamanyo);
fprintf(fid,'       <TerrainAnchor>\n         <Position x="%f" y="%f" z="%f" />\n       </TerrainAnchor>\n',data);
fprintf(fid2,'%d %f %f %f\n',datan);
fprintf(fid,'     </TerrainAnchors>\n');

my_fclose(fid);
my_fclose(fid2);


datan=[(1:tamanyo)' x z y];
m=size(datan);
datan=reshape(datan',1,m(1)*m(2),1);


%fid=my_fopen('prueba.geo','w')
%fprintf(fid,'       Point(%d) = {%f, %f, %f, 1};\n',datan);
%my_fclose(fid);

datax=x;
datay=y;
dataz=z;
save('salida\anchors_originales.mat','datax','datay','dataz');

message(22)




function [indices indicesfuera]=comprobar_rangos(rangox,rangoz,x,z)

dentrodelrango=(x>=min(rangox)).*(x<=max(rangox)).*(z>=min(rangoz)).*(z<=max(rangoz));
indices=find(dentrodelrango==1);
indicesfuera=find(dentrodelrango==0);
