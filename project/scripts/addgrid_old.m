function addgrid(numx,numz)

salvaguarda=1;

S=load('..\s2_elevation_b\salida\lamalla.mat');
minx=S.rangox(1);
maxx=S.rangox(end);
pasox=(maxx-minx-salvaguarda)/(numx);

minz=S.rangoz(1);
maxz=S.rangoz(end);
pasoz=(maxz-minz-salvaguarda)/(numz);


fid=fopen('salida\anchors_carretera.geo','a');
fprintf(fid,'clg=150;\r\n');

fprintf(fid,'\r\n');
fprintf(fid,'numx=%d;\r\n',numx+1);
fprintf(fid,'numy=%d;\r\n',numz+1);
fprintf(fid,'xmin=%f;\r\n',minx+salvaguarda/2);
fprintf(fid,'pasox=%f;\r\n',pasox);
fprintf(fid,'ymin=%f;\r\n',minz+salvaguarda/2);
fprintf(fid,'pasoy=%f;\r\n',pasoz);
fprintf(fid,'For indx In {1:numx}\r\n');
fprintf(fid,'  x=xmin+(indx-1)*pasox;\r\n');
fprintf(fid,'  For indy In {1:numy}\r\n');
fprintf(fid,'    y=ymin+(indy-1)*pasoy;\r\n');
fprintf(fid,'\r\n');    
fprintf(fid,'    puntos[indx*numy+indy] = newp; Point(puntos[indx*numy+indy])={x,y,0,clg};\r\n');
fprintf(fid,'\r\n');
fprintf(fid,'    If (indx>1)\r\n');
fprintf(fid,'        ll=newl; Line(ll)={puntos[indx*numy+indy] , puntos[(indx-1)*numy+indy]};\r\n');
fprintf(fid,'    EndIf\r\n');
fprintf(fid,'    If (indy>1)\r\n');
fprintf(fid,'        ll=newl; Line(ll)={puntos[indx*numy+indy] , puntos[indx*numy+(indy-1)]};\r\n');
fprintf(fid,'    EndIf\r\n');
fprintf(fid,'  EndFor\r\n');
fprintf(fid,'EndFor\r\n');

fclose(fid)