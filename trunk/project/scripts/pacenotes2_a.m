function pacenotes2_a(sensibilidad,adelanto)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código No es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

if nargin<2
  display('pacenotes2(sensibility,distance before middle point of curves)')
  return;
end


S=load('driveline.mat');
angulos=-S.angulos;
x=S.x;
z=S.z;
distancias=S.equidistantes;
pendientes=S.pendiente;

[lista_pacenotes]=calcular_pacenotes(x,z,pendientes,angulos,distancias,sensibilidad,adelanto);


%------------------------------------------------------------------------------------------
%         Leer la posición de los anchors como porcentaje de distancia entre nodos

anchors_porcentaje=load('porcentajes.mat'); %nac anchors como distancia entre nodos

tree.Anchor=anchors_porcentaje.tree;

for h=1:length(tree.Anchor)/2
        elnodo(h)=tree.Anchor(h).StartNode  ;
        elporcentaje(h)=tree.Anchor(h).StartPercentage ;
end

%--------------------------------------------------------------------------------------- 
%       Leemos las pacenotes (inicio, final y checkpoints) que hay en pacenotes.ini y las añadimos a las que hemos generado

display('Leemos tramos_nodos.mat');
tramos=load('tramos_nodos.mat');
tramos=tramos.tramos;


display('Leemos ..\anchors.mat');
anchors=load('..\anchors.mat');
nac=length(anchors.x);
anchors.x=0.5*(anchors.x(1:nac/2)+anchors.x(nac/2+1:end));
anchors.z=0.5*(anchors.z(1:nac/2)+anchors.z(nac/2+1:end));
anchors.y=0.5*(anchors.y(1:nac/2)+anchors.y(nac/2+1:end));

%Cut 64
%Don't cut 32
%Long 1024
%Wideout 2
%Narrows 1
%Tightens 4
%Tightens bad 128
%Maybe 8192

contador=0;
for h=1:length(lista_pacenotes)
  if strcmp(lista_pacenotes(h),'-')==0
    contador=contador+1;
    switch lista_pacenotes(h).flag
      case {64}, lista_pacenotes(h).Variation='Cut';
      case {32}, lista_pacenotes(h).Variation='DontCut';
      case {1024}, lista_pacenotes(h).Variation='Long';
      case {2}, lista_pacenotes(h).Variation='WideOut';
      case {1}, lista_pacenotes(h).Variation='Narrows';
      case {4}, lista_pacenotes(h).Variation='Tightens';
      case {128}, lista_pacenotes(h).Variation='TightensBad';
      case {8192}, lista_pacenotes(h).Variation='Maybe';
      case {0}, lista_pacenotes(h).Variation='None';
    endswitch
  end
end

fid=fopen('salida\pacenotes.txt','w');
fprintf(fid,'<Pacenotes count=\"%d\">\r\n',contador);

for h=1:length(lista_pacenotes)
    if strcmp(lista_pacenotes(h),'-')==0
      nodo=buscar_anchor_cercano(x(lista_pacenotes(h).nodo),z(lista_pacenotes(h).nodo),anchors);
      [track nodo_inicial frontera]=dame_nodo_inicial(elnodo(nodo),tramos);
      fprintf(fid,'<Pacenote Name=\"%s\" DrivelineSegmentId=\"%d\" KnotOrNodeId=\"%d\" Percentage=\"%.2f\" Variation=\"%s\" />\r\n',lista_pacenotes(h).Nombre,track,elnodo(nodo)-nodo_inicial,elporcentaje(nodo),lista_pacenotes(h).Variation);
      fprintf(1,'%s %f %f %d %d\r\n',lista_pacenotes(h).Nombre,x(lista_pacenotes(h).nodo),z(lista_pacenotes(h).nodo),track,elnodo(nodo)-nodo_inicial);
    end
end
  fprintf(fid,'</Pacenotes>\r\n');
 
  mensaje=sprintf('Hay %d pacenotes',contador);
  display(mensaje);
fclose(fid)

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function indice=buscar_anchor_cercano(x,z,anchors)
distancias=(x-anchors.x).^2+(z-anchors.z).^2;
[Value indice]=min(distancias);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------------------------------------------------------------------------------



