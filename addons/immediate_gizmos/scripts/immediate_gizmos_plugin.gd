@tool
extends EditorPlugin

##########################################################################

func _enable_plugin() -> void:
	assert(ProjectSettings.get_setting("application/run/main_loop_type") == "SceneTree", "To use ImmediateGizmos, the project main loop must be of type 'SceneTree'");
	add_autoload_singleton("ImmediateGizmos2D", "res://addons/immediate_gizmos/scripts/immediate_gizmos_2d.gd");
	add_autoload_singleton("ImmediateGizmos3D", "res://addons/immediate_gizmos/scripts/immediate_gizmos_3d.gd");
	
func _disable_plugin() -> void:
	remove_autoload_singleton("ImmediateGizmos2D");
	remove_autoload_singleton("ImmediateGizmos3D");

##########################################################################
