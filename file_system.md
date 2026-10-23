# File system tutorial

## Naming
Name files and folders in lowercase snake_case only, per the Godot stylesheet.
Use plural names when applicable. ("npcs" not "npc", because there are multiple,
"npc_base.png" if there is only one base)

## Adding assets
If you are Nao, or otherwise adding assets made outside Godot, feel free to just
drop them into the "intake" folder and move on. Don't worry about anything else.

## Using assets
Firstly, DO NOT REFERENCE THE INTAKE FOLDER. If you want an asset from it, move
it to whatever the appropriate location is first.

Files are sorted by "conceptual item." All the NPC files are in npcs/
for example. If you wanted to add an image to use for NPCs, you would bring it
to npcs/example_image.png. If, later on, this system becomes too cluttered, (for
instance, if we get 1000 flower images), then we can reorganize just the 
relevant folders. The system is expandable.

Sometimes, a conflict can occur. For example, images of plants should go into
plants/... but the UI needs those images too, for planting. So where do they go?
 In these cases, do not put the images in both locations. Instead, consider the 
problem conceptually. The images for the plants are for the plants, the UI just 
has an *image* of the flower. Therefore, the images for the flowers go in 
flowers/(etc...), and the UI simply references that folder. The UI images folder 
would have like, pictures of buttons and stuff.
