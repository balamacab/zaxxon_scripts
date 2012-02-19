function process_sons()
%This script needs file sons.txt to be on the current directory

[numero_sons caminossons]=look_for_father_or_sons('sons.txt')
origen=pwd;

%road_width=8*ones(numero_sons,1);%All the roads have 8m width
%road_width(4)=6; %road 6 has a different width
%Use: btb06(road_width(h),1)

for h=1:numero_sons

	cd(char(caminossons(h)));
	cd s0_import;
	[errores,filename]=system('dir *.kml /b')
	cd ..;
	pos = findstr (filename, '.kml');
	filename=filename(1:pos+3);
		%%%%%%%%%%%%%%%%%%%%%%CHANGE TEXT BELOW%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	cd s0_import;
	
	importakml(filename);
	cd ..\venue;
	btb06(4,1);
	cd ..\s3_road
	s3_coge_datos
	creartrack1
	try
            dar_altura(1,0.25,-0.25,10,0);
	catch
            try
                dar_altura(1,0.25,-0.25,5,0);
            catch
                dar_altura(1,0.25,-0.25,2,0);
            end
	end
	cd ..\venue
	btb06(4)
	cd ..\s1_mesh
	mallado_regular(8,2);
	cd ..\s10_split
	s10_coge_datos
	split_track(1)
	partir_track
	%%%%%%%%%%%%%%%%%%%%%%CHANGE TEXT ABOVE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end	
cd(origen);