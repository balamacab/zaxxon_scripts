function p_e(varargin)
if nargin==0
	partes_x=10;
	partes_z=10;
	mapear=0;
else
   [reg, prop] = parseparams(varargin);
   partes_x=reg(1,1);
   partes_x=partes_x{1};
   partes_z=reg(1,2);
   partes_z=partes_z{1};
   mapear=reg(1,3);
   mapear=mapear{1};
end 

procesar_elementstxt_mt(partes_x,partes_z,mapear);