# Ghost Busters
Demo project for the course "Real-Time Rendering" at the TU Wien
Created by Victor Mittermair and Philipp Hochhauser

<video controls src="assets/video-ghostbusters.mp4" title="Title"></video>
https://github.com/xHotch/GhostBusters/blob/master/assets/video-ghostbusters.mp4
# Controls
- Enter : Restart the scene.
- F1 : Toggle Wireframe rendering.
- F2 : Toggle backface culling.
- F3 : Toggle FPS counter.
- F4: Toggle Omnidirectional Shadow Mapping.
- F5: Toggle Volumetric Lighting.
- F6 : Toggle normal mapping.
# Technical Basis
We use the C++/OpenGL framework from CG course from SS 2021 Cough of Duty:
Covid Mode by Victor and his partner for the course Georg. Following libraries were
used:
- irrKlang [1]
- GLEW [2]
- EnTT [3]
- Bullet [4]
- assimp[5]
In the Resources folder, there is a settings.ini file where the resolution can be changed.
1
# Development Status
We have finished implementing following effects: Volumetric Lighting for Pointlights,
Omnidirectional Shadows with PCF. Not all pointlights have volumetric lighting, to
lower computational cost.
# List of Effects
## Mandatory Effects
- Omnidirectional Shadowmaps [6]

- Volumetric lighting [7, 8]
## Optional Effects
- Normal mapping
- Environment mapping
- Shadow mapping with percentage-closer filtering
# Assets
We have used the following assets:
- Abandoned House 3D Model [9]
- Background Music [10]
- Spooky tree [11]
- Lantern [12]
# Hardware
We have tested our scene on an Nvidia GTX 1080/1060 6GB as well as an Nvidia RTX
3060Ti card

# References
[1] “irrKlang - audio and sound library for C++, C# and .NET.”
https://www.ambiera.com/irrklang [Last Accessed 2022-10-12].

[2] “Glew: The opengl extension wrangler library.” https://glew.sourceforge.net/.
(Accessed on 11/26/2022).


[3] M. Caini, “Gaming meets modern c++ - a fast and reliable entity component system
(ecs).” https://github.com/skypjack/entt [Last accessed: 2022-10-12].

[4] “Bullet Real-Time Physics Simulation — Home of Bullet and PyBullet: Physics
simulation for games, visual effects, robotics and reinforcement learning..”
https://pybullet.org/wordpress/ [Last Accessed: 2022-10-12].

[5] “assimp/assimp: The official open-asset-importer-library repository. loads 40+ 3d-
file-formats into one unified and clean data structure..” https://github.com/
assimp/assimp. (Accessed on 11/26/2022).

[6] A. Cech, “Revision cource: Omnidirectional shadows,” TU Vienna, 2021.

[7] A. Cech, “Revision cource: Volumetric lighting,” TU Vienna, 2021.

[8] B. lomiej Wronski, “Volumetric fog and lighting,” GPU Pro 360, 2018.

[9] “Low-poly furnished abandoned house - download free 3d model
by neokg (@neokg) [ab6c142].” https://sketchfab.com/3d-models/
low-poly-furnished-abandoned-house-ab6c142e1c494c8e84dd82c852138501.
(Accessed on 01/13/2023).

[10] “Royalty free background music downloads - fesliyan studios.” https://www.
fesliyanstudios.com/. (Accessed on 11/26/2022).

[11] “Spooky tree - download free 3d model by marissa menlove
(@rissymenlove) [3f05064].” https://sketchfab.com/3d-models/
spooky-tree-3f050640e5d245ccb458aa5184f241e7. (Accessed on 01/07/2023).

[12] “Lantern - download free 3d model by linsort (@linsort) [24c99e7].” https:
//sketchfab.com/3d-models/lantern-24c99e7b17774718a0b0b793a8c11ede.
(Accessed on 01/13/2023).
3
