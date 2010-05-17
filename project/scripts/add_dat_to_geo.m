function add_dat_to_geo(camino)

if nargin==0
	camino=pwd;
end


[errores,filename]=system(sprintf('dir %s\\*.dat /b',camino));
ficheros=strsplit(filename,strcat(char(13),char(10)));

longitudes=[];
latitudes=[];
for h=1:length(ficheros)
	if length(find(char(ficheros(h)))>0)
		[longitud latitud]=lee_dat(strcat(camino,'\',char(ficheros(h))));
		longitudes=[longitudes longitud];
		latitudes=[latitudes latitud];
	end
end	

longitudes=ordena_y_limpia(longitudes);
latitudes=ordena_y_limpia(latitudes);

[mapeo]=textread('..\mapeo.txt','%f');

[minx nada minz]=coor_a_BTB(longitudes(1),latitudes(1),0,mapeo);
[maxx nada maxz]=coor_a_BTB(longitudes(end),latitudes(end),0,mapeo);
pasox=(maxx-minx)/(length(longitudes)-1);
pasoz=(maxz-minz)/(length(latitudes)-1);
display('Making a backup of addgrid.hlg')
backup_name=sprintf('addgrid_backup%03d.hlg',randint(1,1,1000));
display(sprintf('Backuping addgrid.hlg as %s',backup_name));
system(sprintf('copy addgrid.hlg %s',backup_name));
addgrid(minx,maxx,minz,maxz,[pasox pasoz]);
add_background_images(minx,maxx,minz,maxz,[pasox pasoz]);

function add_background_images(minx,maxx,minz,maxz,paso)
pasox=paso(1);
pasoz=paso(2);
fid=fopen('list_bi.txt','w');
numx=round((maxx-minx)/pasox);
numz=round((maxz-minz)/pasoz);

fprintf(fid,'  <BackgroundImages count="%d">\r\n',numx*numz);
for h=1:numx
    posx=minx+(h-1)*pasox;
	for g=1:numz
	posz=maxz-(g-1)*pasoz;
	fprintf(fid,'    <BackgroundImage>\r\n');
	fprintf(fid,'      <Path>Common\\Textures\\sat_%d-%d.dds</Path>\r\n',h,g);
	fprintf(fid,'      <Plane>\r\n');
	fprintf(fid,'        <Position x="%f" y="-0.5" z="%f" />\r\n',posx,posz);
	fprintf(fid,'        <Scale x="%f" y="1" z="%f" />\r\n',pasox,-pasoz);
	fprintf(fid,'        <Rotation x="0" y="0" z="0" />\r\n');
	fprintf(fid,'      </Plane>\r\n');
	fprintf(fid,'    </BackgroundImage>\r\n');
	
	end
end	
fprintf(fid,'  </BackgroundImages>\r\n');
fclose(fid);
	
function [longitud latitud]=lee_dat(fichero)
fid=my_fopen(fichero,'r');
coordenadas=fscanf(fid,'%d %f,%f\n%f,%f\n%f,%f\n%f,%f');
coordenadas=coordenadas';
longitud=coordenadas(2:2:9);
latitud=coordenadas(3:2:9);
my_fclose(fid);

end

function longitudes=ordena_y_limpia(longitudes)
longitudes=sort(longitudes);
buenos=(find(diff(longitudes)>0)+1);
longitudes=[longitudes(1) longitudes(buenos)];