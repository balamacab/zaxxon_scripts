function patron=busca_lazos(vector)
%[Sorted Index]=sort(vector(:,1)); %Elementos originales ordenados seg�n su coordenada x
Sorted=vector;
patron=ones(length(vector),1);

for h=1:length(vector)
    if mod(h,1000)==0
	    mensaje=sprintf('%.2f',h/length(vector));
	    display(mensaje);
    end
	%Localizamos las rectas que cruzan la vertical x=Sorted(h)
    xmenores=(vector(:,1)<=Sorted(h));   %Para cruzarla, la x de el punto inicial 
    xmayores=(vector(:,1)>=Sorted(h));   %y la del final deben estar en distintos lados de la vertical
    caso1=[xmenores(1:end-1)+xmayores(2:end)]'; %Los que la cruzan con el punto inicial a la izquierda
    caso2=[xmayores(1:end-1)+xmenores(2:end)]'; %Los que la cruzan con el punto inicial a la derecha
	
	segmentosimplicados=(caso1==2)+(caso2==2); %Los segmentos implicados son la uni�n de los dos casos anteriores

	segmentosimplicados=find(segmentosimplicados>0);

    %Para cada segmento que cruza x=Sorted(h) examinamos su posible cruce con todos los dem�s segmentos
    for t=1:length(segmentosimplicados)
		indh=segmentosimplicados(t);
		for g=1:t-1 %No comparamos dos veces la misma pareja, ni un segmento consigo mismo
			 indg=segmentosimplicados(g);
			 if abs(indh-indg)>1 %Ni iguales ni consecutivos			         
         			 [X0 Y0]=intersections([vector(indh,1) vector(indh+1,1)],[vector(indh,3)  vector(indh+1,3)],[vector(indg,1) vector(indg+1,1)],[vector(indg,3) vector(indg+1,3)]);
				tam=size(X0);
	            if tam(1)*tam(2)>0
	               patron(indg:indh)=0;
				   %display('Detectado');
	            end
			end	
	    end
    end
end

