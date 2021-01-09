function ponmuro(murox,muroy,muroz,etiqueta)

    rango=(1:length(murox));
    [s1,s2]=size(rango);if (s2<s1) rango=rango.';end
    [s1,s2]=size(murox);if (s2<s1) murox=murox.';end
    [s1,s2]=size(muroy);if (s2<s1) muroy=muroy.';end
    [s1,s2]=size(muroz);if (s2<s1) muroz=muroz.';end

    offs=length(rango);
    fid=fopen(['salida/nodosmuro',etiqueta,'.txt'],'w');
    fprintf(fid,'%d %f %f %f\n',[rango' murox' muroy' muroz']');
    fprintf(fid,'%d %f %f %f\n',[(rango+offs)' murox' muroy' (muroz+4)']'); %4 metros de alto
    fclose(fid);

    dmuro=sqrt(sum(diff(murox').^2+diff(muroy').^2,2));
    dmuro_acumulada=cumsum([0; dmuro])/10;
    triangulos=zeros((length(murox)-1)*2,3);
    murou=zeros(1,(length(murox)-1)*2+1);
    murov=zeros(1,(length(murox)-1)*2+1);
    for h=1:length(murox)-1;
        triangulos(2*h-1,:)= [h h+1 h+offs];
        triangulos(2*h,:)= [h+offs h+1 h+offs+1];
        murou(h)=dmuro_acumulada(h);
        murou(h+offs)=dmuro_acumulada(h);
        murov(h)=0;
        murov(h+offs)=1;
    end
    murou(offs)=dmuro_acumulada(offs);
    murou(offs+offs)=dmuro_acumulada(offs);
    murov(offs)=0;
    murov(offs+offs)=1;

    fid=fopen(['salida/elementsmuro',etiqueta,'.txt'],'w');
    fprintf(fid,'%d 2 2 55 0 %d %d %d  \n',[(1:longitud(triangulos,3))' triangulos ]');%zona 55, por poner algo
    fclose(fid);
    fid=fopen(['salida/texturasmuro',etiqueta,'.txt'],'w');
    fprintf(fid,'vt %f %f\n',[murou;murov]);
    fclose(fid);
	
	creax([murox murox],[muroy muroy],[muroz muroz+4],murou,murov,triangulos-1,'salida/muro.x','Transpa.dds');
    
    function salida=longitud(a,tam_elemento)
        if isempty(a)==0
            [m,n]=size(a);
            salida=m*n/tam_elemento;
        else
            salida=1;
        end
    end
end