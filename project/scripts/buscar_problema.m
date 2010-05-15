%function  buscar_problema()

fid=fopen('joined.geo','r');
contenido=fread(fid,inf);
fclose(fid)
cadena=char(contenido)';

[s, e, te, m, t, nm]=regexp(cadena,'Point\(offsetp\+([0-9]+)\) = \{([-0-9]+\.([0-9]+)?|\.[0-9]+),\s([-0-9]+\.([0-9]+)?|\.[0-9]+),\s([-0-9]+\.([0-9]+)?|\.[0-9]+),\scl1\};');

anterior=0;
contador=1;
for h=1:length(t(:))
	numero=str2num(char(t{h}{1,1}));
	if numero<anterior
		maximos(contador)=anterior;
		contador=contador+1;
	end
	anterior=numero;
end

maximos(contador)=numero;

maximos

[numero_sons caminos]=look_for_father_or_sons('..\..\sons.txt');

for h=1:numero_sons
	nodos=load(strcat(char(caminos(h)),'\anchors.mat'));
	porcentajes=load(strcat(char(caminos(h)),'\venue\porcentajes.mat'));
	fprintf(1,'%d %d %d %s\n',maximos(h+1),length(nodos.x),length(porcentajes.tree),char(caminos(h)));
end