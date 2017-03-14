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
tot=fscanf(fid,'%f %d %d %d %d %d %d %d %d %d');
m=length(tot);
tot=reshape(tot,10,m/10);
[k p]=size(tot);

for g=1:p %Direccion de avance en la carretera
    alturacomun=tot(1,g);
    if isempty(offset)==0
        alturacomun=alturacomun+escalado*offset(g,:);
    end
    y(tot(2:10,g))=alturacomun;
end
fclose(fid)

fid=fopen('salida/nodosconcarretera.txt','w');
fprintf(fid,'%d %f %f %f\n',[(1:length(x))' x z y]');%En los nodos elevados, la altura es la columna intermedia
fclose(fid);

msh_to_obj('salida/nodos_conaltura.txt','elements.txt');
system('copy salida\test.obj+..\s11_m3d\salida\texturas.txt salida\test_sincarretera.obj');
msh_to_obj('salida/nodosconcarretera.txt','elements.txt');
system('copy salida\test.obj+..\s11_m3d\salida\texturas.txt salida\test_concarretera.obj');


end