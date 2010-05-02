function dividir_anchos()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.


if nargin>0
  display('Uso: sin par�metros');
  return;
end

fichero_anchos='anchos.mat';

S=load(fichero_anchos);
tree=S.tree;

ST=load('tramos_nodos.mat');
tramos=ST.tramos;

track_actual=0;
contador=1;
inicio=1;

for h=1:length(tree)
        elnodo(h)=tree(h).StartNode;
		[track,nodo_inicial,frontera]=dame_nodo_inicial(elnodo(h),tramos);
		tree(h).StartNode=elnodo(h)-nodo_inicial;
		
		if track~=track_actual
				fichero=sprintf('salida\\anchos%02d.txt',contador);
				grabar_anchos(fichero,tree,inicio,h-1);
				inicio=h;
				contador=contador+1;
				track_actual=track;
		end
end
fichero=sprintf('salida\\anchos%02d.txt',contador);
grabar_anchos(fichero,tree,inicio,length(tree));


function grabar_anchos(fichero,tree,inicio,final);
	fid=fopen(fichero,'w');
	fprintf(fid,'      <Widths count="%d">\n',(final-inicio+1));
		for h=inicio:final
			nodo=tree(h).StartNode;
			porcentaje=tree(h).StartPercentage;
			ancho=tree(h).WidthMultiplier;
			fprintf(fid,'        <Width>\n          <StartNode>%d</StartNode>\n          <StartPercentage>%f</StartPercentage>\n          <WidthMultiplier>%f</WidthMultiplier>\n        </Width>\n',nodo,porcentaje,ancho);
		end
		
	fprintf(fid,'      </Widths>\n');
	fclose(fid);
end


end
