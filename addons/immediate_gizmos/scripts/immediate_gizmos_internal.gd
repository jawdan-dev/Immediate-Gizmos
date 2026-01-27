extends Node
class_name ImmediateGizmosInternal;

const _processPriority = -999;

static var gizmoRoot : ImmediateGizmosInternal = null;
static var gizmoMaterial2D : ShaderMaterial = preload("res://addons/immediate_gizmos/materials/immediate_gizmos_2d.tres");
static var gizmoMaterial3D : ShaderMaterial = preload("res://addons/immediate_gizmos/materials/immediate_gizmos_3d.tres");

##########################################################################

class ImmediateGizmosRenderInstance:
	var meshInstance;
	var mesh : ImmediateMesh;
	var is3D : bool;

	func _init(_is3d : bool) -> void:
		is3D = _is3d;
		
		meshInstance = MeshInstance3D.new() if is3D else MeshInstance2D.new();
		mesh = ImmediateMesh.new();
		
		if (is3D):
			var _meshInstance := meshInstance as MeshInstance3D;
			_meshInstance.mesh = mesh;
			_meshInstance.material_override = ImmediateGizmosInternal.gizmoMaterial3D;
		else:
			var _meshInstance := meshInstance as MeshInstance2D;
			_meshInstance.mesh = mesh;
			_meshInstance.top_level = true;
			_meshInstance.material = ImmediateGizmosInternal.gizmoMaterial2D;

		ImmediateGizmosInternal.gizmoRoot.add_child(meshInstance);

static var s_instance2D : ImmediateGizmosRenderInstance = null;
static var s_physiscsInstance2D : ImmediateGizmosRenderInstance = null;
static var s_instance3D : ImmediateGizmosRenderInstance = null;
static var s_physiscsInstance3D : ImmediateGizmosRenderInstance = null;

static func getInstance(is3D : bool) -> ImmediateGizmosRenderInstance:
	if (gizmoRoot == null):
		assert(ProjectSettings.get_setting("application/run/main_loop_type") == "SceneTree", "To use ImmediateGizmos, the project main loop must be of type 'SceneTree'");
		var sceneTree := Engine.get_main_loop() as SceneTree;
		gizmoRoot = ImmediateGizmosInternal.new();
		sceneTree.root.add_child(gizmoRoot);

	if (is3D):
		if (Engine.is_in_physics_frame()):
			if (s_physiscsInstance3D == null):
				s_physiscsInstance3D = ImmediateGizmosRenderInstance.new(true);
			return s_physiscsInstance3D;
		else:
			if (s_instance3D == null):
				s_instance3D = ImmediateGizmosRenderInstance.new(true);
			return s_instance3D;
	else: 
		if (Engine.is_in_physics_frame()):
			if (s_physiscsInstance2D == null):
				s_physiscsInstance2D = ImmediateGizmosRenderInstance.new(false);
			return s_physiscsInstance2D;
		else:
			if (s_instance2D == null):
				s_instance2D = ImmediateGizmosRenderInstance.new(false);
			return s_instance2D;
		
		

##########################################################################

static var points2D : Array[Vector2] = [];
static func drawPoint2D(point : Vector2) -> void:
	points2D.append(point);

static func drawLine2D(from : Vector2, to : Vector2) -> void:
	drawPoint2D(from);
	drawPoint2D(to);

static func drawArc2D(center : Vector2, startPoint : Vector2, radians : float) -> void:
	radians = clampf(radians, 0.0, TAU);
	if (radians <= 0.0):
		return;

	var detail := ceilf((radians / TAU) * 32.0);
	var increment = radians / (detail as float);

	for i : int in range(detail + 1):
		var pos = startPoint.rotated((i as float) * increment);
		drawPoint2D(center + pos);

static func endDraw2D(color : Color, transform2d : Transform2D) -> void:
	if (points2D.size() <= 0): 
		return;

	var instanceMesh := ImmediateGizmosInternal.getInstance(false).mesh;
	instanceMesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP);
	instanceMesh.surface_set_color(color);
	for point : Vector2 in points2D:
		var worldPoint := transform2d * point;
		instanceMesh.surface_add_vertex(Vector3(worldPoint.x, worldPoint.y, 0.0));
	instanceMesh.surface_end();

	points2D.clear();
		
##########################################################################

static var points3D : Array[Vector3] = [];
static func drawPoint3D(point : Vector3) -> void:
	points3D.append(point);

static func drawLine3D(from : Vector3, to : Vector3) -> void:
	drawPoint3D(from);
	drawPoint3D(to);

static func drawArc3D(center : Vector3, axis : Vector3, startPoint : Vector3, radians : float) -> void:
	radians = clampf(radians, 0.0, TAU);
	if (radians <= 0.0):
		return;

	var detail := ceilf((radians / TAU) * 32.0);
	var increment = radians / (detail as float);

	for i : int in range(detail + 1):
		var pos = startPoint.rotated(axis, (i as float) * increment);
		drawPoint3D(center + pos);

static func endDraw3D(color : Color, transform3d : Transform3D) -> void:
	if (points3D.size() <= 0): 
		return;

	var instanceMesh := ImmediateGizmosInternal.getInstance(true).mesh;
	instanceMesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP);
	instanceMesh.surface_set_color(color);
	for point : Vector3 in points3D:
		instanceMesh.surface_add_vertex(transform3d * point);
	instanceMesh.surface_end();

	points3D.clear();

##########################################################################

func _ready() -> void:
	process_priority = _processPriority;
	process_physics_priority = _processPriority;

func _process(_delta: float) -> void:
	if (s_instance2D != null):
		s_instance2D.mesh.clear_surfaces();
	if (s_instance3D != null):
		s_instance3D.mesh.clear_surfaces();

func _physics_process(_delta: float) -> void:
	if (s_physiscsInstance2D != null):
		s_physiscsInstance2D.mesh.clear_surfaces();
	if (s_physiscsInstance3D != null):
		s_physiscsInstance3D.mesh.clear_surfaces();

##########################################################################
