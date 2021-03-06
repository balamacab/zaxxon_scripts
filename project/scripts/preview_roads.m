function preview_roads()
%Creates a Venue.xml with all the roads of the project
%(taken from step s3_road)

[numero_sons caminos]=look_for_father_or_sons('..\sons.txt');

fid1=my_fopen('salida\Venue.xml','w');

fid=my_fopen('Venue_start.txt','r');
contents=fread(fid,inf);
my_fclose(fid);
venue_start=char(contents)';
venue_start=regexprep(venue_start,'<tracks count="1"',sprintf('<tracks count="%d"',numero_sons+1));
fid=my_fopen('Venue_end.txt','r');
contents=fread(fid,inf);
my_fclose(fid);
venue_end=char(contents)';

fprintf(fid1,'%s\n',venue_start);

fid=my_fopen('..\s10_split\track_start.txt','r');
contents=fread(fid,inf);
my_fclose(fid)
track_start=char(contents)';

fid=my_fopen('..\s10_split\track_middle.txt','r');
contents=fread(fid,inf);
my_fclose(fid)
track_middle=char(contents)';

fid=my_fopen('..\s10_split\track_end.txt','r');
contents=fread(fid,inf);
my_fclose(fid)
track_end=char(contents)';

fid=my_fopen('salida\nodes.xml','r');
contents=fread(fid,inf);
cadena=char(contents)';
my_fclose(fid)
fprintf(fid1,'%s\n%s\n%s\n',cadena,track_middle,track_end);

for h=1:numero_sons
	fid=my_fopen(strcat(char(caminos(h)),'\s3_road\salida\nodes.xml'),'r');
	contents=fread(fid,inf);
	cadena=char(contents)';
	my_fclose(fid)
	if h>=1
		fprintf(fid1,'%s\n',track_start);
	end
	fprintf(fid1,'%s\n',cadena);
	if h<numero_sons
		fprintf(fid1,'%s\n%s\n',track_middle,track_end);
	end
end

fprintf(fid1,'%s\n',venue_end);
fclose(fid1);

end