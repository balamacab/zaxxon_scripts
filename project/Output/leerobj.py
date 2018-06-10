import os
import bpy

full_path_to_directory = os.path.join('/tmp/project', 'Output')

# get list of all files in directory
file_list = os.listdir(full_path_to_directory)

# reduce the list to files ending in 'obj'
# using 'list comprehensions'
obj_list = [item for item in file_list if item[-4:] == '.obj']
#obj_list = [item for item in file_list if item[-7:] == '_01.obj']

# loop through the strings in obj_list.



bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()
for item in obj_list:
    full_path_to_file = os.path.join(full_path_to_directory, item)
    bpy.ops.import_scene.obj(filepath=full_path_to_file)


            