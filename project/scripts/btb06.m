function btb06(ancho_track,force_new_anchors,panel_length)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

if nargin<1
  display('Usage: btb06(track_width)');
  display('(track_width will be used by mallado_regular for creating the mesh)')
  return;
end
if nargin==1
	force_new_anchors=0;
	panel_length=5;
end
if nargin==2
	panel_length=5;
end

ancho_track=ancho_track/2;

leer_nodos('nodes.xml','nodos.mat');
%Con el comando anterior regeneramos la carretera. Para evitar problemas de compatibilidad, solo regeneramos anchors
%si a) no existen o b) existen y se solicita que se regeneren poniendo force_new_anchors a 1
if (exist('porcentajes.mat')==2) & (force_new_anchors==0)
	display('Anchors exist for this track and they have not been changed to avoid problems with existing .geo files')
	display('If you are sure you want to replace them set to 1 the second input parameter (i.e btb06(4,1))')
	message(3);
	return;
end


S=load('nodos.mat');
numnodos=length(S.tree);

%figure
%hold on
total_anchors=0;
contador=1;
for h=1:numnodos-1
	Punto0=[S.tree(h).Position.x S.tree(h).Position.y S.tree(h).Position.z];
        Punto3=[S.tree(h+1).Position.x S.tree(h+1).Position.y S.tree(h+1).Position.z];
        AngleXZ0=S.tree(h).ControlPoints.AngleXZ;
        AngleXZ3=S.tree(h+1).ControlPoints.AngleXZ;
        AngleY0=S.tree(h).ControlPoints.AngleY;
        AngleY3=S.tree(h+1).ControlPoints.AngleY;
        Distancia0=S.tree(h).ControlPoints.ExitDistance;
        Distancia3=S.tree(h+1).ControlPoints.EntryDistance;
    if mod(h,1000)==0
         display(sprintf('%d %d',h,total_anchors));
    end
    distancia=0;
    for t=0:0.5:1
        
        salida=interpola_spline(Punto0,Distancia0,[AngleXZ0 AngleY0],Punto3,Distancia3,[AngleXZ3 AngleY3],t);
        %plot(salida(1),salida(2),'+');
        if t>0
            distancia=distancia+sqrt(sum((salida-salida_anterior).^2));
        end
        salida_anterior=salida;
    end
    
    segmentos=round(distancia/panel_length);
    if segmentos==0
        segmentos=1;
    end
    total_anchors=total_anchors+2*(segmentos);

    divisiones=linspace(0,1,segmentos+1);

    for t=divisiones
        [salida angulop]=interpola_spline(Punto0,Distancia0,[AngleXZ0 AngleY0],Punto3,Distancia3,[AngleXZ3 AngleY3],t);
		if (h==1) || (t>0)
			porcentajes(contador,:)=[h t];
			anchors_dcha(contador,:)=[salida(1)+ancho_track*cos(angulop) salida(2) salida(3)+ancho_track*sin(angulop)];
			anchors_izda(contador,:)=[salida(1)-ancho_track*cos(angulop) salida(2) salida(3)-ancho_track*sin(angulop)];
			%plot([anchors_izda(contador,1) anchors_dcha(contador,1)],[anchors_izda(contador,3) anchors_dcha(contador,3)],'g');
			anguloxzp(contador)=angulop;
			contador=contador+1;
		end	 
    end
end    

save 'anguloxzp.mat' anguloxzp

%figure
%hold on
%plot(anchors_izda(:,1),anchors_izda(:,3),'o');
%plot(anchors_dcha(:,1),anchors_dcha(:,3),'or');

total_anchors=total_anchors+2;
display(sprintf('%d %d',h,total_anchors));

for h=1:length(porcentajes) %Los que están a distancia "1" de un nodo los reconvierto en distancia "0" a partir del siguiente
  if porcentajes(h,2)==1
    porcentajes(h,1)=porcentajes(h,1)+1;
    porcentajes(h,2)=0;
  end
end
%No es seguro, pero total_anchors debe ser 2 *length(porcentajes), pues los porcentajes son los mismos a ambos lados de la carretera

%%%%%%%%%Grabar ficheros de texto

fid=my_fopen('porcentajes.xml','w')
fprintf(fid,'      <Anchors count="%d">\r\n',2*length(porcentajes));
for h=1:length(porcentajes)
	fprintf(fid,'        <Anchor>\r\n          <TrackId>0</TrackId>\r\n          <StartNode>%d</StartNode>\r\n          <StartPercentage>%f</StartPercentage>\r\n        </Anchor>\r\n',porcentajes(h,1)-1,porcentajes(h,2));
end
for h=1:length(porcentajes)
	fprintf(fid,'        <Anchor>\r\n          <TrackId>0</TrackId>\r\n          <StartNode>%d</StartNode>\r\n          <StartPercentage>%f</StartPercentage>\r\n        </Anchor>\r\n',porcentajes(h,1)-1,porcentajes(h,2));
end
fprintf(fid,'      </Anchors>\r\n');
my_fclose(fid);

fid=my_fopen('anchors_s1.xml','w')
fprintf(fid,'    <TerrainAnchors count="%d">\r\n',2*length(anchors_izda));
for h=1:length(anchors_izda)
	fprintf(fid,'      <TerrainAnchor>\r\n        <Position x="%f" y="%f" z="%f" />\r\n      </TerrainAnchor>\r\n',anchors_izda(h,1),anchors_izda(h,2),anchors_izda(h,3));
end
for h=1:length(anchors_dcha)
	fprintf(fid,'      <TerrainAnchor>\r\n        <Position x="%f" y="%f" z="%f" />\r\n      </TerrainAnchor>\r\n',anchors_dcha(h,1),anchors_dcha(h,2),anchors_dcha(h,3));
end
fprintf(fid,'      </TerrainAnchors>\r\n');
my_fclose(fid);


%%%%%%%%%%%%Grabar los .mat
%nodos.mat ya se ha generado

%-----------porcentajes.mat

%Para evitar problemas de compatibilidad lo genero a partir del .xml
leer_porcentajes('porcentajes.xml','porcentajes.mat');

%------------anchors.mat
display('Grabando ..\anchors.mat')
tree=[];
offset=length(anchors_izda);
for h=1:length(anchors_izda)
    if mod(h,1000)==0
         display(sprintf('%d',h));
    end
        tree.TerrainAnchor(h).Position.ATTRIBUTE.x=anchors_izda(h,1);
        tree.TerrainAnchor(h).Position.ATTRIBUTE.y=anchors_izda(h,2);
        tree.TerrainAnchor(h).Position.ATTRIBUTE.z=anchors_izda(h,3);
        tree.TerrainAnchor(h+offset).Position.ATTRIBUTE.x=anchors_dcha(h,1);
        tree.TerrainAnchor(h+offset).Position.ATTRIBUTE.y=anchors_dcha(h,2);
        tree.TerrainAnchor(h+offset).Position.ATTRIBUTE.z=anchors_dcha(h,3);
end

x=[anchors_izda(:,1);anchors_dcha(:,1)];
y=[anchors_izda(:,2);anchors_dcha(:,2)];
z=[anchors_izda(:,3);anchors_dcha(:,3)];
x=x';
y=y';
z=z';
save '..\anchors.mat' x y z tree;

%------------nac.mat
longitud=length(x);
nac=longitud
save '..\nac.mat' nac

message(3);
