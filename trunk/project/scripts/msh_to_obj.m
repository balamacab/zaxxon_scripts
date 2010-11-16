function msh_to_obj(fichero_nodos,fichero_elements)

[numero x y z]=textread(fichero_nodos,'%d %f %f %f');

[nada1 nada2 nada3 id_superficie nada5 nada6 n1 n2 n3]=textread(fichero_elements,'%d %d %d %d %d %d %d %d %d');

		fid_w=fopen(strcat('salida\test','.obj'),'w');
		fprintf(fid_w,'g group1\r\n');
		
		fprintf(fid_w,'v %f %f %f\r\n',[x y -z]')
		
		for g=1:length(x)
			fprintf(fid_w,'vn 0 1 0\r\n');
		end
			
		v1=n1;
		v2=n2;
		v3=n3;
		for h=1:length(n1)
			    fprintf(fid_w,'f %d/%d/%d %d/%d/%d %d/%d/%d\r\n',v1(h),v1(h),v1(h),v2(h),v2(h),v2(h),v3(h),v3(h),v3(h));
		end			

		fclose(fid_w);
end
