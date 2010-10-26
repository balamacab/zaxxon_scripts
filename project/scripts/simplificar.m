function simplificar()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

  id_conducible=111;
  id_noconducible=222;
  id_apoyo=333;
if nargin>1
    display('Los Identificadores de las superficies físicas CONDUCIBLE, NO CONDUCIBLE y DE APOYO, deben ser 111, 222 y 333 respectivamente')
    display('Uso: simplificar()');
    return;
end
if nargin==0
	usando_plywrite=0;
end

display('Leyendo datos entrada (nac.mat y salida\anchors_originales.mat)')

S=load('..\nac.mat');
nac=S.nac;

nodos=load('salida\anchors_originales.mat');
x=nodos.datax;
y=double(nodos.datay);
z=nodos.dataz;

display('Leyendo elements')
%[nada1 nada2 nada3 id_superficie nada5 nada6 n1 n2 n3]=textread('elements.txt','%d %d %d %d %d %d %d %d %d');
fid=fopen('elements.txt');
contents=fread(fid,inf);
fclose(fid);
cadena=char(contents)';
todo=sscanf(cadena,'%d',inf);
numtags=todo(3);
tam_registro=numtags+6;
id_superficie=todo(4:tam_registro:end);
n1=todo((numtags+4):tam_registro:end);
n2=todo((numtags+5):tam_registro:end);
n3=todo((numtags+6):tam_registro:end);
id_particular=todo(5:tam_registro:end);

Data_c.vertex.x = x;
Data_c.vertex.y = y;
Data_c.vertex.z = z;

Data_ci.vertex.x = x;
Data_ci.vertex.y = y;
Data_ci.vertex.z = z;

Data_nc.vertex.x = x;
Data_nc.vertex.y = y;
Data_nc.vertex.z = z;

Data_apoyo.vertex.x = x;
Data_apoyo.vertex.y = y;
Data_apoyo.vertex.z = z;


contador_nc=1;
contador_c=1;
contador_ci=1;
contador_apoyo=1;

display('Separando triángulos')

display('1 de 3')


seleccion=find((id_conducible==id_superficie).*((n1>nac) .* (n2>nac) .* (n3>nac)));
display(sprintf('%d triángulos conducibles',length(seleccion)));
if length(seleccion)>0
	if usando_plywrite==1
		cell_array=mat2cell([n1(seleccion)-1 n2(seleccion)-1 n3(seleccion)-1],ones(length(n1(seleccion)),1),[3]);
		Data_c.face.vertex_indices=cell_array;
	else
		Data_c.vertex_indices=[n1(seleccion)-1 n2(seleccion)-1 n3(seleccion)-1];
	end
end

display('2 de 3')

seleccion=find((id_conducible==id_superficie).*((n1<=nac) .+ (n2<=nac) .+ (n3<=nac)));
display(sprintf('%d triángulos intocables',length(seleccion)));
if length(seleccion)>0
    if usando_plywrite==1
		cell_array=mat2cell([n1(seleccion)-1 n2(seleccion)-1 n3(seleccion)-1],ones(length(n1(seleccion)),1),[3]);
		Data_ci.face.vertex_indices=cell_array;
	else
		Data_ci.vertex_indices=[n1(seleccion)-1 n2(seleccion)-1 n3(seleccion)-1];
	end
end

display('3 de 3')

seleccion=find(id_noconducible==id_superficie);
display(sprintf('%d triángulos NO conducibles',length(seleccion)));
id_particular=id_particular(seleccion);%Solo lo queremos para los no conducibles
if length(seleccion)>0
    if usando_plywrite==1
		cell_array=mat2cell([n1(seleccion)-1 n2(seleccion)-1 n3(seleccion)-1],ones(length(n1(seleccion)),1),[3]);
		Data_nc.face.vertex_indices=cell_array;
	else
		Data_nc.vertex_indices=[n1(seleccion)-1 n2(seleccion)-1 n3(seleccion)-1];
	end		
end




display('Escribiendo ficheros')

if usando_plywrite==1 
	plywrite(Data_ci,'salida\intocables.ply','ascii');
	display('Now you can open intocables.ply to remove unreferenced vertex')
	plywrite(Data_c,'salida\conducibles.ply','ascii');
	display('Now you can open conducibles.ply to remove unreferenced vertex')
	plywrite(Data_nc,'salida\noconducibles.ply','ascii');
	display('Now you can open noconducibles.ply to reduce poly count')
else
	my_plywrite(Data_ci,'salida\intocables.ply','ascii');
	display('Now you can open intocables.ply to remove unreferenced vertex')
	my_plywrite(Data_c,'salida\conducibles.ply','ascii');
	display('Now you can open conducibles.ply to remove unreferenced vertex')
	my_plywrite(Data_nc,'salida\noconducibles.ply','ascii');
	display('Now you can open noconducibles.ply to reduce poly count')
	
end

trocear_noconducibles(Data_nc,id_particular);

message(10);

function my_plywrite(Data,fichero)
cabecera='ply\r\nformat ascii 1.0\r\ncomment created by zaxxon\r\nelement vertex %d\r\nproperty float x\r\nproperty float y\r\nproperty float z\r\nelement face %d\r\nproperty list uchar %s vertex_indices\r\nend_header\r\n';
fid=fopen(fichero,'w');
vertices=Data.vertex.x;
tama=size(Data.vertex_indices);
fprintf(fid,cabecera,length(Data.vertex.x),tama(1)*tama(2)/3,'int');
fprintf(fid,'%.6f %.6f %.6f\r\n',[Data.vertex.x Data.vertex.y Data.vertex.z]');
fprintf(fid,'3 %d %d %d\r\n',Data.vertex_indices');
fclose(fid);
end


function trocear_noconducibles(Data_nc,id_particular)
system('mkdir salida\nc_splitted');
system('del /Q salida\nc_splitted\*.ply');
restan=id_particular;
Data_seleccionados=Data_nc;
do
	id_concreto=restan(1);
	indices=find(id_particular==id_concreto);
	Data_seleccionados.vertex_indices=Data_nc.vertex_indices(indices,:);
	my_plywrite(Data_seleccionados,sprintf('salida\\nc_splitted\\sup%d.ply',id_concreto));
	restan=restan(find(restan~=id_concreto));
until length(restan)==0


end
