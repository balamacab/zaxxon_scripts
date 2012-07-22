
%N'utilisez pas des caracteres speciaux tels que á, e, ñ, n, etc.
%Respectez la ponctuation speciale telle que ", ', \n, %f, etc.

string001='Ce script est a utiliser uniquement dans le dossier racine de votre projet';

string002="'Importer un kml'";
string003="'Largeur\nRoute (m):'";
string004="'Dimension\nPolys (m):'";
string005="'Fichier introuvable'";
string006="'Realiser une grille'";
string007="'Attribuer l altitude aux KMLs'";
string008="'Lire la grille'";
string009="'Vue\nData'";
string010="'Espacement de la grille (m):'";
string011="'Nombre de points dans le fichier \n(ex.5000):'";
string012="L analyse de cet enfant est terminee";
string013="'Lire les donnees d elevation'";
string014="'Creer un profile d elevation'";
string015="'Confirmer'";
string016="'Fix terrain (opt)'";
string017="'Utiliser\nligne centrale'";
string018="'Facteur de\nLissage:'";
string019="'Ecart\nlimit:'";
string020="'Largeur (m):'";
string021="'Polys :'";
string022="'Creer le fichier .geo'";
string023="'Diviser les\nsurfaces'";
string024="'Inclure\nles limites d levation'";
string025="'Appliquer l elevation au maillage'";
string026="'Creer sasplanet.hlg'";
string027="'Creer test.obj'";
string028="'Accepter le mesh'";
string029="'Creer les murs'";
string030="'Creer des points de division'";
string031="'Divisier la route'";
string032="'Creer le terrain'";
string033="'# segments:'";
string034="'Fusionner avec\nArriere Plan'";
string035="'Diviser le terrain\navec une grille:'";
string036="'Creer Venue.xml'";
string037="' Les fichiers .dat\nsont dans le dossier:'";
string038='Pour commencer:\nCopier votre trace kml dans le dossier s0_import\net appuyez sur le bouton\"Importer un kml\" \n\nPour plus d informations visitez:\nhttp://plpcreation.tonsite.biz\nhttp://forum.rallyesim.fr/viewtopic.php?f=51&t=3025&start=825\nhttp://btbtracks-rbr.foroactivo.com/t131-zaxxon-s-method-tutorial\nhttp://foro.simracing.es/bobs-track-builder/3815-1.html\nhttp://devtrackteam.solorally.it/viewforum.php?f=28';
string039='"L operation a echouee  %f"';
string040='L operation a reussi';
string041='L operation a echouee';
string042='fichier necessaire';
string043='L operation a echouee. Utiliser un ancien facteur de lissage';
global string044='"Repertoire AGR\nTrouve"';
global string045='"Repertoire lidar\nTrouve"';
global string046='\nTrouve"';
global string047='\nIntrouvable"';
string048='anchors_carretera.mesh introuvable';
global string049='Commande en cours:   ';
string050='Vous pouvez editer le fichier pos_nodes.txt pour changer les points de division';
string051='Utilisez mallado_regular avec les fichiers enfants et ensuite executer join_geos a l interieur de s1_mesh';
string052='"Creer pacenotes"';
string053=['Ce bouton convertit un kml en une liste de suite de points au format BTB. \nL altitude original est ignoree. Ces points sont a une altitude de 0m \n',... 
'La largeur de la route a une influence sur le maillage .geo\net egalement sur le profile d elevation'];
string054='Cette etape lis le fichier kml convertit en une liste de suite de points au format BTB avec l altitude a 0m. La prochaine etape va attribuer l altitude a la route';
string055=['Cette etape va acquerir les donnees d elevation pour notre projet.\nLes donnees d elevation doivent couvrir toute la zone du projet\n',...
'Si vous avez les fichiers de donnees d elevation (.agr,lidar,.hgt,.flt) alors vous n avez pas besoin de faire cette etape.\n Sinon vous pouvez l utiliser pour avoir les donnees d elevation depuis Google Earth.\n',...
'Reportez vous au section V.1 du fichier pdf d aide avant d essayer d utiliser le bouton -Attribuer l altitude aux KMLs-'];
string056='On lis les fichiers gridXXX_relleno.kml et on cree un fichier \n (appele lamalla.mat) qui contient toutes les donnees d elevation reunis';
string057='On trace les donnees d altitude (lamalla.mat)';
string058=['On cree une grille avec des points equidistants qui recouvre l ensemble du \nterrain delimite par le fichier limits.kml. Ces points sont sauvegardes',...
'dans les fichiers gridXXX.kml et nous allons leurs attribuer l altitude\n en utilisant le bouton Attribuer l altitude aux KMLs. Les fichiers DOIVENT contenir MOINS de 5000 points (conseille 1000)'];
string059='On attribue l altitude aux fichiers gridXXX.kml\nLes resultats sont sauvegardes dans les fichiers gridXXX_relleno.kml\nN UTILISEZ PAS CE BOUTON AVANT D AVOIR LU LE SECTION V.1 DU FICHIER PDF D AIDE\n present dans le dossier Documentation de votre projet';
string060='';
string061='';
string062='';
string063=['Cette etape attribue les donnees d elevation pour notre projet.\nLes donnees d elevation doivent couvrir l ensemble du projet',...
'Si vous avez des donnees d elevation de type (.agr,lidar,.hgt,.flt) alors vous n avez pas besoin de cette etape.\n Sinon vous pouvez l utiliser pour avoir les donnees d elevation depuis Google Earth.\n',...
'Reportez vous au section V.1 du fichier pdf d aide avant d essayer d utiliser le bouton -Attribuer l altitude aux KMLs-'];;
string064='';
string065=['On lis les coordonnees de la route et des donnees d elevation.\nOn recupere egalement les donnees d elevation du terrain pour les coordonnees de la route.\n',...
'Pour des donnees d elevation tres detaillees (espacement de grille de 1m) \non peut utiliser la ligne centrale de la route en tant que reference.\n',...
'Dans un cas normal (espacement \>1m), on utilise la largeur de route pour dessiner son profile d elevation. '];
string066=['Cette etape applique un profile d elevation a la route.\n','Vous pouvez editer ce profile a la main.\n',...
'Lorsque vous avez finit de l editer dans la console de commande Octave vous devez appuyez sur e et entree'];
string067='On accepte le profile d elevation pour les de points de la route.\n';
string068='Cette etape eleve la route en utilisant les donnees d elevation disponible.';
string069=['Les donnees d elevation sont modifiees en utilisant le profile d elevation de la route.\n Cliquez sur le bouton Lire les donnees d elevation si vous voulez recommencer\n',...
' en utilisant le profile d elevation original. Sinon vous pouvez re cliquer sur \nCreer un profile d elevation pour faire une route qui suit mieux les nouvelles donnees d elevation'];
string070=['On cree le fichier anchors_carretera.geo, un fichier gmsh qui\n contient la definition des surfaces pour la zone roulable. Apres cette etape\n',... 
'vous devez editer le fichier .geo en utilisant gmsh (dans le cas d un fichier ENFANT, votre prochaine etape est S10_split)'];
string071=['Cette etape creee un fichier .geo avec le terrain roulable de chaque cotes de la route.\nLa liste des surfaces roulables peut etre trouver dans le fichier phys111.txt dans le cas ou vous n utilisez pas un projet multi route.\n',...
'Votre maillage NE DOIT PAS depasser la taille des donnnees d elevation disponible, ainsi il est recommande de toujours ajouter la limite des donnees d elevation disponible a votre .geo.\n',...
'Pour des usages particuliers des scripts, vous voudrez peut etre forcer le maillage a etre regulier.\n Si vous n etes pas sur, ne cochez pas la case -Forcer regulier-.'];
string072='On utlise nos donnees d elevation pour elever notre anchors_carretera.msh\n';
string073='On doit changer l ordre des points du maillage pour correspondre aux points d ancrage de la route. C est un procede long.';
string074='A cette etape, on attribue l altitude a notre terrain en utilisant nos donnees d elevation.';
string075='On cree les murs de protection ainsi la voiture ne pourra pas atteindre la zone non-roulable.';
string076=['On peut creer des murs de protection pour empecher la voiture de rouler sur une zone non-roulable'];
string077='On cree le pacenote pour la route principale';
string078='On scinde la route en segments en utilisant le fichier info.\nLes tests nous ont appris qu utiliser des segments de 1-1.5Km marche bien. Des segments plus longs peuvent rendre BTB vraiment tres lent.';
string079='On cree une liste des points de division de la route. Le resultat est dans le fichier pos_nodes.txt.\n Vous pouvez l editer pour le faire correspondre a vos besoins';
string080=['On transforme notre maillage au format terrain de BTB. Le maillage va maintenant etre divise en\n',...
'zones avec les dimensions utilisees pour la grille. La division est recommandee pour augmenter les perfomances dans RBR.\n',...
'Coche -Fusionner avec l arriere plan- la texture du terrain sera le resultat de la fusion\n de la texture par defaut avec les images d arriere plan.\n',...
'Si vous selectionne cette option, BTB refusera d ouvrir votre Venue.xml\ntant qu il ne trouvera pas les fichiers .dds pour l arriere plan\n',...
'If you want blending select now the same grid dimensions you used with SASPLanet'];
string081='Cette etape cree les blocs principaux du projet BTB : les segments de route et le terrain.\n Pour de meilleure performance sous BTB/RBR, les deux doivent etre decoupes en de petites parties';
string082='Ceci est l etape finale. Nous allons creer le projet BTB en recollant toutes les parties.\n N oubliez pas d ajouter le fichier WP.zip dans le dossier Xpack de votre projet BTB et Bonne Chance';
string083='A cette etape on cree le fichier Venue.xml.\n Si vous avez des images d arriere plan, definissez correctement le chemin qui permet d y acceder (utilisez toujours /), \nsinon assurez vous juste d entree un chemin non existant';
