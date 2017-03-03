fid=fopen('salida/nodos_conaltura.txt','r');
tot=fscanf(fid,'%d %f %f %f\n',inf);
x=tot(2:4:end);
y=tot(3:4:end);
z=tot(4:4:end);%Esta es la altura
fclose(fid);

fid=fopen('../s11_m3d/carretera.txt');
tot=fscanf(fid,'%f %d %d %d %d %d %d %d %d %d');
m=length(tot);
tot=reshape(tot,10,m/10);
[k p]=size(tot);
for g=1:p
    y(tot(2:10,g))=tot(1,g);
end
fclose(fid)

fid=fopen('salida/nodosconcarretera.txt','w');
fprintf(fid,'%d %f %f %f\n',[(1:length(x))' x y z]');
fclose(fid);

msh_to_obj('salida/nodos_conaltura.txt','elements.txt');
system('copy salida\test.obj+..\s11_m3d\salida\texturas.txt salida\test_sincarretera.obj');
msh_to_obj('salida/nodosconcarretera.txt','elements.txt');
system('copy salida\test.obj+..\s11_m3d\salida\texturas.txt salida\test_concarretera.obj');