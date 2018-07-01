function creax(x,y,z,u,v,tri,ficherosalida,textura)
  %creax(x',y',alturas',u,v,tri(ii,:)-1,'salida/inside.x','Placa3.dds');
  fid=fopen('../scripts/esqueleto_directx.x','r');
  contenido=char(fread(fid,inf,'char'))';
  fclose(fid);
  inicio0=contenido(1:240);%Comun a todos los objetos
  inicio=contenido(241:496);%findstr(contenido','Mesh {')
  % 171756;
  %      2051.904541;449.297119;-626.045227;,
  centro1='      MeshNormals { ';
  %        57252;
  %        -0.114429; 0.969981; 0.214577;,
  %        57252;
  %        3;0,0,0;,
  centro2='      MeshTextureCoords {';
  %        171756;
  %         0.000000; 1.000000;,
  centro3='      MeshMaterialList {';
  %        1;
  %        57252;
  %        0,
  %        0,
  final1=contenido(1379:1600);
  final2=contenido(1611:end-17);
  final3=contenido(end-16:end);%Final comun a todos los objetos
  %Cambiamos las normales de cara
  tri(:,[2 3]) = tri(:,[3 2]);

  fid=fopen(ficherosalida,'w');
  fprintf(fid,'%s',inicio0);
  offset=0;
  acabar=0;
  disponibles=ones(1,length(tri));
  renumerados=zeros(size(x));
  salto=50;
  while acabar==0
    coor_ini=offset;
    coor_fin=offset+salto;
    %Triangulos que usan algunas de esas coordenadas
    listatri=find(disponibles'.*sum((tri>=coor_ini).*(tri<=coor_fin),2));
    if length(listatri)>0
      disponibles(listatri)=0;
      listacoor=unique(tri(listatri,:));
      nuevanumeracion=0:length(listacoor)-1;%Nueva numeracion de esas coordenadas
      lostri=tri(listatri,:);
      renumerados(listacoor+1)=nuevanumeracion;
      lostri=renumerados(lostri+1);
      losx=x(listacoor+1);
      losy=y(listacoor+1);
      losz=z(listacoor+1);
      losu=u(listacoor+1);
      losv=v(listacoor+1);
      [nf,nc]=size(lostri);longlostri=nf*nc/3;      
      fprintf(fid,'%s\n      %d;\n',inicio,length(losx));
      cadena=sprintf('      %f; %f; %f;,\n',[losx' losz' -losy']');cadena(end-1)=';';
      fprintf(fid,'%s       %d;\n',cadena,longlostri);
      cadena=sprintf('       3;%d,%d,%d;,\n',lostri');cadena(end-1)=';';
      fprintf(fid,'%s%s\n      %d;\n',cadena,centro1,length(lostri));
      cadena=sprintf('      %f; %f; %f;,\n',[zeros(1,longlostri)' ones(1,longlostri)' zeros(1,longlostri)']');cadena(end-1)=';';
      fprintf(fid,'%s        %d;\n',cadena,longlostri);
      cadena=sprintf('      3;%d,%d,%d;,\n',[(0:longlostri-1)' (0:longlostri-1)' (0:longlostri-1)']');cadena(end-1)=';';
      fprintf(fid,'%s      }\n%s\n      %d;\n',cadena,centro2,length(losx));
      cadena=sprintf('        %f; %f;,\n',[losu' losv']');cadena(end-1)=';';
      fprintf(fid,'%s      }\n%s\n        1;\n        %d;\n',cadena,centro3,longlostri);
      for h=1:longlostri-1
          fprintf(fid,'       0,\n');      
      end
      fprintf(fid,'       0;;');   
      fprintf(fid,'%s%s%s',final1,textura,final2);
      offset=offset+salto;
    else
      acabar=1;
    end
  end
  fprintf(fid,'%s',final3);  
  fclose(fid);
end
