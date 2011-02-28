
%Don't use special characters like á, é, ñ, n, etc.
%Respect all the special chars like ", ', \n, %f, etc.

string001='Este script debe usarse en el directorio raiz del proyecto';
string002="'Importar el kml'";
string003="'Ancho\ncarretera (m):'";
string004="'Espaciado\npaneles (m):'";
string005="'Fichero no encontrado'";
string006="'Crear rejilla'";
string007="'Elevar kmls'";
string008="'Leer rejilla'";
string009="'Ver\ndatos'";
string010="'Paso (m):'";
string011="'Tamanyo fichero\n(puntos):'";
string012="El procesamiento de este SON ha terminado";
string013="'Leer datos elevacion'";
string014="'Crear perfil en altura'";
string015="'Consolidar'";
string016="'Corregir terreno (opt)'";
string017="'Usar linea\ncentral'";
string018="'Factor de\nsuavizado:'";
string019="'Pendiente\nmaxima:'";
string020="'Ancho (m):'";
string021="'nn Paneles:'";
string022="'Crear el .geo'";
string023="'Forzar\nregularidad'";
string024="'Incluir limites\nde elevacion'";
string025="'Elevar la malla'";
string026="'Crear grid.hlg'";
string027="'Crear test.obj'";
string028="'Aceptar la malla'";
string029="'Crear muros'";
string030="'Crear puntos de ruptura'";
string031="'Trocear carretera'";
string032="'Crear el terreno'";
string033="'nn segmentos:'";
string034="'Mezcla con\nfondo'";
string035="'Dividir terreno\n con rejilla:'";
string036="'Crear Venue.xml'";
string037="' Los ficheros .dat estan en el directorio:'";
string038='Para comenzar:\nCopia el kml en el directorio s0_import\ny pulsa \"Importar el kml\"\n\nFor mor info Visit:\n http://www.plpcreation.tonsite.biz/\nhttp://forum.rallyesim.fr/viewtopic.php?f=51&t=3025&start=825\nhttp://btbtracks-rbr.foroactivo.com/t131-zaxxon-s-method-tutorial\nhttp://foro.simracing.es/bobs-track-builder/3815-1.html\nhttp://devtrackteam.solorally.it/viewforum.php?f=28';
string039='"La operacion no se pudo completar %f"';
string040='Operacion finalizada con exito';
string041='La operacion no se pudo completar';
string042='ficheros necesarios';
string043='La operacion fallo. Usa un factor de suavizado impar';
global string044='"AGR Dir\nencontrado"';
global string045='"lidar Dir\nencontrado"';
global string046='\nEncontrado"';
global string047='\nNO Encontrado"';
string048='anchors_carretera.mesh NO encontrado';
global string049='Ejecutando comando:   ';
string050='Edita pos_nodes.txt si quieres cambiar los puntos de division';
string051='Procesa los SONS y luego ejectuta join_geos en s1_mesh';
string052='"Notas copiloto"';
string053=['This button converts the kml to a list of track nodes with BTB format. \nOriginal elevation is ignored. These nodes have elevation 0m \n',...
'The width of the road has influence on the .geo mesh\nand also on the elevation profile'];
string054='This step reads a kml route and creates a list of BTB nodes with elevation 0m. Next steps will give elevation to the road';
string055=['This step gets elevation data for our project.\nElevation data must cover ALL the tracks of the project\n',...
'If you have elevation data files (.agr,lidar,.hgt,.flt) then you do not need this step.\n Otherwise you can use it to get elevation data from Google Earth.\n',...
'read raise_with_python.pdf before trying to use the -raise the kmls- button'];
string056='We read the gridXXX_relleno.kml files and create a file\n (called lamalla.mat)with all the elevation data gathered';
string057='We plot the elevation data (lamalla.mat)';
string058=['We create a grid of equispaced points that covers all the \nterrain enclosed by limits.kml. Those points are saved',...
'in gridXXX.kml files and we will give elevation to those files\n using Raise the kmls button. File size should be kept below 5000'];
string059='We give elevation to gridXXX.kml files\nResults are saved as gridXXX_relleno.kml files\nDo not use these button before reading raise_with_python.pdf';
string060='';
string061='';
string062='';
string063=['This step gets elevation data for our project.\nElevation data must cover all the terrain of the project',...
'If you have elevation data files (.agr,lidar,.hgt,.flt) then you do not need this step.\n Otherwise you can use it to get elevation data from Google Earth.\n',...
'read raise_with_python.pdf before trying to use the -raise- button'];;
string064='';
string065=['We read track coordinates and elevation data.\nWe also get terrain elevation values for the track coordinates\n',...
'For very detailed elevation data (grid spacing 1m) \nwe can use the centerline of the track as a reference. \n',...
'In a normal case (\>1m spacing), we use the road width to design its elevation profile. '];
string066=['This step determines the elevation profile of the track.\n','You can edit by hand the profile proposed by the scripts.\n',...
'When you finish editing you have press e and then ENTER on the octave text-mode window'];
string067='We accept the elevation profile for the track nodes.\n';
string068='This step gives elevation to the road usign available elevation data.';
string069=['Elevation data is modified using the track elevation profile.\n Click on Get Elevation Data button if you want to start again\n',...
' using the original elevation data. Otherwise you can click again on \nCreate Elevation Profile to create a track that fits better the new elevation data'];
string070=['We create anchors_carretera.geo, a gmsh file that\n contains a set of surfaces for the driveable zone. After this step\n',... 
'you have to edit the .geo file using gmsh (if case of a SON, your next step is S10_split)'];
string071=['This step creates a .geo file with the driveable terrain on both sides of the road.\nThe list of driveable surfaces can be found inside phys111.txt in case of not using multitrack.\n',...
'Your mesh must NOT exceed available elevation data, so it is always recommended to add the elevation data limits to your .geo.\n',...
'For special used of the scripts you may want to force the mesh to be regular.\n If you are not sure, do not select -force regular-.'];
string072='We use our elevation data to raise our anchors_carretera.msh\n';
string073='We have to change mesh nodes order to match tracks anchors ordering. It is a slow process.';
string074='In this step we give elevation to our terrain mesh using our elevation data';
string075='We create the protection walls so the car can not reach the non-driveable zone.';
string076=['We can create protection walls to avoid the car racing on the non-driveable zones\nThis step needs that the boundary has no gaps:\n',...
'there must be always a driveable triangle in touch with boundary. End-track surfaces are the main source of problems for this step.'];
string077='We create pacnotes for the main track';
string078='We split the track into segments using pos_nodes.txt info.\nExperience tells us that 1-1.5Km segments work ok. Bigger segments can make BTB work really slow';
string079='We create a set of split points for the track. Result is pos_nodes.txt.\n The user can edit pos_nodes.txt to fit his needs';
string080=['We transform our mesh into BTB terrain format. The mesh will be split into\n',...
'zones using the dimensions selected for the grid. Splitting is recommended to improve RBR performance.\n',...
'checking -Blend with background- terrain textures will be the result of blending\n a default texture with Background images.',...
'If you select this option BTB will refuse to open your Venue.xml\nunless it can find the .dds files for the background images'];
string081='This step creates the main blocks of the BTB project: the track segments and the terrain.\n For better BTB/RBR performance both should be splitted into smaller parts';
string082='This is the final step. We are creating the BTB project joining all the parts.\nDo not foget to add the WP.zip and good luck';
string083='In this step we create the Venue.xml, the final output of the process.\nIf you have background images, set the correct path for them (using always /),\notherwise just make sure you enter a non-existant path';
