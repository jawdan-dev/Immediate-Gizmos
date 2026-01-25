extends MeshInstance3D
class_name ImmediateGizmosInternal;

static var gizmoRoot : ImmediateGizmosInternal = null;
static var gizmoMaterial : ShaderMaterial = preload("res://addons/immediate_gizmos/immediate_gizmos.tres");

class ImmediateGizmosRenderInstance:
	var meshInstance : MeshInstance3D;
	var mesh : ImmediateMesh;

	func _init() -> void:
		meshInstance = MeshInstance3D.new();
		mesh = ImmediateMesh.new();
		meshInstance.mesh = mesh;

		meshInstance.material_override = ImmediateGizmosInternal.gizmoMaterial;
		ImmediateGizmosInternal.gizmoRoot.add_child(meshInstance);

static var s_instance : ImmediateGizmosRenderInstance = null;
static var s_physiscsInstance : ImmediateGizmosRenderInstance = null;
static func getInstance() -> ImmediateGizmosRenderInstance:
	if (gizmoRoot == null):
		assert(ProjectSettings.get_setting("application/run/main_loop_type") == "SceneTree", "To use ImmediateGizmos, the project main loop must be of type 'SceneTree'");
		var sceneTree := Engine.get_main_loop() as SceneTree;
		gizmoRoot = ImmediateGizmosInternal.new();
		sceneTree.root.add_child(gizmoRoot);

	if (Engine.is_in_physics_frame()):
		if (s_physiscsInstance == null):
			s_physiscsInstance = ImmediateGizmosRenderInstance.new();
		return s_physiscsInstance;
	if (s_instance == null):
		s_instance = ImmediateGizmosRenderInstance.new();
	return s_instance;

##########################################################################

static var points : Array[Vector3] = [];

static func drawPoint(point : Vector3) -> void:
	points.append(point);

static func drawLine(from : Vector3, to : Vector3) -> void:
	drawPoint(from);
	drawPoint(to);

static func drawArc(center : Vector3, axis : Vector3, startPoint : Vector3, radians : float) -> void:
	radians = clampf(radians, 0.0, TAU);
	if (radians <= 0.0):
		return;

	var detail := ceilf((radians / TAU) * 32.0);
	var increment = radians / (detail as float);

	for i : int in range(detail + 1):
		var pos = startPoint.rotated(axis, (i as float) * increment);
		points.append(center + pos);

##########################################################################

static func endDraw(color : Color, transform3d : Transform3D) -> void:
	if (points.size() <= 0):
		return;

	var instanceMesh := ImmediateGizmosInternal.getInstance().mesh;
	instanceMesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP);
	instanceMesh.surface_set_color(color);
	for point : Vector3 in points:
		instanceMesh.surface_add_vertex(transform3d * point);
	instanceMesh.surface_end();

	points.clear();

##########################################################################

func _ready() -> void:
	process_priority = -999;
	process_physics_priority = -999;

func _process(_delta: float) -> void:
	if (s_instance == null): return;
	s_instance.mesh.clear_surfaces();
	ImmediateGizmos.reset();

func _physics_process(_delta: float) -> void:
	if (s_physiscsInstance == null): return;
	s_physiscsInstance.mesh.clear_surfaces();
	ImmediateGizmos.reset();

##########################################################################
