
%Don't use special characters like á, é, ñ, n, etc.
%Respect all the special chars like ", ', \n, %f, etc.

string001='Use this script only on the root folder of the project';
string002="'Import the kml'";
string003="'Road\nwidth (m):'";
string004="'Panel\nspacing (m):'";
string005="'File not found'";
string006="'Make Grid'";
string007="'Raise Kmls'";
string008="'Read Grid'";
string009="'Plot\nData'";
string010="'Step (m):'";
string011="'File size\n(points):'";
string012="Processing of this SON has finished";
string013="'Read Elevation Data'";
string014="'Create Elevation Profile'";
string015="'Consolidate'";
string016="'Fix terrain (opt)'";
string017="'Use\ncenterline'";
string018="'Smooth\nFactor:'";
string019="'Slope\nlimit:'";
string020="'Width (m):'";
string021="'Panels:'";
string022="'Create .geo'";
string023="'Split\nsurfaces'";
string024="'Include\nElevation Limits'";
string025="'Give Elevation to the mesh'";
string026="'Create sasplanet.hlg'";
string027="'Create test.obj'";
string028="'Accept the mesh'";
string029="'Create walls'";
string030="'Create split points'";
string031="'Split the track'";
string032="'Create the terrain'";
string033="'# segments:'";
string034="'Blend with\nBackground'";
string035="'Split terrain\nwith grid:'";
string036="'Create Venue.xml'";
string037="'.dat files are in dir:'";
string038='To start:\nCopy your kml to the s0_import folder\nand press \"Import the kml\" button\n\nFor more info Visit:\nhttp://plpcreation.tonsite.biz\nhttp://forum.rallyesim.fr/viewtopic.php?f=51&t=3025&start=825\nhttp://btbtracks-rbr.foroactivo.com/t131-zaxxon-s-method-tutorial\nhttp://foro.simracing.es/bobs-track-builder/3815-1.html\nhttp://devtrackteam.solorally.it/viewforum.php?f=28';
string039='"Operation failed %f"';
string040='Operation Successful';
string041='Operation Failed';
string042='files needed';
string043='Operation Failed. Use an odd smoothing factor';
global string044='"AGR Dir\nFound"';
global string045='"lidar Dir\nFound"';
global string046='\nFound"';
global string047='\nNOT Found"';
string048='anchors_carretera.mesh NOT found';
global string049='Running command:   ';
string050='You can edit pos_nodes.txt to change the split points';
string051='Process the sons with mallado_regular and then run join_geos inside s1_mesh';
string052='"Create pacenotes"';
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
string059='We give elevation to gridXXX.kml files\nResults are saved as gridXXX_relleno.kml files\nDo not use this button before reading raise_with_python.pdf';
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
string076=['We can create protection walls to avoid the car racing on the non-driveable zones'];
string077='We create pacnotes for the main track';
string078='We split the track into segments using pos_nodes.txt info.\nExperience tells us that 1-1.5Km segments work ok. Bigger segments can make BTB work really slow';
string079='We create a set of split points for the track. Result is pos_nodes.txt.\n The user can edit pos_nodes.txt to fit his needs';
string080=['We transform our mesh into BTB terrain format. The mesh will be split into\n',...
'zones using the dimensions selected for the grid. Splitting is recommended to improve RBR performance.\n',...
'Checking -Blend with background- terrain textures will be the result of blending\n a default texture with Background images.\n',...
'If you select this option BTB will refuse to open your Venue.xml\n unless it can find the .dds files for the background images\n',...
'If you want blending select now the same grid dimensions you used with SASPLanet'];
string081='This step creates the main blocks of the BTB project: the track segments and the terrain.\n For better BTB/RBR performance both should be splitted into smaller parts';
string082='This is the final step. We are creating the BTB project joining all the parts.\nDo not forget to add the WP.zip and good luck';
string083='In this step we create the Venue.xml, the final output of the process.\nIf you have background images, set the correct path for them (using always /),\notherwise just make sure you enter a non-existant path';
