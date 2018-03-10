function creatodo(h)

road_width=[   4   3   3   3   3  4  ];


  numtracks=12;%46;
	panel_length=5*ones(1,numtracks);
	%road_width=5*ones(1,numtracks);
	panel_length(23+1)=3.7;
	

%for h=1:numtracks-1
	%try
		
		p.amp_ruido=0.3;%0.1 en primera version
		p.ancho_carretera=road_width(h+1);
		
		fichero=sprintf('r%02d.kml',h);
		fprintf(2,'\n\n%s\n\n',fichero);
		cd s0_import;
		importakml(fichero);
		cd ..\venue
		btb06(p.ancho_carretera,1,panel_length(h+1));
		cd ..\s3_road
		s3_coge_datos;
		creartrack1(0);
		conseguido=0;
		paso=10;
		while (conseguido==0)
			 try
				system(sprintf('move r%02d.txt retoques.txt',h)); 
				dar_altura(13,0.25,-0.25,paso,1);
				system(sprintf('move retoques.txt r%02d.txt',h));
				conseguido=1;
			catch
				paso=paso-2;
			end_try_catch
		end
		if (h==0)
			cd ..\s4_terrain
			crearbase
			system(sprintf('copy salida\\fondo.obj ..\\Output\\r%02dfondo.obj',h));
		end	
		cd ..\s11_m3d
		s11_coge_datos
		
		fprintf(2,'Mallando\n');
		mallado(p);
		cd ..\s4_terrain
		s4_coge_datos;
		p_n;
		poncarretera;
		cd ..
		system(sprintf('copy s4_terrain\\direct.trk Output\\r%02dd.trk',h));
                system(sprintf('copy s4_terrain\\inverse.trk Output\\r%02di.trk',h));
		salida1='s4_terrain\salida\test_concarretera.obj';nombre1=sprintf('Output\\r%02d_01.obj',h);
		salida2='s4_terrain\salida\contexturas1.obj';nombre2=sprintf('Output\\r%02d_02.obj',h);
		salida3='s4_terrain\salida\murodcho.obj';nombre3=sprintf('Output\\r%02d_03.obj',h);
		salida4='s4_terrain\salida\muroizdo.obj';nombre4=sprintf('Output\\r%02d_04.obj',h);
		system(sprintf('copy %s %s\n',salida1,nombre1));pause(1);
		system(sprintf('copy %s %s\n',salida2,nombre2));pause(1);
		system(sprintf('copy %s %s\n',salida3,nombre3));pause(1);
		system(sprintf('copy %s %s\n',salida4,nombre4));pause(1);
		salida5='s4_terrain\salida\inside.x';nombre5=sprintf('Output\\r%02d_01.x',h);
		salida6='s4_terrain\salida\outside.x';nombre6=sprintf('Output\\r%02d_02.x',h);
		salida7='s4_terrain\salida\muroizdo.x';nombre7=sprintf('Output\\r%02d_03.x',h);
		salida8='s4_terrain\salida\murodcho.x';nombre8=sprintf('Output\\r%02d_04.x',h);
		system(sprintf('copy %s %s\n',salida5,nombre5));pause(1);
		system(sprintf('copy %s %s\n',salida6,nombre6));pause(1);
		system(sprintf('copy %s %s\n',salida7,nombre7));pause(1);
		system(sprintf('copy %s %s\n',salida8,nombre8));pause(1);
	%catch
	%	fprintf(2,'%d falla---------\n',h);
	%end_try_catch
end

endfunction
