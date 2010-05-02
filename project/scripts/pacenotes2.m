function pacenotes2(sensibilidad,adelanto)
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

%--------------------------------------------------------------------------------------- 
%       Leemos las pacenotes (inicio, final y checkpoints) que hay en pacenotes.ini y las añadimos a las que hemos generado

pacenotes_previas=leer_pacenotesini();
%pacenotes_saltos=localiza_saltos(pendientes,distancias);

length(lista_pacenotes)
lista_pacenotes
length(pacenotes_previas) 
pacenotes_previas
if exist('lista_pacenotes')
		lista_pacenotes=[lista_pacenotes pacenotes_previas];
	else
		lista_pacenotes=[pacenotes_previas];
end
if exist('pacenotes_saltos')
	lista_pacenotes=[lista_pacenotes pacenotes_saltos];
end

for h=1:length(lista_pacenotes)
	distanc(h)=lista_pacenotes(h).distancia;
end
[valores orden]=sort(distanc);

lista_pacenotes=lista_pacenotes(orden);

fid=fopen('salida\pacenotes.ini','w');
fprintf(fid,'[PACENOTES]\ncount=%d\r\n',length(lista_pacenotes));
for h=1:length(lista_pacenotes)
  fprintf(fid,'[P%d]\ntype=%d\ndistance=%.2f\nflag=%d\r\n',h-1,lista_pacenotes(h).Tipo,lista_pacenotes(h).distancia,lista_pacenotes(h).flag);
end
fclose(fid)

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------------------------------------------------------------------------------


%---------------------------------------------------------------------------------------

function pacenotes_previas=leer_pacenotesini() 
	display('Leyendo pacenotes.ini')
	fid=fopen('pacenotes.ini','r');
	linea=fgets(fid);
	linea=fgets(fid);
	contador=0;
	while ~feof(fid)
		%Localizar [
		encontrado=0;
		while (encontrado==0) && (~feof(fid))
			linea=fgets(fid);			
			posiciones=findstr('[',linea);
			if length(posiciones)
				encontrado=1;
				linea=fgets(fid);
				[tipo]=sscanf(linea,'type=%d');
				linea=fgets(fid);
				[distancia]=sscanf(linea,'distance=%f');
				linea=fgets(fid);
				[flag]=sscanf(linea,'flag=%d');
				
				if (tipo==21) || (tipo==22) || (tipo==23) || (tipo==24) 
					contador=contador+1;
			                pacenotes_previas(contador).Nombre='';
			                pacenotes_previas(contador).nodo=0;
					pacenotes_previas(contador).Tipo=tipo;
					pacenotes_previas(contador).distancia=distancia;
					pacenotes_previas(contador).flag=flag;
				end
			else
				encontrado=0;
			end
		end
	end
	fclose(fid);
end

%--------------------------------------------------------------------------------------

function pacenotes_saltos=localiza_saltos(pendientes,distancias)
	derivada_pendiente=diff(pendientes);
	[maxtab mintab]=peakdet(derivada_pendiente,0.1);
	minimosnegativos=find(mintab(:,2)<0);
	mintab=mintab(minimosnegativos,:);
	contador=0;
	for h=1:length(mintab(:,1))
		if mintab(h,1)>1
			contador=contador+1;
			if mintab(h,2)<0.04
				pacenotes_saltos(contador).Tipo=20; %Salto
			elseif 	mintab(h,2)<0.025
				pacenotes_saltos(contador).Tipo=16; %Overcrest. 19 sería un bump
			end
			pacenotes_saltos(contador).distancia=distancias(mintab(h,1));
			pacenotes_saltos(contador).flag=0;
		end
	end
end
%---------------------------------------------------------------------------------------

