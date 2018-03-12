function fid=my_fopen(fichero,modo)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

  if modo=='r'
     mensaje='Leyendo';
  else
    mensaje='Escribiendo';
  end
  midisplay(sprintf('%s el fichero %s',mensaje,fichero));
  fid=fopen(fichero,modo);
  if fid==-1
    midisplay(sprintf('Error accesing file %s in folder %s',fichero,pwd));
	midisplay('Check the file exists');
  end
end