function poncarretera(escalado)
if nargin==0
    escalado=1;
end
fid=fopen('salida/nodos_conaltura.txt','r');
tot=fscanf(fid,'%d %f %f %f\n',inf);
x=tot(2:4:end);
y=tot(3:4:end);
z=tot(4:4:end);%Esta es la altura
fclose(fid);

curvaturas=[];
if exist('../s11_m3d/curvaturas.mat','file')==2
    S=load('../s11_m3d/curvaturas.mat');
    offset=S.offset;
end

fid=fopen('../s11_m3d/carretera.txt');
tot=fscanf(fid,'%f %d %d %d %d %d ');
m=length(tot);
tot=reshape(tot,6,m/6);
[k p]=size(tot);

for g=1:p %Direccion de avance en la carretera
    alturacomun=tot(1,g);
    if isempty(offset)==0
        alturacomun=alturacomun+escalado*offset(g,:);
    end
    y(tot(2:6,g))=alturacomun;
end
fclose(fid);
createtrk([x(4,1:3:end) z(4,1:3:end) y(4,1:3:end)]);

fid=fopen('salida/nodosconcarretera.txt','w');
fprintf(fid,'%d %f %f %f\n',[(1:length(x))' x z y]');%En los nodos elevados, la altura es la columna intermedia
fclose(fid);

msh_to_obj('salida/nodos_conaltura.txt','elements.txt','test.mtl');
system('copy salida\test.obj+..\s11_m3d\salida\texturas0.txt salida\test_sincarretera.obj');
msh_to_obj('salida/nodosconcarretera.txt','elements.txt','test.mtl');
system('copy salida\test.obj+..\s11_m3d\salida\texturas0.txt salida\test_concarretera.obj');


end