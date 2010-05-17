function  fix_project()

fid=fopen('joined.geo','r');
contenido=fread(fid,inf);
fclose(fid)
cadena=char(contenido)';

[s, e, te, m, t, nm]=regexp(cadena,'Point\(offsetp\+([0-9]+)\) = \{([-0-9]+\.([0-9]+)?|\.[0-9]+),\s([-0-9]+\.([0-9]+)?|\.[0-9]+),\s([-0-9]+\.([0-9]+)?|\.[0-9]+),\scl1\};');

anterior=0;
contador=1;
for h=1:length(t(:))
	numero=str2num(char(t{h}{1,1}));
    x(h)=str2num(char(t{h}{1,2}));
    z(h)=str2num(char(t{h}{1,4}));
	y(h)=str2num(char(t{h}{1,6}));
	if numero<anterior
		maximos(contador)=anterior;
		contador=contador+1;
	end
	anterior=numero;
end

maximos(contador)=numero;

maximos


nodos_father=load('..\..\venue\nodos.mat');
porcentajes=crear_porcentajes(nodos_father,x(1:maximos(1)),y(1:maximos(1)),z(1:maximos(1)));
grabar('..\..\',x(1:maximos(1)),y(1:maximos(1)),z(1:maximos(1)),porcentajes);
    
[numero_sons caminos]=look_for_father_or_sons('..\..\sons.txt');

for h=1:numero_sons
	nodos=load(strcat(char(caminos(h)),'\venue\nodos.mat'));
	rango=sum(maximos(1:h))+(1:maximos(h+1));
	porcentajes=crear_porcentajes(nodos,x(rango),y(rango),z(rango));
    grabar(char(caminos(h)),x(rango),y(rango),z(rango),porcentajes);
end


function grabar(camino,x,y,z,porcentajes);
save(strcat(camino,'\anchors.mat'),'x','y','z');
tree=porcentajes.tree;
save(strcat(camino,'\venue\porcentajes.mat'),'tree');
save(strcat(camino,'\s10_split\porcentajes.mat'),'tree');
cur_dir=pwd;
cd(strcat(camino,'\s10_split'));
partir_track;
cd(cur_dir);


function salida=crear_porcentajes(nodos,x,y,z)

nac=length(x);
centrox=0.5*(x(1:nac/2)+x(nac/2+1:end));
centroz=0.5*(z(1:nac/2)+z(nac/2+1:end));

porcentajes=ones(nac/2,1);

for h=1:length(nodos.tree)
    distancias=(nodos.tree(h).Position.x-centrox).^2+(nodos.tree(h).Position.z-centroz).^2;
    [valor pos]=min(distancias);
    porcentajes(pos)=0;
end

pos_nodes=find(porcentajes==0);

segmentos=diff(pos_nodes);

for h=1:length(pos_nodes)-1
    porcentajes_segmento=linspace(0,1,segmentos(h)+1);
    porcentajes_segmento=porcentajes_segmento(1:end-1);
    porcentajes(pos_nodes(h):pos_nodes(h)+segmentos(h)-1)=porcentajes_segmento;
end

contador=-1;

for h=1:length(porcentajes)
    salida.tree(h).TrackId=0;
    if porcentajes(h)==0
        contador=contador+1;
    end
    salida.tree(h).StartNode=contador;    
    salida.tree(h).StartPercentage=porcentajes(h);
end

contador=-1;
for h=length(porcentajes)+1:2*length(porcentajes)
    salida.tree(h).TrackId=0;
    if porcentajes(h-length(porcentajes))==0
        contador=contador+1;
    end
    salida.tree(h).StartNode=contador;    
    salida.tree(h).StartPercentage=porcentajes(h-length(porcentajes));
end