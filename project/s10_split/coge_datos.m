[numero_padres caminos]=look_for_father_or_sons('..\father.txt',1);
if numero_padres==0 
   system('copy ..\s4_terrain\salida\elements.txt . 2>NUL')
   system('copy ..\s6_hairpins\salida\nodos_conaltura.txt . 2>NUL')
end
system('copy ..\Venue\nodos.mat . 2>NUL');
system('copy ..\Venue\porcentajes.mat . 2>NUL');

message(14);
