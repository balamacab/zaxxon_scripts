function fid=my_fopen(fichero,modo)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

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