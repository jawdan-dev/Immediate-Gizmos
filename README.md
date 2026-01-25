# Immediate Gizmos
Immediate mode gizmos for all to use!

## Usage

ImmediateGizmos is used with calls through the `ImmediateGizmos` namespace.
`ImmediateGizmos` features numerous line-based drawing methods which can be called with `ImmediateGizmos.line*(...)`.

```gdscript
func _process(_delta) -> void:
	# Simple line draw!
	ImmediateGizmos.line(Vector3.ZERO, Vector3.RIGHT, Color.RED);
	ImmediateGizmos.line(Vector3.ZERO, Vector3.UP, Color.GREEN);
	ImmediateGizmos.line(Vector3.ZERO, Vector3.FORWARD, Color.BLUE);
```

This usage is similar to Unity's `Gizmos`. However, one major key difference is where ImmediateGizmos can be used.
ImmediateGizmos can be used during either the `_process` or `_physics_process` loops and any subsequently called functions.
This allows an on-demand usage without having to breakout into specific a `OnDrawGizmos` function.

### State

#### Color

Extra features, such as setting a *color* globally with `ImmediateGizmos.color = ...`, before any calls to easily reuse a common state, in this case *color*, all subsequent gizmo calls.

```gdscript
# Set color globally
ImmediateGizmos.color = Color.YELLOW;
ImmediateGizmos.lineCapsule(Vector3(0, 0, -2.0), 0.5, 2.0);
```

#### Transform

Additionally, a *transform* can be set globally for all subsequent gizmo calls with `ImmediateGizmos.transform = ...`.

```gdscript
for i : float in range(3):
	# Set a global transform!
	var pos := Vector3(0.0, i, 2.0);
	var rot := Basis.from_euler(Vector3(0.0, TAU * 0.1 * i, 0.0));
	ImmediateGizmos.transform = Transform3D(rot, pos);
	#
	ImmediateGizmos.color = [ Color.MAGENTA, Color.RED, Color.ORANGE ][i];
	ImmediateGizmos.lineCube(Vector3.ZERO, 0.5);
```

This can further be used to draw gizmos in the local space of a *node* with the following:
```gdscript
ImmediateGizmos.transform = node.transform;
```

#### Cleanup

Once all local draw operations and state changes have been performed, you can call `ImmediateGizmos.reset()`, which resets the state back to the defaults and is ready to be used by the next caller.

```gdscript
# Undo color and transform changes!
ImmediateGizmos.reset();
```

### Example Output

All of this combined produces the following:

![Example Image](/media/example.png)

## Function List

| Functions   | Arguments                                                                             | Description                                                                              |
| ----------- | ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| line        | from : `Vector3`<br>to : `Vector3`                                                    | Draws a line from point `from` to point `to`.                                            |
| lineStrip   | points : `Array[Vector3]`                                                             | Draws a continuous line made up from array points.                                       |
| linePolygon | points : `Array[Vector3]`                                                             | Draws a continuous closed line loop made up from the array points.                       |
| lineArc     | center : `Vector3`<br>axis : `Vector3`<br>startPoint : `Vector3`<br>radians : `float` | Draws a continuous line from `startPoint` rotated around the chosen `axis` by `radians`. |
| lineCircle  | center : `Vector3`<br>axis : `Vector3`<br>radius : `float`                            | Draws a circle of `radius` around `center` based on `axis`.                              |
| lineSphere  | center : `Vector3`<br>radius : `float`                                                | Draws an axis-aligned sphere of `radius` around `center`.                                |
| lineCapsule | center : `Vector3`<br>radius : `float`<br>height : `float`                            | Draws an axis-aligned capsule of `radius` and `height` around `center`.                  |
| lineCuboid  | center : `Vector3`<br>radius : `Vector3`                                              | Draws an axis-aligned cuboid of          `radius` size around `center`.                  |
| lineCube    | center : `Vector3`<br>radius : `float`                                                | Draws an axis-aligned cube of          `radius` size around `center`.                    |

<hr>

[Immediate Gizmos](https://github.com/jawdan-dev/Immediate-Gizmos) © 2026 by [Jawdan.dev](https://jawdan.dev/) is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)