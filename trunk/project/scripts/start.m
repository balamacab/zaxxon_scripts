function start(paso_fino,paso_grueso,npuntos)

if nargin==0
	paso_fino=25;
	paso_grueso=75;
	npuntos=5000;
end

cd s0_import
importakml('road.kml');
[mapeo]=textread('..\mapeo.txt','%f');

cd ..\s2_elevation
m_grid('limits.kml',paso_fino,mapeo,npuntos);

cd ..\s2_elevation_b
m_grid('limits_b.kml',paso_grueso,mapeo,npuntos);


function m_grid(ficherokml,paso,mapeo,npuntos)
[longitud latitud altura]=leer_datos(ficherokml);
[lax nada laz]=coor_a_BTB(longitud,latitud,0,mapeo);
minx=min(lax);
maxx=max(lax);
minz=min(laz);
maxz=max(laz);

make_grid(minx-2*paso,maxx+2*paso,minz-2*paso,maxz+2*paso,paso,npuntos);

%message(20);
