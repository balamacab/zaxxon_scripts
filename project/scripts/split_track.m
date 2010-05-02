function split_track(trozos)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.


fichero_nodos='nodos.mat';
fichero_anchors='porcentajes.mat';
fichero_pos_anchors='..\anchors.mat';

if (nargin==0)||(trozos=='h') 
    display('Ejemplo: partir_track(8)');
    return;
end

nodos=load(fichero_nodos);     %posición absoluta de los nodos que definen el spline
anchors_porcentaje=load(fichero_anchors); %nac anchors como distancia entre nodos

figure
hold on

for h=1:length(nodos.tree)
	plot(nodos.tree(h).Position.x,nodos.tree(h).Position.z,'g*');
        if mod(h,10)==0
        	text(nodos.tree(h).Position.x,nodos.tree(h).Position.z,sprintf('%d',h));
	end
end


%
tree.Anchor=anchors_porcentaje.tree;
for h=1:length(tree.Anchor)/2
        elnodo(h)=tree.Anchor(h).StartNode;
end
pos_anchors=load(fichero_pos_anchors);
x=pos_anchors.x;
z=pos_anchors.z;

nac=length(x);
x=0.5*(x(1:nac/2)+x(nac/2+1:end));
z=0.5*(z(1:nac/2)+z(nac/2+1:end));
xz = [x;z]; 
df = diff(xz,1,2); 
distancia = cumsum([0, sqrt([1 1]*(df.*df))]);


%Calculamos el número de nodos que vamos a poner en cada uno de los nuevos tracks
tree.node=nodos.tree;

longitud_media=distancia(end)/trozos;
distancia_recorrida=0;
pos_anterior=0;
for h=1:trozos
	distancia_recorrida+=longitud_media; %El siguiente punto de separación esta longitud_media más allá
	[minimo pos]=min(abs(distancia_recorrida-distancia));
	longitud_tramo(h)=elnodo(pos)-pos_anterior;
    pos_anterior=elnodo(pos);	
end
longitud_tramo(trozos)=2*longitud_tramo(trozos); %Nos aseguramos de que cubre todo el tramo final
longitud_tramo(trozos+1)=longitud_tramo(trozos);%No se usa pero hace falta para un lazo



contador=1;
inicio=1;
final=min([longitud_tramo(contador)+1 length(tree.node)]);
plot(tree.node(inicio).Position.x,tree.node(inicio).Position.z,'ro');

while inicio<final,
	pos_nodes(contador)=inicio;
	pos_nodes(contador+1)=final;
	plot(tree.node(final).Position.x,tree.node(final).Position.z,'ro');	
	contador=contador+1;
	inicio=final;
	final=min([final+longitud_tramo(contador) length(tree.node)]);
end
dibuja_padre_o_hijos;

fid=my_fopen('pos_nodes.txt','w')
for h=1:length(pos_nodes)
	fprintf(fid,'%d \r\n',pos_nodes(h));
end
my_fclose(fid);

message(17);

function dibuja_padre_o_hijos
[numero_padres caminos]=look_for_father_or_sons('..\father.txt');

for h=1:numero_padres
	anchors=load(strcat(char(caminos(h)),'\anchors.mat'));
	nac=length(anchors.x);
	plot(anchors.x(1:nac/2),anchors.z(1:nac/2));
	plot(anchors.x(nac/2+1:nac),anchors.z(nac/2+1:nac));
end  

[numero_hijos caminos]=look_for_father_or_sons('..\sons.txt');

for h=1:numero_hijos
	anchors=load(strcat(char(caminos(h)),'\anchors.mat'));
	nac=length(anchors.x);
	plot(anchors.x(1:nac/2),anchors.z(1:nac/2));
	plot(anchors.x(nac/2+1:nac),anchors.z(nac/2+1:nac));
end

end
