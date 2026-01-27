extends Node

var color : Color = Color.WHITE;
var transform : Transform2D = Transform2D.IDENTITY;

func reset():
	color = Color.WHITE;
	transform = Transform2D.IDENTITY;
	
##########################################################################

func line(from : Vector2, to : Vector2, drawColor : Color = color) -> void:
	ImmediateGizmosInternal.draw_line_2d(from, to);
	ImmediateGizmosInternal.end_draw_2d(drawColor, transform);
	
func line_strip(points : Array[Vector2], drawColor : Color = color) -> void:
	ImmediateGizmosInternal.points_2d.append_array(points);
	ImmediateGizmosInternal.end_draw_2d(drawColor, transform);
	
func line_polygon(points : Array[Vector2], drawColor : Color = color) -> void:
	ImmediateGizmosInternal.points_2d.append_array(points);
	if (points.size() <= 0): return;
	ImmediateGizmosInternal.draw_point_2d(points[0])
	ImmediateGizmosInternal.end_draw_2d(drawColor, transform);
	
func line_arc(center : Vector2, startPoint : Vector2, radians : float, drawColor : Color = color) -> void:
	ImmediateGizmosInternal.draw_arc_2d(center, startPoint, radians);
	ImmediateGizmosInternal.end_draw_2d(drawColor, transform);

func line_circle(center : Vector2, radius : float, drawColor : Color = color) -> void:
	ImmediateGizmosInternal.draw_arc_2d(center, Vector2.UP * radius, TAU);
	ImmediateGizmosInternal.end_draw_2d(drawColor, transform);
	
func line_capsule(center : Vector2, radius : float, height : float, drawColor : Color = color) -> void:
	height -= radius * 2;
	if (height < 0):
		return line_circle(center, radius, drawColor);
	
	var topCenter := center + Vector2(0.0, height * 0.5);
	var bottomCenter := center - Vector2(0.0, height * 0.5);
	
	var east := Vector2.RIGHT * radius;
	var west := Vector2.LEFT * radius;
	
	# Zero overlaps, super cool!
	ImmediateGizmosInternal.draw_arc_2d(topCenter, east, PI);
	ImmediateGizmosInternal.draw_arc_2d(bottomCenter, west, PI);
	ImmediateGizmosInternal.draw_point_2d(topCenter + east);
	ImmediateGizmosInternal.end_draw_2d(drawColor, transform);
	
func line_rect(center : Vector2, size : Vector2, drawColor : Color = color) -> void:
	var tl := center + (Vector2(-1, -1) * size);
	var tr := center + (Vector2(1, -1) * size);
	var bl := center + (Vector2(-1, 1) * size);
	var br := center + (Vector2(1, 1) * size);
	
	# 3 Overlaps. Argh.
	ImmediateGizmosInternal.draw_line_2d(tl, tr);
	ImmediateGizmosInternal.draw_line_2d(br, bl);
	ImmediateGizmosInternal.draw_point_2d(tl);
	ImmediateGizmosInternal.end_draw_2d(drawColor, transform);
	
func line_square(center : Vector2, size : float, drawColor : Color = color) -> void:
	line_rect(center, Vector2.ONE * size, drawColor);

##########################################################################
