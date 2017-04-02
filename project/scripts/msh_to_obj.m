function msh_to_obj(fichero_nodos,fichero_elements)

[numero x y z]=textread(fichero_nodos,'%d %f %f %f');

fid=fopen(fichero_elements,'r');
fid_w=fopen(strcat('salida/test','.obj'),'w');
fprintf(fid_w,'mtllib test.mtl\n');
contador=1;
while (feof(fid)~=1)
    todo=fscanf(fid,'%d',3);
	if length(todo)>0
		tipo=todo(2);
		if (tipo==2) || (tipo==3)
			numtags=todo(3);
			lostags=fscanf(fid,'%d',numtags);
			id_superficie(contador)=lostags(1);
			id_particular(contador)=lostags(2);
			if tipo==2 %Triang
				datos=fscanf(fid,'%d %d %d\n',3);
				n1(contador)=datos(1);
				n2(contador)=datos(2);
				n3(contador)=datos(3);
				n4(contador)=-1;
			elseif tipo==3
				datos=fscanf(fid,'%d %d %d %d\n',4);
				n1(contador)=datos(1);
				n2(contador)=datos(2);
				n3(contador)=datos(3);
				n4(contador)=datos(4);
			end
			contador=contador+1;
		else
		fgets(fid);
		end
	end
end
fclose(fid);
[id_superficie,orden]=sort(id_superficie);
n1=n1(orden);
n2=n2(orden);
n3=n3(orden);
n4=n4(orden);
id_particular=id_particular(orden);

		fprintf(fid_w,'v %f %f %f\r\n',[x z -y]');%La altura es y en los ficheros de nodos ya elevados
                                                %Blender interpreta que la
                                                %su y es -z y que su z es y
		
		for g=1:length(x)
			fprintf(fid_w,'vn 0 1 0\r\n');
		end
			
		v1=n1;
		v2=n2;
		v3=n3;
		v4=n4;
		id_anterior=-1;
        
		for h=1:length(n1)
				%if id_superficie(h)~=id_anterior
				%	fprintf(fid_w,'g group%02d\r\n',id_superficie(h));
				%	id_anterior=id_superficie(h);
				%end
				if id_particular(h)~=id_anterior
					fprintf(fid_w,'g group%02d\r\n',id_particular(h));
                    fprintf(fid_w,'usemtl material_00\n');
					id_anterior=id_particular(h);
				end
				if v4(h)==-1
					fprintf(fid_w,'f %d/%d/%d %d/%d/%d %d/%d/%d\r\n',v1(h),v1(h),v1(h),v2(h),v2(h),v2(h),v3(h),v3(h),v3(h));
				else
					fprintf(fid_w,'f %d/%d/%d %d/%d/%d %d/%d/%d %d/%d/%d\r\n',v1(h),v1(h),v1(h),v2(h),v2(h),v2(h),v3(h),v3(h),v3(h),v4(h),v4(h),v4(h));
				end
		end			

		fclose(fid_w);
end
