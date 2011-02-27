function  join_all()
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

fichero1='salida\Venue.xml';
muros1='..\s7_walls\salida\muros.txt';
listado_imagenes='..\s1_mesh\list_bi.txt';

grabar(fichero1,muros1,listado_imagenes);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function grabar(fichero1,muros1,listado_imagenes)
fid1=my_fopen(fichero1,'w')

fid=my_fopen('start.txt','r');
contents=fread(fid,inf);
my_fclose(fid);

fid=fopen(listado_imagenes,'r');
if fid~=-1
  contenido_imagenes=fread(fid,inf);
  fclose(fid);
  contenido_imagenes=char(contenido_imagenes)';
  contents=strrep(char(contents)','<BackgroundImages count="0" />',contenido_imagenes);
  display(sprintf('Including %s',listado_imagenes));
else
  display(sprintf('%s not found',listado_imagenes));
end
fprintf(fid1,"%s",contents);



numtramos=cargar_tramos()

fid=my_fopen('..\s10_split\salida\listado_tracks.txt','r');
contents=fread(fid,inf);
my_fclose(fid)
cadena=char(contents)';
cadena=regexprep(cadena,'<tracks count="\d+" ActiveTrack',sprintf('<tracks count="%d" ActiveTrack',sum(numtramos)));
fprintf(fid1,'%s',cadena);

[numero_sons caminos]=look_for_father_or_sons('..\sons.txt');

for h=1:numero_sons
	fid=my_fopen(strcat(char(caminos(h)),'\s10_split\salida\listado_tracks.txt'),'r');
	contents=fread(fid,inf);
	cadena=char(contents)';
	for g=0:numtramos(h+1)-1
		cadena=strrep(cadena,sprintf('<TrackId>%d</TrackId>',g),sprintf('<TrackId>%d</TrackId>',g+sum(numtramos(1:h))));
	end
	my_fclose(fid)
	fprintf(fid1,'%s',cadena);
end

fid=fopen(muros1,'r');
if fid~=-1
  contents=fread(fid,inf);
  fclose(fid)
  fwrite(fid1,contents);
  display(sprintf('Including %s',muros1));
 else
  fprintf(fid1,'\r\n  <Walls count="0" />\r\n');
  display(sprintf('%s not found',muros1));
end

fclose(fid1);

fid1=my_fopen(fichero1,'r');
contents=fread(fid1,inf);
fclose(fid1);
fid1=my_fopen(fichero1,'w');
cadena=char(contents)';
cadena=regexprep(cadena,'</tracks>  <tracks count="\d+" ActiveTrack="\d+">','');
fprintf(fid1,'%s',cadena);
fclose(fid1);
fid1=my_fopen(fichero1,'a');

fprintf(fid1,'\r\n  <Terrain>\r\n');

fid=my_fopen('..\s4_terrain\salida\listado_anchors.txt','r');
contents=fread(fid,inf);
my_fclose(fid)

fwrite(fid1,contents);


fid=my_fopen('..\s10_split\salida\lis.txt','r');
contents=fread(fid,inf);
my_fclose(fid)

fwrite(fid1,contents);

fprintf(fid1,'\r\n  </Terrain>\r\n');

fid=my_fopen('end1.txt','r');
contents=fread(fid,inf);
my_fclose(fid)

fwrite(fid1,contents);

tramos_nodos=load('..\s10_split\tramos_nodos.mat');
num_segments=size(tramos_nodos.tramos);
num_segments=num_segments(1)*num_segments(2)/2;

fprintf(fid1,'\r\n  <DrivelineSegments count="%d">\r\n',num_segments);
for h=0:num_segments-1
  fprintf(fid1,'   <DrivelineSegment>\r\n      <TrackId>%d</TrackId>\r\n      <LinkedToTrack>True</LinkedToTrack>\r\n      <Reversed>False</Reversed>\r\n   </DrivelineSegment>\r\n',h);
end
fprintf(fid1,'  </DrivelineSegments>\r\n');

fid=my_fopen('end2.txt','r');
contents=fread(fid,inf);
my_fclose(fid)

fwrite(fid1,contents);

fid=fopen('..\pacenotes\salida\pacenotes.txt','r');
if fid~=-1
  contents=fread(fid,inf);
  fclose(fid)
  fwrite(fid1,contents);
  display('pacenotes included');
 else
  fprintf(fid1,'\r\n  <Pacenotes count="0" />\r\n');
  display('pacenotes not found');
end

fid=my_fopen('end3.txt','r');
contents=fread(fid,inf);
my_fclose(fid)

fwrite(fid1,contents);

fclose(fid1)
end

function numtramos=cargar_tramos()
	tramos=load('..\s10_split\tramos.mat');
	tramos=tramos.tramos;
	tama=size(tramos);
	numtramos(1)=tama(1)*tama(2)/2;
	[numero_sons caminos]=look_for_father_or_sons('..\sons.txt');

	for h=1:numero_sons
		tramos_extra=load(strcat(char(caminos(h)),'\s10_split\tramos.mat'));
		tramos_extra=tramos_extra.tramos;
		tama=size(tramos_extra);
		numtramos(h+1)=tama(1)*tama(2)/2;
	end		
end

end