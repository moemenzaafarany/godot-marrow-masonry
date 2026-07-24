Coming from building smaller 1–3 scene projects into tackling a massive hybrid like *Stonehearth* with large-scale war, multiplayer, and body-part dynamics can feel like standing at the base of Mount Everest.

Because you want to build this natively using **Godot's built-in blocky primitives** (avoiding Blender) while keeping it customizable, modular, and networked, jumping straight into advanced mechanics will result in overwhelm.

Below is a structured, step-by-step roadmap to build *Marrow & Masonry* without burning out.

---

## 🏗️ The 5-Phase Project Roadmap

```
Phase 1: Basic Networked Sandbox 
   └── Spawn players & movement over ENet

Phase 2: Code-Based Modular Avatars 
   └── Build blocky humans in Godot without Blender

Phase 3: The Task Queue & Voxel Engine
   └── Let settlers mine/place blocks and pathfind

Phase 4: Combat, Body Parts & Morale
   └── Limb hitboxes, wound application, & AI panic

Phase 5: Scale to "Big War" Systems
   └── Optimization, squad AI, & massive battles

```

---

## Phase 1: Networked Foundation & Spawning (Week 1–2)

*Goal: Get two player instances standing on a flat ground plane and seeing each other move.*

* **Step 1: Network Manager Autoload**
* Create a global `NetworkManager.gd` using Godot’s `ENetMultiplayerPeer`.
* Create a basic host/join button UI scene to switch between hosting and connecting.


* **Step 2: Basic Player Avatar**
* Create a standard `CharacterBody3D` with a simple capsule or box mesh.
* Attach a `MultiplayerSynchronizer` to track `position` and `rotation`.
* Attach a `MultiplayerSpawner` in your root scene so the server automatically instantiates player nodes on connected clients.



---

## Phase 2: Procedural Voxel Humanoids (Week 3–4)

*Goal: Construct modular, customizable characters using Godot's built-in nodes—no Blender required.*

* **Step 1: Code-Generated Block Meshes**
* Construct a hierarchy using `Node3D` sockets (`Head`, `Torso`, `LeftArm`, `RightArm`, etc.).
* Attach standard `MeshInstance3D` nodes with standard box geometries (`BoxMesh`) as children of these sockets.


* **Step 2: Customization Resource**
* Create a custom resource (`CharacterAppearance.gd`) containing properties like `height`, `arm_length`, `skin_color`, `hair_style_index`.


* **Step 3: Procedural Scaler Script**
* Write a script that loops through the body parts and adjusts node scales dynamically.
* Update attached `Area3D` hitboxes programmatically to match the visually scaled box sizes.



---

## Phase 3: Voxel World & Settler Task Queue (Week 5–8)

*Goal: Dig blocks, build structures, and command basic AI.*

* **Step 1: Voxel World Plugin**
* Import **Voxel-Tools for Godot** (by Zylann). Using standard `StaticBody3D` block nodes will crash Godot when scaling up; chunk-based mesh generation is required.


* **Step 2: World Interactions**
* Implement networked RPC methods like `request_break_block(coords)` so clients send block destruction requests to the server.


* **Step 3: The Job/Task Queue**
* Create a global task manager where player clicks create task objects (e.g., `MiningTask`, `BuildingTask`).
* Implement basic AI pathfinding using Godot’s `NavigationAgent3D` or `AStar3D` grid to send idle settlers to task coordinates.



---

## Phase 4: Wounds, Dismemberment & Morale (Week 9–12)

*Goal: Replace standard HP with limb-based damage and psychological reactions.*

* **Step 1: Decoupled Health Components**
* Attach individual `HealthComponent` scripts to each body part node (`Head`, `LeftArm`, etc.).


* **Step 2: Limb Detachment System**
* When a specific body part's HP reaches zero:
1. Sever the node from the character skeleton.
2. Instantiate a temporary rigid body (`RigidBody3D`) with the same box mesh to fall and roll on the terrain.
3. Instantiate a blood particle effect at the socket joint.




* **Step 3: Morale Finite State Machine (FSM)**
* Add a simple calculation:

$$\text{Morale} = \text{Base Courage} - \text{Accumulated Pain} - \text{Nearby Friendly Deaths}$$


* If Morale drops below a threshold, override the settler's task queue state and switch their AI state to `Flee` or `Panic`.



---

## Phase 5: War Scale & Optimization (Week 13+)

*Goal: Scale combat up to dozens or hundreds of entities without performance lag.*

* **Step 1: Server Authoritative Logic Processing**
* Ensure calculations (wound logic, AI state checks) run **only on the server**. Clients should purely handle rendering and interpolation.


* **Step 2: Level of Detail (LOD) for AI**
* Disable fine-grained hitboxes for distant units, reverting them to simple single-capsule colliders until they get closer to combat zones.



---

## 🎯 What to Do Right Now (Your Next Immediate Step)

1. Open a blank Godot 4 project.
2. Build **Phase 1, Step 1**: Set up a simple scene with a host and join button, using ENet to connect two instances of your game together.
3. Don't worry about voxel terrain, AI, or swords yet—get the network connection working first!