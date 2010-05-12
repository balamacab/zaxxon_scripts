function [pos1,pos2,pos3]=BTB_a_coor(a,c,b,mapeo)
%---
% Descargado de http://foro.simracing.es/bobs-track-builder/3815-tutorial-ma-zaxxon.html
%---
% Este código NO es software libre. Su uso implica la aceptación de las condiciones del autor,
% condiciones que explícitamente prohiben tanto la redistribución como su uso con fines comerciales.
% Asimismo queda prohibida la realización de cualquier modificación que no sea para estricto uso personal 
% y sin finalidad comercial.
% 
% El autor no acepta ninguna responsabilidad por cualquier daño resultante del uso de este código. 

    %pos1 es longitud 
    %pos2 es la altura
    %pos3 es latitud
    %y=y0+(x-x0)*(y1-y0)/(x1-x0)
    
	xinicial=mapeo(1);%2157.232; %mapeo(1)
	xfinal=mapeo(5);%1666.922;   %mapeo(5)
    zinicial=mapeo(2);%5137.749; %mapeo(2)
    zfinal=mapeo(6);%-3785.737;  %mapeo(6)
    %Estas son las coordenadas originales, que deben ser mapeadas con las
    %del BTB
    
    %x del BTB
	coordenadaxinicial=mapeo(3);%-105.037205228836; %mapeo(3)
	coordenadaxfinal=mapeo(7);%-105.042881979876; %mapeo(7)
    pos1=coordenadaxinicial+(a-xinicial)*(coordenadaxfinal-coordenadaxinicial)/(xfinal-xinicial);
    
    %z del BTB es la profundidad
	coordenadazinicial=mapeo(4);%38.9209304085051; %mapeo(4)
	coordenadazfinal=mapeo(8);%38.8405926230566;   %mapeo(8)
	pos3=coordenadazinicial+(b-zinicial)*(coordenadazfinal-coordenadazinicial)/(zfinal-zinicial);
    
    %y del BTB es la altura
    pos2=c;
    
end
