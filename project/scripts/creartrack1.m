function creartrack1(usar_centro);
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.


if nargin>1
  display('Sin argumentos');
  return;
end

if nargin==0
  usar_centro=0;
end

if (exist('..\..\agr')==7) || (exist('..\..\lidar')==7)
	creartrack1_agr(usar_centro);
	return
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

S=load('..\nac.mat');
nac=S.nac;

S=load('..\anchors.mat');
x=S.x;
y=S.y;
z=S.z;

malla=load('lamalla.mat');
malla.malla_regular=single(malla.malla_regular); %Por si los datos son enteros

if usar_centro==0
    alturas_derecha=z_interp2(malla.rangox,malla.rangoz,malla.malla_regular,x(1:nac/2),z(1:nac/2));
    alturas_izquierda=z_interp2(malla.rangox,malla.rangoz,malla.malla_regular,x(nac/2+1:end),z(nac/2+1:end));
	nueva_altura=zeros(length(alturas_derecha),1);
else
    alturas_centro=z_interp2(malla.rangox,malla.rangoz,malla.malla_regular,0.5*(x(1:nac/2)+x(nac/2+1:end)),0.5*(z(1:nac/2)+z(nac/2+1:end)));
	nueva_altura=zeros(length(alturas_centro),1);
end


for h=1:length(nueva_altura)
    if usar_centro==0
       nueva_altura(h)=min([alturas_izquierda(h) alturas_derecha(h)]);
    else
       nueva_altura(h)=alturas_centro(h);
    end
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
