function [pos1,pos2,pos3]=coor_a_BTB(a,b,c,mapeo)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este c�digo NO es software libre. Su uso implica la aceptaci�n de las condiciones del autor,
% condiciones que expl�citamente prohiben tanto la redistribuci�n como su uso con fines comerciales.
% Asimismo queda prohibida la realizaci�n de cualquier modificaci�n que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier da�o resultante del uso de este c�digo.

    %pos1 es horizontal (x)
    %pos2 es la altura (y)
    %pos3 es profundidad (Z)
    %a es longitud
    %b es latitud
    %c es altura sobre el nivel del mar
    %y=y0+(x-x0)*(y1-y0)/(x1-x0)
    
    %Estos valores est�n bien seguro
	xinicial=mapeo(1);%2157.232;
	xfinal=mapeo(5);%1666.922;
    zinicial=mapeo(2);%5137.749;
    zfinal=mapeo(6);%-3785.737;
    %Estas son las coordenadas originales, que deben ser mapeadas con las
    %del BTB
    %x del BTB
	coordenadaxinicial=mapeo(3);%-105.037205228836;
	coordenadaxfinal=mapeo(7);%-105.042881979876;
    pos1=xinicial+(a-coordenadaxinicial)*(xfinal-xinicial)/(coordenadaxfinal-coordenadaxinicial);
    %z del BTB es la profundidad
	coordenadazinicial=mapeo(4);%38.9209304085051;
	coordenadazfinal=mapeo(8);%38.8405926230566;
	pos3=zinicial+(b-coordenadazinicial)*(zfinal-zinicial)/(coordenadazfinal-coordenadazinicial);
    %y del BTB es la altura
   	pos2=c;
end


