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

distribucion=get_option('LINEAR','%d');
default_panel_length=get_option('PANEL_LENGTH','%f');

if nargin<=1
	force_new_anchors=0;
	panel_length=default_panel_length;
end
if nargin==2
	panel_length=default_panel_length;
end

leer_nodos('nodes.xml','nodos.mat');
%Con el comando anterior regeneramos la carretera. Para evitar problemas de compatibilidad, solo regeneramos anchors
%si a) no existen o b) existen y se solicita que se regeneren poniendo force_new_anchors a 1
if (exist('porcentajes.mat')==2) & (force_new_anchors==0)
	midisplay('Anchors exist for this track and they have not been changed to avoid problems with existing .geo files')
	midisplay('If you are sure you want to replace them set to 1 the second input parameter (i.e btb06(4,1))')
	message(3);
	return;
end

%Si se nos da como ancho 0, tratamos de usar el ancho usado anteriormente
if ancho_track==0
  try 
	  S=load('..\anchors.mat');
	  nac=length(S.x);
	  ancho_track=sqrt((S.x(1)-S.x(nac/2+1))^2+(S.z(1)-S.z(nac/2+1))^2);
	  ancho_track=ancho_track*10;
	  ancho_track=round(ancho_track);
	  ancho_track=ancho_track/10;
  catch
	  midisplay('Previous width could not be read')
	  return
  end
end

ancho_track=ancho_track/2;

S=load('nodos.mat');
numnodos=length(S.tree);

%figure
%hold on
total_anchors=0;
contador=1;

if distribucion==1
	midisplay('Using LINEAR (non uniform) spacing');
else
	midisplay('Using NONLINEAR (uniform) spacing');
end
%hold on
%figure
%hold on
global progress_bar;
for h=1:numnodos-1
	Punto0=[S.tree(h).Position.x S.tree(h).Position.y S.tree(h).Position.z];
	%plot(S.tree(h).Position.x,S.tree(h).Position.z,'*');
	Punto3=[S.tree(h+1).Position.x S.tree(h+1).Position.y S.tree(h+1).Position.z];
	AngleXZ0=S.tree(h).ControlPoints.AngleXZ;
	AngleXZ3=S.tree(h+1).ControlPoints.AngleXZ;
	AngleY0=S.tree(h).ControlPoints.AngleY;
	AngleY3=S.tree(h+1).ControlPoints.AngleY;
	Distancia0=S.tree(h).ControlPoints.ExitDistance;
	Distancia3=S.tree(h+1).ControlPoints.EntryDistance;
    
	if mod(h,100)==0
	     if isempty(progress_bar)==0
			gtk(progress_bar.in,progress_bar.out,["gtk_progress_bar_set_fraction ",progress_bar.id,sprintf('%.1f',0.5+(0.5*h)/numnodos)]);
			gtk(progress_bar.in,progress_bar.out,"gtk_server_callback update");
		 else
            midisplay(sprintf('%d %d',h,total_anchors));
		 end
    end
	
	metodo_distancia=2;
	if metodo_distancia==1
		%Este cálculo de la distancia trata de cuadrar los resultados dados por el BTB	
		distancia=0;
		for t=0:0.5:1
			salida=interpola_spline(Punto0,Distancia0,[AngleXZ0 AngleY0],Punto3,Distancia3,[AngleXZ3 AngleY3],t);
			%plot(salida(1),salida(2),'+');
			if t>0
				distancia=distancia+sqrt(sum((salida-salida_anterior).^2));
			end
			salida_anterior=salida;
		end
	else %Cálculo de la distancia basado en la integración de la derivada
		[coef_x coef_z]=derivada_spline(Punto0,Distancia0,[AngleXZ0 AngleY0],Punto3,Distancia3,[AngleXZ3 AngleY3]);
		elpaso=0.01;
		counter=1;
		anterior=0;
		distancia_int=[];
		for hh=elpaso:elpaso:1
			distancia_int(counter)=quad(@(x) sqrt((coef_x(3)*x^2+coef_x(2)*x+coef_x(1))^2+(coef_z(3)*x^2+coef_z(2)*x+coef_z(1))^2),hh-elpaso,hh,[0.1 0])+anterior;
			anterior=distancia_int(counter);
			counter=counter+1;
		end
		distancia_int=[0 distancia_int];
		distancia=distancia_int(end);
	end
    
	segmentos=round(distancia/panel_length);
	if segmentos==0
		segmentos=1;
	end
	
	if distribucion==1
		%display('Using LINEAR (non uniform) spacing');
		divisiones=linspace(0,1,segmentos+1);
	else
		%display('Using NONLINEAR (uniform) spacing');
		pos_segmentos=linspace(0,distancia,segmentos+1);
		divisiones=calcula_t(pos_segmentos,distancia_int);
	end
	
	total_anchors=total_anchors+2*(segmentos);

    for t=divisiones
        [salida angulop curvatura]=interpola_spline(Punto0,Distancia0,[AngleXZ0 AngleY0],Punto3,Distancia3,[AngleXZ3 AngleY3],t);
		%plot(salida(1),salida(3),'o');
		if (h==1) || (t>0)
			porcentajes(contador,:)=[h t];
			anchors_dcha(contador,:)=[salida(1)+ancho_track*cos(angulop) salida(2) salida(3)+ancho_track*sin(angulop)];
			anchors_izda(contador,:)=[salida(1)-ancho_track*cos(angulop) salida(2) salida(3)-ancho_track*sin(angulop)];
			%plot([anchors_izda(contador,1) anchors_dcha(contador,1)],[anchors_izda(contador,3) anchors_dcha(contador,3)],'g');
			anguloxzp(contador)=angulop;
            curvaturaxz(contador)=1/curvatura;
			contador=contador+1;
		end	 
    end
end    

save('anguloxzp.mat','anguloxzp','curvaturaxz');

%figure
%hold on
%plot(anchors_izda(:,1),anchors_izda(:,3),'o');
%plot(anchors_dcha(:,1),anchors_dcha(:,3),'or');

total_anchors=total_anchors+2;
midisplay(sprintf('%d %d',h,total_anchors));

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
midisplay('Grabando ..\anchors.mat')
tree=[];
offset=length(anchors_izda);
for h=1:length(anchors_izda)
    if mod(h,1000)==0
         midisplay(sprintf('%d',h));
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

function [coef1 coef2]=derivada_spline(punto0,distancia0,angulos0,punto3,distancia3,angulos3)

x0=punto0(1);
y0=punto0(2);
z0=punto0(3);

x3=punto3(1);
y3=punto3(2);
z3=punto3(3);

anguloxz0=pi+(pi/2-angulos0(1));
anguloy0=-angulos0(2);

x1=x0+(distancia0*cos(anguloy0))*cos(anguloxz0);
z1=z0+(distancia0*cos(anguloy0))*sin(anguloxz0);
y1=y0+distancia0*sin(anguloy0);

anguloxz3=(pi/2-angulos3(1));
anguloy3=angulos3(2);

x2=x3+(distancia3*cos(anguloy3))*cos(anguloxz3);
z2=z3+(distancia3*cos(anguloy3))*sin(anguloxz3);
y2=y3+distancia3*sin(anguloy3);

A = x3 - 3*x2 + 3*x1 - x0;
B = 3*x2  - 6*x1  + 3*x0;   
C = 3*x1 - 3*x0;
D = x0;

E = z3 - 3*z2 + 3*z1 - z0;
F = 3*z2  - 6*z1  + 3*z0;   
G = 3*z1 - 3*z0;
H = z0;

I = y3 - 3*y2 + 3*y1 - y0;
J = 3*y2  - 6*y1  + 3*y0;   
K = 3*y1 - 3*y0;
L = y0;

%x=A*t^3+B*t^2+C*t+D;
%y=I*t^3+J*t^2+K*t+L;
%z=E*t^3+F*t^2+G*t+H;

%salida=[x y z];

%Derivadas
%Según x
%dx=3*A*t^2+2*B*t+C;
%Según z
%dz=3*E*t^2+2*F*t+G;

coef1(3)=3*A;
coef1(2)=2*B;
coef1(1)=C;

coef2(3)=3*E;
coef2(2)=2*F;
coef2(1)=G;
end

function los_t=calcula_t(pos_segmentos,distancia_int)
	los_t(1)=0;
	for hn=2:length(pos_segmentos)-1
		inicio=sum(pos_segmentos(hn)>=distancia_int);
		fin=inicio+1;
		
		fraccion=(pos_segmentos(hn)-distancia_int(inicio))/(distancia_int(fin)-distancia_int(inicio));
		los_t(hn)=(inicio-1+fraccion)/(length(distancia_int)-1);
	end
	los_t(length(pos_segmentos))=1;
end

end