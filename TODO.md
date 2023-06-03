## Plans
- [x] New infection set using points rather than individual Node2D for each infection node
- [x] Interactions between flashlight and new infection points
- [x] Lighting under infection points (possibly massive lightmap with occlusion tiles?)
- [x] Cleaned up item spawning spaghetti code
- [x] Redraw infection sprite
- [x] Add sound effects
- [x] Redo floor plan, including adding a first floor and basement
- [x] Implement hall area
- [ ] Implement new floor plan
- [ ] Re-redrawing infection sprite to allow for autotiling
- [x] Add shooting "light bullets"
- [x] Add light barriers (light cannot go past barriers)
- [ ] Change player flashlight to use raycasts instead of an area
- [x] Re-implement NPC scenes using inheritance
- [x] Dummy/invalid points: points not allowed to be spread to
- [ ] Better pathfinding (BFS, A*, etc.) while keeping randomness

##### Current issues:
- [x] After collecting an item, talking to an NPC acts like picking up an item and plays the accompanying sound effect
- [x] There is a slight delay in NPC processing when interacting with an NPC twice in a row, after the inventory closes. Possibly an issue with hitboxes.
    - it was a hitbox issue 



