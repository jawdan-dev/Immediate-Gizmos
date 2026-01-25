@tool
extends EditorPlugin

##########################################################################

func _enable_plugin() -> void:
	assert(ProjectSettings.get_setting("application/run/main_loop_type") == "SceneTree", "To use ImmediateGizmos, the project main loop must be of type 'SceneTree'");
	add_autoload_singleton("ImmediateGizmos", "res://addons/immediate_gizmos/immediate_gizmos.gd");

func _disable_plugin() -> void:
	remove_autoload_singleton("ImmediateGizmos");

##########################################################################
