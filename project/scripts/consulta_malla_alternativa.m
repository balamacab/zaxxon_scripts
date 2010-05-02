function altura=consulta_malla_alternativa(x,z,datax,datay,dataz,radio)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código.

altura=x'*0;
datay=datay';

a=radio*cos(1.266);
b=radio*sin(1.266);
for h=1:length(x)
    fprintf(1,'%.3f\n',h/length(x));
    if radio>3
        %h
        punto1=[x(h) z(h)]+[a b];
        punto2=[x(h) z(h)]+[b -a];
        punto3=[x(h) z(h)]+[-a -b];
        punto4=[x(h) z(h)]+[-b a];
        distancias1=sqrt((punto1(1)-datax).^2+(punto1(2)-dataz).^2);
        distancias2=sqrt((punto2(1)-datax).^2+(punto2(2)-dataz).^2);
        distancias3=sqrt((punto3(1)-datax).^2+(punto3(2)-dataz).^2);
        distancias4=sqrt((punto4(1)-datax).^2+(punto4(2)-dataz).^2);

        [valor1,pos1]=min(distancias1);
        [valor2,pos2]=min(distancias2);
        [valor3,pos3]=min(distancias3);
        [valor4,pos4]=min(distancias4);

        distancia1=sqrt((x(h)-datax(pos1)).^2+(z(h)-dataz(pos1)).^2);
        distancia2=sqrt((x(h)-datax(pos2)).^2+(z(h)-dataz(pos2)).^2);
        distancia3=sqrt((x(h)-datax(pos3)).^2+(z(h)-dataz(pos3)).^2);
        distancia4=sqrt((x(h)-datax(pos4)).^2+(z(h)-dataz(pos4)).^2);

        sumdistancias=distancia1+distancia2+distancia3+distancia4;
        if sumdistancias==0
            display('?');
        end
        
        %Comprobamos si alguno de los puntos usados para el filtrado es muy
        %próximo al punto cuya altura queremos
        
        r_cercania=1;
        if distancia1<r_cercania
            altura(h)=datay(pos1);
        else
            if distancia2<r_cercania
                altura(h)=datay(pos2);
            else
                if distancia3<r_cercania
                    altura(h)=datay(pos3);
                else
                    if distancia4<r_cercania
                        altura(h)=datay(pos4);
                    else          
                        promedioaltura=datay(pos1)*(1-distancia1/sumdistancias)+datay(pos2)*(1-distancia2/sumdistancias)+datay(pos3)*(1-distancia3/sumdistancias)+datay(pos4)*(1-distancia4/sumdistancias);
                        promedioaltura=promedioaltura/3;%(1-a/(a+b+b))+(1-b/(a+b+c))+(1-c/(a+b+c)) suma 3-1=2
                        altura(h)=promedioaltura;
                    end
                end
            end
        end
    else
        distancias1=sqrt((x(h)-datax).^2+(z(h)-dataz).^2);
        [valor1,pos1]=min(distancias1);
        altura(h)=datay(pos1);
    end
end
altura=altura';
end


        
