function [vector coordenadas dist]=leetrk(fuente)
%fuente='invertido.trk';
verdatos=0;
if exist('fuente','var')==0
	fuente='track-71_M.trk';
end
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
    if (verdatos)
      fprintf(2,'%d %f %f %f\n',t,coordenadas(t,:));
    end
end
siguiente=fread(fid,6,'integer*4');
if (feof(fid))
    fprintf(2,'Final de fichero\n');
end
%siguiente=fread(fid,5,'integer*4')

fclose(fid)

%%%%%%%%%%%%%%%%%%%%invertir trk%%%%%%%%%%%%%%%%%%%%%%

% fidw = fopen('invertido.trk','w');
% fwrite(fidw,inicio,'uint32');
% for t=inicio(5):-1:1
%     fwrite(fidw,coordenadas(t,:),'single');
%     if t>1
%         fwrite(fidw,-vector(t-1,:),'single');
%     else
%         fwrite(fidw,-vector(1,:),'single');
%     end
%     fwrite(fidw,dist(end)-dist(t,:),'single');
%     fwrite(fidw,nose(t,:));    
% end
% fwrite(fidw,siguiente,'uint32');
% fclose(fidw);
figure,plot(coordenadas(:,1),coordenadas(:,2))
axis('equal')
end