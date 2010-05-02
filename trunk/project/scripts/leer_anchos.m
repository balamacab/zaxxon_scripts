function [tree]=leer_anchos()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

  fichero_entrada='..\Venue\anchos.xml';
  fichero_salida='anchos.mat';
fid = fopen(fichero_entrada,'r');

if nargin>0
  display('Uso: sin parámetros. Debe ejecutarse desde dentro de s10_split')
  return;
end

contador=1;
contador_anchors=0;

while ~feof(fid),
    linea=fgets(fid);
    nuevo_anchor=findstr(linea,'Widths');
    if length(nuevo_anchor)>=1
        break;
    end
end

salir=0;
tree=[];
contador=0;
while ~feof(fid),
    linea=fgets(fid);
    nuevo_anchor=findstr(linea,'<Width>');
    if length(nuevo_anchor)>=1
        contador_anchors=contador_anchors+1;
        estructura.inicializado=1;
    else
      while (salir==0) && isempty(findstr(linea,'</Width>')) && (length(linea)>2) && (~feof(fid)),
            remain=linea;
            display(linea)
            [str, remain] = strtok(remain, '>');
            [previo Parametro]= strtok(str,'<');
            [valor resto]= strtok(remain,'<');
            estructura=setfield(estructura,Parametro(2:end),str2num(valor(2:end)));
			mensaje=sprintf('%s=%s\n',Parametro,valor);
			disp(mensaje);
            linea=fgets(fid);
			contador=contador+1;
        end
        if length(findstr(linea,'</Width>'))>0
            estructura=rmfield(estructura,'inicializado');
            tree=[tree;estructura];
            salir=1;
        end
    end

end
fclose(fid)

save(fichero_salida,'tree'); 
