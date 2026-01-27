extends Node
class_name ImmediateGizmosInternal;

const target_process_priority = -999;

static var gizmo_root : ImmediateGizmosInternal = null;
static var gizmo_material_2d : ShaderMaterial = preload("res://addons/immediate_gizmos/materials/immediate_gizmos_2d.tres");
static var gizmo_material_3d : ShaderMaterial = preload("res://addons/immediate_gizmos/materials/immediate_gizmos_3d.tres");

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
			_meshInstance.material_override = ImmediateGizmosInternal.gizmo_material_3d;
		else:
			var _meshInstance := meshInstance as MeshInstance2D;
			_meshInstance.mesh = mesh;
			_meshInstance.top_level = true;
			_meshInstance.material = ImmediateGizmosInternal.gizmo_material_2d;

		ImmediateGizmosInternal.gizmo_root.add_child(meshInstance);
		
static var instance_2d : ImmediateGizmosRenderInstance = null;
static var physiscs_instance_2d : ImmediateGizmosRenderInstance = null;
static var instance_3d : ImmediateGizmosRenderInstance = null;
static var physiscs_instance_3d : ImmediateGizmosRenderInstance = null;

static func get_instance(is3D : bool) -> ImmediateGizmosRenderInstance:
	if (gizmo_root == null):
		assert(ProjectSettings.get_setting("application/run/main_loop_type") == "SceneTree", "To use ImmediateGizmos, the project main loop must be of type 'SceneTree'");
		var sceneTree := Engine.get_main_loop() as SceneTree;
		gizmo_root = ImmediateGizmosInternal.new();
		sceneTree.root.add_child(gizmo_root);

	if (is3D):
		if (Engine.is_in_physics_frame()):
			if (physiscs_instance_3d == null):
				physiscs_instance_3d = ImmediateGizmosRenderInstance.new(true);
			return physiscs_instance_3d;
		else:
			if (instance_3d == null):
				instance_3d = ImmediateGizmosRenderInstance.new(true);
			return instance_3d;
	if (Engine.is_in_physics_frame()):
		if (physiscs_instance_2d == null):
			physiscs_instance_2d = ImmediateGizmosRenderInstance.new(false);
		return physiscs_instance_2d;
	else:
		if (instance_2d == null):
			instance_2d = ImmediateGizmosRenderInstance.new(false);
		return instance_2d;

##########################################################################

static var points_2d : Array[Vector2] = [];
static func draw_point_2d(point : Vector2) -> void:
	points_2d.append(point);

static func draw_line_2d(from : Vector2, to : Vector2) -> void:
	draw_point_2d(from);
	draw_point_2d(to);

static func draw_arc_2d(center : Vector2, startPoint : Vector2, radians : float) -> void:
	radians = clampf(radians, 0.0, TAU);
	if (radians <= 0.0):
		return;

	var detail := ceilf((radians / TAU) * 32.0);
	var increment = radians / (detail as float);

	for i : int in range(detail + 1):
		var pos = startPoint.rotated((i as float) * increment);
		draw_point_2d(center + pos);

static func end_draw_2d(color : Color, transform2d : Transform2D) -> void:
	if (points_2d.size() <= 0): 
		return;

	var instanceMesh := ImmediateGizmosInternal.get_instance(false).mesh;
	instanceMesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP);
	instanceMesh.surface_set_color(color);
	for point : Vector2 in points_2d:
		var worldPoint := transform2d * point;
		instanceMesh.surface_add_vertex(Vector3(worldPoint.x, worldPoint.y, 0.0));
	instanceMesh.surface_end();

	points_2d.clear();
		
##########################################################################

static var points_3d : Array[Vector3] = [];
static func draw_point_3d(point : Vector3) -> void:
	points_3d.append(point);

static func draw_line_3d(from : Vector3, to : Vector3) -> void:
	draw_point_3d(from);
	draw_point_3d(to);

static func draw_arc_3d(center : Vector3, axis : Vector3, startPoint : Vector3, radians : float) -> void:
	radians = clampf(radians, 0.0, TAU);
	if (radians <= 0.0):
		return;

	var detail := ceilf((radians / TAU) * 32.0);
	var increment = radians / (detail as float);

	for i : int in range(detail + 1):
		var pos = startPoint.rotated(axis, (i as float) * increment);
		draw_point_3d(center + pos);

static func end_draw_3d(color : Color, transform3d : Transform3D) -> void:
	if (points_3d.size() <= 0): 
		return;

	var instanceMesh := ImmediateGizmosInternal.get_instance(true).mesh;
	instanceMesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP);
	instanceMesh.surface_set_color(color);
	for point : Vector3 in points_3d:
		instanceMesh.surface_add_vertex(transform3d * point);
	instanceMesh.surface_end();

	points_3d.clear();

##########################################################################

func _ready() -> void:
	process_priority = target_process_priority;
	process_physics_priority = target_process_priority;

func _process(_delta: float) -> void:
	if (instance_2d != null):
		instance_2d.mesh.clear_surfaces();
	if (instance_3d != null):
		instance_3d.mesh.clear_surfaces();

func _physics_process(_delta: float) -> void:
	if (physiscs_instance_2d != null):
		physiscs_instance_2d.mesh.clear_surfaces();
	if (physiscs_instance_3d != null):
		physiscs_instance_3d.mesh.clear_surfaces();

##########################################################################
