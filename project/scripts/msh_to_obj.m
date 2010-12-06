function msh_to_obj(fichero_nodos,fichero_elements)

[numero x y z]=textread(fichero_nodos,'%d %f %f %f');

fid=fopen(fichero_elements,'r');
contents=fread(fid,inf);
fclose(fid);
cadena=char(contents)';
todo=sscanf(cadena,'%d',inf);
numtags=todo(3);
tam_registro=numtags+6;
id_superficie=todo(4:tam_registro:end);
n1=todo((numtags+4):tam_registro:end);
n2=todo((numtags+5):tam_registro:end);
n3=todo((numtags+6):tam_registro:end);
id_particular=todo(5:tam_registro:end);

[nada,orden]=sort(id_superficie);
n1=n1(orden);
n2=n2(orden);
n3=n3(orden);
id_particular=id_particular(orden);

		fid_w=fopen(strcat('salida\test','.obj'),'w');
		
		
		fprintf(fid_w,'v %f %f %f\r\n',[x y -z]')
		
		for g=1:length(x)
			fprintf(fid_w,'vn 0 1 0\r\n');
		end
			
		v1=n1;
		v2=n2;
		v3=n3;
		id_anterior=-1;
		for h=1:length(n1)
				if id_superficie(h)~=id_anterior
					fprintf(fid_w,'g group%02d\r\n',id_anterior);
					id_anterior=id_superficie(h);
				else
				end
			    fprintf(fid_w,'f %d/%d/%d %d/%d/%d %d/%d/%d\r\n',v1(h),v1(h),v1(h),v2(h),v2(h),v2(h),v3(h),v3(h),v3(h));
		end			

		fclose(fid_w);
end
