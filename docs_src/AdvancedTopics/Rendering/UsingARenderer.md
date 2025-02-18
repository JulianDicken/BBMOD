# Using a renderer
In the [Quickstart guide](./QuickstartGuide.html) you have learnt that you can
quickly get models onto the screen using the [submit](BBMOD_Model.submit) method.
While this works just fine, it is not the recommended approach, as it does not
allow you to utilize the BBMOD library to its maximum potential. For this you
should use the method `render` instead.

## Method render
What [render](./BBMOD_Model.render.html) does is that it only puts
[render commands](./BBMOD_RenderCommand.html) into separate
[render queues](./BBMOD_BaseMaterial.RenderCommands.html) (one for each used material),
which can be then traversed and executed multiple times, using a different shader,
different configuration, different render target (like off-screen surface) etc.

Method `render` takes exactly the same arguments as `submit`, so it is easy to
switch from one to another. Additionally, since `render` does not draw the model
right away (and so it does not immediately apply materials), you do not have to
(and you should not) call [bbmod_material_reset](./bbmod_material_reset.html)
before and after `render`.

For example

```gml
/// @desc Draw event
matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, 1, 1, 1));
bbmod_material_reset();
model.submit();
bbmod_material_reset();
```
becomes

```gml
/// @desc Draw event
matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, 0, 1, 1, 1));
model.render();
```

The thing that handles traversal and execution of render commands is called a
renderer.

## Renderer
As stated above, when you switch to using method `render`, you need to create
a [renderer](./BBMOD_Renderer.html) (defined in Rendering/Renderer submodule),
which then picks up the created render commands and executes them. We recommend
you to create a renderer in a special controller object like `OMain`, `ORenderer`
or `OGameController`, based on your likings.

```gml
/// @desc Create event
renderer = new BBMOD_Renderer();

/// @desc Step event
renderer.update(delta_time);

/// @desc Draw event
// If you are using a camera, do not forget to apply it here, otherwise the
// models will not be rendered from its perspective!
OPlayer.camera.apply();
// This is what actually executes the render commands:
renderer.render();

/// @desc Clean Up event
renderer.destroy();
```

Please note that the controller object should execute its draw event *after* all
render commands are created! To ensure this, you can for example place it into
a special layer with the lowest `depth`.

At this point, your game should look exactly the same as when you used `submit`.

## Renderer configuration
Now, when you have got your game running using a renderer, you can configure the
renderer further to for example change the resolution scale (render the game at
a smaller resolution than the window to increase FPS), enable rendering of
dynamic shadows or enable various post-processing effects. There should be a
dedicated section for each one of these, but to give you an example:

```gml
/// @desc Create event
renderer = new BBMOD_Renderer();
// Enable control over the application surface
renderer.UseAppSurface = true;
// Enable post-processing effects (requires UseAppSurface)
renderer.EnablePostProcessing = true;
// Configure strength of chromatic aberration post-processing effect
renderer.ChromaticAberration = 2.0;
// Configure strength of vignette post-processing effect
renderer.Vignette = 1.5;
// Enable fast approximate anti-aliasing (requires Rendering/FXAA submodule)
renderer.Antialiasing = BBMOD_EAntialiasing.FXAA;

/// @desc Post-Draw event
// When UseAppSurface is enabled, you need to call this to draw the application
// surface on screen!
renderer.present();
```

For the full list of renderer's properties, please refer to its
[documentation](./BBMOD_Renderer.html).
