@tool
extends Node
class_name EditorImmediateGizmos;

const target_process_priority = -999;
const __expected_id : int = 0x1eaf1e55;
@onready var __id := __expected_id;

static var gizmo_root : EditorImmediateGizmos = null;
static var gizmo_material_2d : ShaderMaterial = preload("res://addons/immediate_gizmos/materials/immediate_gizmos_2d.tres");
static var gizmo_material_3d : ShaderMaterial = preload("res://addons/immediate_gizmos/materials/immediate_gizmos_3d.tres");

##########################################################################

class ImmediateGizmosRenderInstance:
	var meshInstance;
	var mesh : ImmediateMesh;
	var is_3d : bool;

	func _init(is3D : bool) -> void:
		is_3d = is3D;
		
		meshInstance = MeshInstance3D.new() if is_3d else MeshInstance2D.new();
		mesh = ImmediateMesh.new();
		
		if (is3D):
			var _meshInstance := meshInstance as MeshInstance3D;
			_meshInstance.mesh = mesh;
			_meshInstance.material_override = EditorImmediateGizmos.gizmo_material_3d;
		else:
			var _meshInstance := meshInstance as MeshInstance2D;
			_meshInstance.mesh = mesh;
			_meshInstance.top_level = true;
			_meshInstance.material = EditorImmediateGizmos.gizmo_material_2d;
	
		EditorImmediateGizmos.get_root().add_child(meshInstance);

class ImmediateGizmosRenderBlock:
	var instance_counter := 0;
	var instances : Array[ImmediateGizmosRenderInstance] = [];
	var is_3d : bool;
	
	func _init(is3D : bool) -> void:
		is_3d = is3D;
	
	func get_instance():
		if (instances.size() <= instance_counter):
			instance_counter = instances.size();
			instances.append(ImmediateGizmosRenderInstance.new(is_3d));
		elif (instances[instance_counter].mesh.get_surface_count() >= RenderingServer.MAX_MESH_SURFACES):
			instance_counter += 1;
			return get_instance();
		return instances[instance_counter];
	
	func clear():
		for instance in instances:
			instance.mesh.clear_surfaces();
		instance_counter = 0;

class ImmediateGizmosRenderSelector:
	var process_block : ImmediateGizmosRenderBlock;
	var physics_process_block : ImmediateGizmosRenderBlock;
	func _init(is3D : bool) -> void:
		process_block = ImmediateGizmosRenderBlock.new(is3D);
		physics_process_block = ImmediateGizmosRenderBlock.new(is3D);
		
	func get_instance():
		if (Engine.is_in_physics_frame()):
			return physics_process_block.get_instance();
		return process_block.get_instance();
		
	func clear():
		if (Engine.is_in_physics_frame()):
			return physics_process_block.clear();
		return process_block.clear();

static var selector_2d : ImmediateGizmosRenderSelector = ImmediateGizmosRenderSelector.new(false);
static var selector_3d : ImmediateGizmosRenderSelector = ImmediateGizmosRenderSelector.new(true);

static func get_scene_root() -> Node:
	if (Engine.is_editor_hint()):
		return EditorInterface.get_edited_scene_root().get_parent();

	assert(ProjectSettings.get_setting("application/run/main_loop_type") == "SceneTree", "To use ImmediateGizmos, the project main loop must be of type 'SceneTree'");
	return (Engine.get_main_loop() as SceneTree).root;
		
static func get_root() -> EditorImmediateGizmos:
	if (gizmo_root != null): 
		return gizmo_root;

	# Get root.
	var sceneRoot : Node = get_scene_root();

	var rootCounter = 1;
	var rootName := "ImmediateGizmos";
	var rootNode := sceneRoot.find_child(rootName, false, false);
	while (rootNode != null):
		if (rootNode.get("__id") == __expected_id):
			# Claim back root??
			gizmo_root = rootNode;
			return gizmo_root;
		
		# Ignore same named node.
		rootCounter += 1;
		rootName = "ImmediateGizmos%d" % rootCounter;
		rootNode = sceneRoot.find_child(rootName, false, false);
	
	# Create root.
	gizmo_root = EditorImmediateGizmos.new();
	gizmo_root.name = rootName;
	sceneRoot.add_child(gizmo_root);
	
	return gizmo_root;
	
static func get_instance(is3D : bool) -> ImmediateGizmosRenderInstance:
	if (is3D):
		return selector_3d.get_instance();
	return selector_2d.get_instance();

##########################################################################

static var gizmo_default_color := Color.TRANSPARENT; # Key

static var draw_color : Color = Color.WHITE;
static var draw_2d_transform : Transform2D = Transform2D.IDENTITY;
static var draw_3d_transform : Transform3D = Transform3D.IDENTITY;
static var draw_required_selection : Node = null;

static func is_required_selection_met() -> bool:
	if (draw_required_selection == null): 
		return true;
	if (!Engine.is_editor_hint()):
		return false;
	
	var sceneRoot := get_scene_root();
	var selected := draw_required_selection;
	
	while (selected != sceneRoot):
		if (EditorInterface.get_selection().get_selected_nodes().has(selected)):
			return true;
		selected = selected.get_parent();
	return false;	

static func reset() -> void:
	draw_color = Color.WHITE;
	draw_2d_transform = Transform2D.IDENTITY;
	draw_3d_transform = Transform3D.IDENTITY;
	draw_required_selection = null;

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

static func end_draw_2d(color : Color) -> void:
	if (points_2d.size() <= 0):
		return;
	if (!is_required_selection_met()): 
		points_2d.clear();
		return;

	var instance := EditorImmediateGizmos.get_instance(false);
	if (instance == null):
		return;
	var instanceMesh := instance.mesh;

	instanceMesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP);
	instanceMesh.surface_set_color(color if (color != gizmo_default_color) else draw_color);
	for point : Vector2 in points_2d:
		var worldPoint := draw_2d_transform * point;
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

static func end_draw_3d(color : Color) -> void:
	if (points_3d.size() <= 0):
		return;
	if (!is_required_selection_met()): 
		points_3d.clear();
		return;

	var instance := EditorImmediateGizmos.get_instance(true);
	if (instance == null):
		return;
	var instanceMesh := instance.mesh;

	instanceMesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP);
	instanceMesh.surface_set_color(color if (color != gizmo_default_color) else draw_color);
	for point : Vector3 in points_3d:
		instanceMesh.surface_add_vertex(draw_3d_transform * point);
	instanceMesh.surface_end();

	points_3d.clear();

##########################################################################

func _ready() -> void:
	process_priority = target_process_priority;
	process_physics_priority = target_process_priority;
	set_process(true);
	set_physics_process(true);

func _process(_delta: float) -> void:
	selector_2d.clear();
	selector_3d.clear();
	reset();

func _physics_process(_delta: float) -> void:
	selector_2d.clear();
	selector_3d.clear();
	reset();

##########################################################################
