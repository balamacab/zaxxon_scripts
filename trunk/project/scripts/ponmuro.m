function ponmuro(murox,muroy,muroz)

    rango=(1:length(murox));
    [s1,s2]=size(rango);if (s2<s1) rango=rango.';end
    [s1,s2]=size(murox);if (s2<s1) murox=murox.';end
    [s1,s2]=size(muroy);if (s2<s1) muroy=muroy.';end
    [s1,s2]=size(muroz);if (s2<s1) muroz=muroz.';end

    offs=length(rango);
    fid=fopen('salida/nodosmuroizdo.txt','w');
    fprintf(fid,'%d %f %f %f\n',[rango' murox' muroy' muroz']');
    fprintf(fid,'%d %f %f %f\n',[(rango+offs)' murox' muroy' (muroz+4)']'); %4 metros de alto
    fclose(fid);

    dmuro=sqrt(sum(diff(murox').^2+diff(muroy').^2,2));
    dmuro_acumulada=cumsum([0; dmuro])/10;
    triangulos=[]
    for h=1:length(murox)-1;
        triangulos= [triangulos; h h+1 h+offs];
        triangulos= [triangulos; h+offs h+1 h+offs+1];
        murou(h)=dmuro_acumulada(h);
        murou(h+offs)=dmuro_acumulada(h);
        murov(h)=0;
        murov(h+offs)=1;
    end
    murou(offs)=dmuro_acumulada(offs);
    murou(offs+offs)=dmuro_acumulada(offs);
    murov(offs)=0;
    murov(offs+offs)=1;

    fid=fopen('salida/elementsmuroizdo.txt','w');
    fprintf(fid,'%d 2 2 55 0 %d %d %d  \n',[(1:longitud(triangulos,3))' triangulos ]');%zona 55, por poner algo
    fclose(fid);
    
   function salida=longitud(a,tam_elemento)
        if isempty(a)==0
            [m,n]=size(a);
            salida=m*n/tam_elemento;
        else
            salida=1;
        end
    end
end