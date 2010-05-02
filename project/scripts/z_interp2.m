function salida=z_interp2(rangox,rangoz,malla,px,pz)

method=2;   %2->Bicubic  1->Linear
if method==1
    salida=interp2(rangox,rangoz,malla,px,pz);
	return
end

salida=0*px;
pasos=round(length(px)/10);
for g=1:length(px)
   if mod(g,pasos)==0
	   display(sprintf('%.3f',g/length(px)));
   end
   posx=sum(px(g)>rangox); %Por encima de cuántos está -> su posición
   posz=sum(pz(g)>rangoz); %Por encima de cuántos está -> su posición
   %length(rangox)
   %posx
   %posz
   if (posx<=2)||(posz<2)||(posx>=length(rangox)-2)||(posz>=length(rangoz)-2)
        %disp('Linear')
        salida(g)=interp2(rangox,rangoz,malla,px(g),pz(g));
	else
	    %salida(g)=interp2(rangox,rangoz,malla,px(g),pz(g));
		
		submalla=malla(posz-1:posz+2,posx-1:posx+2);
		posicionx=(px(g)-rangox(posx))/(rangox(posx+1)-rangox(posx));
		posicionz=(pz(g)-rangoz(posz))/(rangoz(posz+1)-rangoz(posz));
		salida(g)=interpolacion_bicubica(submalla,posicionx,posicionz);
	end
end

function salida=interpolacion_bicubica (matriz,y,x) 

	 a(1,1) = matriz(2,2);
	 a(1,2) = matriz(2,3) - matriz(2,2)/2 - matriz(2,1)/3 - matriz(2,4)/6;
	 a(1,3) = matriz(2,1)/2 - matriz(2,2) + matriz(2,3)/2;
	 a(1,4) = matriz(2,2)/2 - matriz(2,1)/6 - matriz(2,3)/2 + matriz(2,4)/6;
	 a(2,1) = matriz(3,2) - matriz(2,2)/2 - matriz(1,2)/3 - matriz(4,2)/6;
	 a(2,2) = matriz(1,1)/9 + matriz(1,2)/6 - matriz(1,3)/3 + matriz(1,4)/18 + matriz(2,1)/6 + matriz(2,2)/4 - matriz(2,3)/2 + matriz(2,4)/12 - matriz(3,1)/3 - matriz(3,2)/2 + matriz(3,3) - matriz(3,4)/6 + matriz(4,1)/18 + matriz(4,2)/12 - matriz(4,3)/6 + matriz(4,4)/36;
	 a(2,3) = matriz(1,2)/3 - matriz(1,1)/6 - matriz(1,3)/6 - matriz(2,1)/4 + matriz(2,2)/2 - matriz(2,3)/4 + matriz(3,1)/2 - matriz(3,2) + matriz(3,3)/2 - matriz(4,1)/12 + matriz(4,2)/6 - matriz(4,3)/12;
	 a(2,4) = matriz(1,1)/18 - matriz(1,2)/6 + matriz(1,3)/6 - matriz(1,4)/18 + matriz(2,1)/12 - matriz(2,2)/4 + matriz(2,3)/4 - matriz(2,4)/12 - matriz(3,1)/6 + matriz(3,2)/2 - matriz(3,3)/2 + matriz(3,4)/6 + matriz(4,1)/36 - matriz(4,2)/12 + matriz(4,3)/12 - matriz(4,4)/36;
	 a(3,1) = matriz(1,2)/2 - matriz(2,2) + matriz(3,2)/2;
	 a(3,2)  = matriz(1,3)/2 - matriz(1,2)/4 - matriz(1,1)/6 - matriz(1,4)/12 + matriz(2,1)/3 + matriz(2,2)/2 - matriz(2,3) + matriz(2,4)/6 - matriz(3,1)/6 - matriz(3,2)/4 + matriz(3,3)/2 - matriz(3,4)/12;
	 a(3,3)  = matriz(1,1)/4 - matriz(1,2)/2 + matriz(1,3)/4 - matriz(2,1)/2 + matriz(2,2) - matriz(2,3)/2 + matriz(3,1)/4 - matriz(3,2)/2 + matriz(3,3)/4;
	 a(3,4)  = matriz(1,2)/4 - matriz(1,1)/12 - matriz(1,3)/4 + matriz(1,4)/12 + matriz(2,1)/6 - matriz(2,2)/2 + matriz(2,3)/2 - matriz(2,4)/6 - matriz(3,1)/12 + matriz(3,2)/4 - matriz(3,3)/4 + matriz(3,4)/12;
	 a(4,1) = matriz(2,2)/2 - matriz(1,2)/6 - matriz(3,2)/2 + matriz(4,2)/6;
	 a(4,2) = matriz(1,1)/18 + matriz(1,2)/12 - matriz(1,3)/6 + matriz(1,4)/36 - matriz(2,1)/6 - matriz(2,2)/4 + matriz(2,3)/2 - matriz(2,4)/12 + matriz(3,1)/6 + matriz(3,2)/4 - matriz(3,3)/2 + matriz(3,4)/12 - matriz(4,1)/18 - matriz(4,2)/12 + matriz(4,3)/6 - matriz(4,4)/36;
	 a(4,3) = matriz(1,2)/6 - matriz(1,1)/12 - matriz(1,3)/12 + matriz(2,1)/4 - matriz(2,2)/2 + matriz(2,3)/4 - matriz(3,1)/4 + matriz(3,2)/2 - matriz(3,3)/4 + matriz(4,1)/12 - matriz(4,2)/6 + matriz(4,3)/12;
	 a(4,4) = matriz(1,1)/36 - matriz(1,2)/12 + matriz(1,3)/12 - matriz(1,4)/36 - matriz(2,1)/12 + matriz(2,2)/4 - matriz(2,3)/4 + matriz(2,4)/12 + matriz(3,1)/12 - matriz(3,2)/4 + matriz(3,3)/4 - matriz(3,4)/12 - matriz(4,1)/36 + matriz(4,2)/12 - matriz(4,3)/12 + matriz(4,4)/36;

	 x2 = x * x;
	 x3 = x2 * x;
	 y2 = y * y;
	 y3 = y2 * y;

	salida= a(1,1) + a(1,2) * y + a(1,3) * y2 + a(1,4) * y3 +...
	       a(2,1) * x + a(2,2) * x * y + a(2,3) * x * y2 + a(2,4) * x * y3 +...
	       a(3,1) * x2 + a(3,2)  * x2 * y + a(3,3)  * x2 * y2 + a(3,4)  * x2 * y3 +...
	       a(4,1) * x3 + a(4,2) * x3 * y + a(4,3) * x3 * y2 + a(4,4) * x3 * y3;
