function procesar_nodostxt(amp_ruido)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.


fichero_entrada='nodos.txt';

if nargin>1
    display('Puede tener como parámetro de entrada la amplitud máxima de ruido deseada en las alturas generadas')
    display('Lee nodos.txt y le da altura según lamalla.mat y lamalla2.mat');
    display(' ');
    display('Ejemplo: procesar_nodostxt([0 0.5])');    
    display(' ');
    display('Salida:');
    display('-> listado_anchors.txt (es el listado de anchors que se incorporará tal cual al Venue.xml)');
    display('-> nodos_conaltura.txt (es un listado de nodos y alturas útil para procesar_elementstxt.m)');
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

%Los nodos no tienen altura, así que hay que cargar los datos de los xml
%para interpolar la altura en ese punto de la malla

S=load('..\nac.mat');
nac=S.nac;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[datax datay dataz]=leerloskml();
malla=load('lamalla.mat');

try
    mallaB=load('lamalla2.mat');
catch
    display('No se ha encontrado una segunda malla');
end


display('Recalculando altura de anchors próximos a carretera...');
x_deseados=x;
z_deseados=z;
[indices indicesfuera]=comprobar_rangos(malla.rangox,malla.rangoz,x_deseados,z_deseados);
y(indices)=z_interp2(malla.rangox,malla.rangoz,malla.malla_regular,x_deseados(indices),z_deseados(indices));
if length(indices)<length(x_deseados) %Si algún dato no ha sido obtenido de la malla principal, tratamos de sacarlo de la secundaria
	display('Buscando alturas para datos que caen fuera del mallado rectangular principal. Se usará ''lamalla2.mat''');
	indices=indicesfuera;
	y(indices)=z_interp2(mallaB.rangox,mallaB.rangoz,mallaB.malla_regular,x_deseados(indices),z_deseados(indices));
end

y=double(y);

if find(isnan(y)==1)
    display('ALGUNOS DATOS DE ALTURA SON ERRÓNEOS. COMPRUEBE QUE EL MALLADO NO EXCEDE LOS LÍMITES DE LA FUENTE DE DATOS');
end

try
	if sum(datay==NaN)>1
		display('Valores erróneos');
		return;
	end
catch
	display('...')
end

tamanyo=length(numero);

fid=my_fopen('salida\listado_anchors.txt','w');
fid2=my_fopen('salida\nodos_conaltura.txt','w');

fprintf(fid,'     <TerrainAnchors count="%d">\n',tamanyo);
for h=1:tamanyo
    fprintf(fid,'       <TerrainAnchor>\n         <Position x="%f" y="%f" z="%f" />\n       </TerrainAnchor>\n',x(h),y(h),z(h));
    fprintf(fid2,'%d %f %f %f\n',h,x(h),z(h),y(h));
end
fprintf(fid,'     </TerrainAnchors>\n');

my_fclose(fid);
my_fclose(fid2);

fid=my_fopen('prueba.geo','w')

for h=1:tamanyo
    fprintf(fid,'       Point(%d) = {%f, %f, %f, 1};\n',h,x(h),z(h),y(h));
end

datax=x;
datay=y;
dataz=z;
save('salida\anchors_originales.mat','datax','datay','dataz');

my_fclose(fid);


function alturas=dar_altura_nac(cx,cy,cz,nac,distancia)
%La posición real de los anchors de carretera está moviéndose 10cm
%(distancia) hacia el anchor opuesto

for h=1:nac/2
    vector_entrante=[cx(h+nac/2)-cx(h) cz(h+nac/2)-cz(h)];
    unitario_entrante=vector_entrante/norm(vector_entrante);
    x_real(h)=cx(h)+distancia*unitario_entrante(1);
    z_real(h)=cz(h)+distancia*unitario_entrante(2);
end

for h=nac/2+1:nac
    vector_entrante=[cx(h-nac/2)-cx(h) cz(h-nac/2)-cz(h)];
    unitario_entrante=vector_entrante/norm(vector_entrante);
    x_real(h)=cx(h)+distancia*unitario_entrante(1);
    z_real(h)=cz(h)+distancia*unitario_entrante(2);
end

for h=1:nac/2
    vector_saliente=[x_real(h+nac/2)-x_real(h) cy(h+nac/2)-cy(h) z_real(h+nac/2)-z_real(h)];
    unitario_saliente=vector_saliente/norm(vector_saliente);
    %tangente=alturaY/distanciaXZ;
    tangente=unitario_saliente(2)/sqrt(unitario_saliente(1)^2+unitario_saliente(3)^2);
    if tangente~=0
        mensaje=sprintf('El anchor se sube %.3fm',distancia*tangente);
        display(mensaje);
    end
    %altura=distancia*tangente;
    alturas(h)=cy(h)+distancia*tangente;
end

for h=nac/2+1:nac
    vector_saliente=[x_real(h-nac/2)-x_real(h) cy(h-nac/2)-cy(h) z_real(h-nac/2)-z_real(h)];
    unitario_saliente=vector_saliente/norm(vector_saliente);
    %tangente=alturaY/distanciaXZ;
    tangente=unitario_saliente(2)/sqrt(unitario_saliente(1)^2+unitario_saliente(3)^2);
    if tangente~=0
        mensaje=sprintf('El anchor se sube %.3fm',distancia*tangente);
        display(mensaje);
    end
    %altura=distancia*tangente;
    alturas(h)=cy(h)+distancia*tangente;
end

alturas=alturas';



function [indices indicesfuera]=comprobar_rangos(rangox,rangoz,x,z)

dentrodelrango=(x>=min(rangox)).*(x<=max(rangox)).*(z>=min(rangoz)).*(z<=max(rangoz));
indices=find(dentrodelrango==1);
indicesfuera=find(dentrodelrango==0);
