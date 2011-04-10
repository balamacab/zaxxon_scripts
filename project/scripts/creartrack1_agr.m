function creartrack1_agr(usar_centro);
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.


if nargin>1
  display('Sin argumentos');
  return;
end

if nargin==0
  usar_centro=0;
end

%        <node NodeId="700">
%          <Position x="1666.922" y="4296.436" z="-3785.737" />
%          <ControlPoints AngleXZ="-1.997605" AngleY="0.04364966" EntryDistance="5.304023" ExitDistance="0" />
%        </node>

% S=load(fichero_nodos_carretera)
% tree=S.tree;
% for h=1:length(tree.Anchor)
%         elnodo(h)=tree.Anchor(h).StartNode  ;
%         elporcentaje(h)=tree.Anchor(h).StartPercentage  ;
% end

[numero_padres caminos]=look_for_father_or_sons('..\father.txt');

if numero_padres==0  
	[mapeo]=textread('..\mapeo.txt','%f');
else
	[mapeo]=textread(strcat(caminos(1),'\mapeo.txt'),'%f');
end


display('Calculamos la altura de la carretera en función de la altura de los anchors de carretera')

S=load('..\nac.mat');
nac=S.nac;

display('Leyendo la posición de los anchors de lamalla.mat')
S=load('..\anchors.mat');
x=S.x;
y=S.y;
z=S.z;
if usar_centro==0


    [pos1 pos3 pos2]=BTB_a_coor(x,0,z,mapeo);%Altura es el segundo

    %Los datos LiDAR mantienen las coordenadas originales, así que la carretera hay que pasarla a ese sistema de coordenadas
    fid=fopen('carretera.txt','w')
    for h=1:nac
      fprintf(fid,'%f %f\r\n',pos1(h),pos2(h));
    end
    fclose(fid);

    alturas=elevar_agr('carretera.txt',mapeo);
	if length(alturas)==0
		return
	end
    %No tengo claro que la derecha y la izquierda estén bien escogidas
    alturas_izquierda=alturas(1:nac/2);
    alturas_derecha=alturas(nac/2+1:end);

    for h=1:length(alturas_derecha)
        nueva_altura(h)=min([alturas_izquierda(h) alturas_derecha(h)]);
    end
else
    xc=0.5*(S.x(1:nac/2)+S.x(nac/2+1:nac));
    yc=0.5*(S.y(1:nac/2)+S.y(nac/2+1:nac));
    zc=0.5*(S.z(1:nac/2)+S.z(nac/2+1:nac));

    [pos1 pos3 pos2]=BTB_a_coor(xc,0,zc,mapeo);%Altura es el segundo

    %Los datos LiDAR mantienen las coordenadas originales, así que la carretera hay que pasarla a ese sistema de coordenadas
    fid=fopen('carretera.txt','w')
    for h=1:nac/2
      fprintf(fid,'%f %f\r\n',pos1(h),pos2(h));
    end
    fclose(fid);

    nueva_altura=elevar_agr('carretera.txt',mapeo);
end

cabecera=sprintf('      <nodes count=\"%d\">\n        <OnlyOneNodeSelected>1</OnlyOneNodeSelected>\n<LineType>BezierSpline</LineType>\n',length(nueva_altura));
cola='      </nodes>';

fid=my_fopen('salida\t1.txt','w')
fprintf(fid,cabecera);
angulo=0;
anguloy=0;

for h=1:length(nueva_altura)
    if mod(h,100)==0
        mensaje=sprintf('%.2f\n',h/length(nueva_altura));
        display(mensaje);
    end
    if (h>1) && (h<length(nueva_altura))
        angulo=angle(x(h)-x(h-1)+j*(z(h)-z(h-1)));
        inc_altura=nueva_altura(h+1)-nueva_altura(h-1);
        separacion=norm(x(h+1)-x(h-1)+j*(z(h+1)-z(h-1)));
        anguloy=angle(separacion+j*inc_altura);
    end
    fprintf(fid,'        <node NodeId=\"%d\">\n          <Position x=\"%f\" y=\"%f\" z=\"%f\" />\n          <ControlPoints AngleXZ=\"%f\" AngleY=\"%f\" EntryDistance=\"%f\" ExitDistance=\"%f\" />\n        </node>\n',...
        h-1,(x(h)+x(h+nac/2))/2,nueva_altura(h),(z(h)+z(h+nac/2))/2,angulo,-anguloy,1,1);
end
fprintf(fid,cola);
my_fclose(fid)

alturas_track1=nueva_altura;
display('Grabando alturas_track1.mat');
save('alturas_track1.mat','alturas_track1');

if find(isnan(alturas_track1)==1)
    display('----------------------------------------------------------------------------------------------------------');
    display('SOME POINTS OF THE MESH WILL HAVE A WRONG ALTITUDE. CHECK THAT YOUR MESH DOESN''T EXCEED AVAILABLE DATA');
	display('DON''T GO ON WITH THE PROCESS UNTIL YOU CORRECT THIS PROBLEM');
	display(sprintf('Track limits:                    x in [%.1f,%.1f], z in [%.1f,%.1f]',min(x),max(x),min(z),max(z)));
	display(sprintf('Available elevation data limits: x in [%.1f,%.1f], z in [%.1f,%.1f]',malla.rangox(1),malla.rangox(end),malla.rangoz(1),malla.rangoz(end)));
	display('----------------------------------------------------------------------------------------------------------');
else
	message(5);
end

end
