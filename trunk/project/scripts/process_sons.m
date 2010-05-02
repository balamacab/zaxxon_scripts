function process_sons()
%This script needs file sons.txt to be on the current directory

[numero_sons caminossons]=look_for_father_or_sons('sons.txt')
origen=pwd;

for h=1:numero_sons

	cd(char(caminossons(h)));
	cd s0_import;
	[errores,filename]=system('dir *.kml /b')
	cd ..;
	pos = findstr (filename, '.kml');
	filename=filename(1:pos+3);
		%%%%%%%%%%%%%%%%%%%%%%CHANGE TEXT BELOW%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	cd s0_import;
	
	importakml(filename,0.75);
	cd ..\venue;
	btb06(4);
	cd ..\s3_road
	coge_datos
	creartrack1
	try
	    dar_altura(1,0.25,-0.25,10,0);
	catch
	    dar_altura(1,0.25,-0.25,5,0);
	end
	cd ..\venue
	btb06(4)
	cd ..\s1_mesh
	mallado_regular(8,2);
	cd ..\s10_split
	coge_datos
	split_track(1)
	partir_track
	%%%%%%%%%%%%%%%%%%%%%%CHANGE TEXT ABOVE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end	
cd(origen);