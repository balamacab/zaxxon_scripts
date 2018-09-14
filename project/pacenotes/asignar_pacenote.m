function [Tipo indice_pn flag]=asignar_pacenote(girocentral,girototal);
%Cut 64
%Don't cut 32
%Long 1024
%Wideout 2
%Narrows 1
%Tightens 4
%Tightens bad 128
%Maybe 8192
        Tipo='-';
        flag=0;
	if abs(girocentral)>15
		if abs(girototal)>140 %Más de 140-----------------------------------
			if abs(girocentral)<80
				Tipo='Medium'; indice_pn=4; flag=1024;
			else
				Tipo='Hairpin'; indice_pn=1;
			end	
		else			
			if abs(girototal)>70 %Entre 70 y 140 -----------------------------------
				if abs(girocentral)> 55
                    Tipo='90'; indice_pn=2; 
                elseif abs(girocentral)>35
					Tipo='K'; indice_pn=3;	flag=1024;				
				else
                    Tipo='Medium' ;indice_pn=4; flag=1024;
				end
			else
				if abs(girototal)>35 %Entre 35 y 70  -----------------------------------
					if abs(girocentral)>35
						Tipo='K'; indice_pn=3;
					else
						Tipo='Medium'; indice_pn=4;
					end
				else
					if abs(girototal)>15 %Entre 15 y 35 -----------------------------------
						if abs(girocentral)>25
							Tipo='Medium'; indice_pn=4;
						else
							Tipo='Fast'; indice_pn=5;
						end
	        else
						if abs(girocentral)<7
              Tipo='-';indice_pn=0
            else
              if abs(girocentral)>11
                Tipo='Easy';indice_pn=6;
              else
                Tipo='Very Easy';indice_pn=7;
              end
            end	  
					end
				end
			end
		end
	else %Giro central menor que 15
      if abs(girocentral)<7
        Tipo='-';indice_pn=0
      else
        if abs(girocentral)>11
		      Tipo='Easy';indice_pn=6;
        else
          Tipo='Very Easy';indice_pn=7;
        end
      end
	end
end
