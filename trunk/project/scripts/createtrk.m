function createtrak(trazado)
%fuente='invertido.trk';
if exist('fuente','var')==0
	fuente='track-71_M.trk';
end


%%%%%%%%%%%%%%%%%%%LEER UN TRK%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fid = fopen(fuente,'r');

inicio=fread(fid,5,'integer*4');

%inicio(5) es el numero de puntos en el driveline
coordenadas=zeros(inicio(5),3);
vector=zeros(inicio(5),3);
nose=zeros(inicio(5),4);
dist=zeros(inicio(5),1);
for t=1:inicio(5)
    coordenadas(t,:)=fread(fid,3,'single');
    vector(t,:)=fread(fid,3,'single');
    dist(t,:)=fread(fid,1,'single');
    nose(t,:)=fread(fid,4);
    fprintf(2,'%d %f %f %f\n',t,coordenadas(t,:));
end
siguiente=fread(fid,6,'integer*4');
if (feof(fid))
    fprintf(2,'Final de fichero\n');
end
%siguiente=fread(fid,5,'integer*4')

fclose(fid);

vector=diff(trazado);
vector(end+1,:)=vector(end,:);

dist=cumsum([0 sqrt(sum(vector.^2,2))']);

[m,n]=size(trazado);
coordenadas=trazado;
nose=zeros(m,4);
inicio(5)=m*n/3;
%%%%%%%%%%%%%%%%%%%%GRABAR TRK%%%%%%%%%%%%%%%%%%%%%%

 fidw = fopen('creado.trk','w');
 fwrite(fidw,inicio,'uint32');
 for t=1:m*n/3
     fwrite(fidw,coordenadas(t,:),'single');
     fwrite(fidw,vector(t,:),'single');
     
     fwrite(fidw,dist(t),'single');
     fwrite(fidw,nose(t,:));    
 end
 fwrite(fidw,siguiente,'uint32');
 fclose(fidw);
 %figure,plot(coordenadas(:,1),coordenadas(:,2))
 %axis('equal');
