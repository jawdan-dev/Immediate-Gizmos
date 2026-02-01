class_name ImmediateGizmos2D

static var color : Color = Color.WHITE;
static var transform : Transform2D = Transform2D.IDENTITY;

static func reset():
	color = Color.WHITE;
	transform = Transform2D.IDENTITY;
	
##########################################################################

static func line(from : Vector2, to : Vector2, drawColor : Color = color) -> void:
	EditorImmediateGizmos.draw_line_2d(from, to);
	EditorImmediateGizmos.end_draw_2d(drawColor, transform);
	
static func line_strip(points : Array[Vector2], drawColor : Color = color) -> void:
	EditorImmediateGizmos.points_2d.append_array(points);
	EditorImmediateGizmos.end_draw_2d(drawColor, transform);
	
static func line_polygon(points : Array[Vector2], drawColor : Color = color) -> void:
	EditorImmediateGizmos.points_2d.append_array(points);
	if (points.size() <= 0): return;
	EditorImmediateGizmos.draw_point_2d(points[0])
	EditorImmediateGizmos.end_draw_2d(drawColor, transform);
	
static func line_arc(center : Vector2, startPoint : Vector2, radians : float, drawColor : Color = color) -> void:
	EditorImmediateGizmos.draw_arc_2d(center, startPoint, radians);
	EditorImmediateGizmos.end_draw_2d(drawColor, transform);

static func line_circle(center : Vector2, radius : float, drawColor : Color = color) -> void:
	EditorImmediateGizmos.draw_arc_2d(center, Vector2.UP * radius, TAU);
	EditorImmediateGizmos.end_draw_2d(drawColor, transform);
	
static func line_capsule(center : Vector2, radius : float, height : float, drawColor : Color = color) -> void:
	height -= radius * 2;
	if (height < 0):
		return line_circle(center, radius, drawColor);
	
	var topCenter := center + Vector2(0.0, height * 0.5);
	var bottomCenter := center - Vector2(0.0, height * 0.5);
	
	var east := Vector2.RIGHT * radius;
	var west := Vector2.LEFT * radius;
	
	# Zero overlaps, super cool!
	EditorImmediateGizmos.draw_arc_2d(topCenter, east, PI);
	EditorImmediateGizmos.draw_arc_2d(bottomCenter, west, PI);
	EditorImmediateGizmos.draw_point_2d(topCenter + east);
	EditorImmediateGizmos.end_draw_2d(drawColor, transform);
	
static func line_rect(center : Vector2, size : Vector2, drawColor : Color = color) -> void:
	var tl := center + (Vector2(-1, -1) * size);
	var tr := center + (Vector2(1, -1) * size);
	var bl := center + (Vector2(-1, 1) * size);
	var br := center + (Vector2(1, 1) * size);
	
	# 3 Overlaps. Argh.
	EditorImmediateGizmos.draw_line_2d(tl, tr);
	EditorImmediateGizmos.draw_line_2d(br, bl);
	EditorImmediateGizmos.draw_point_2d(tl);
	EditorImmediateGizmos.end_draw_2d(drawColor, transform);
	
static func line_square(center : Vector2, size : float, drawColor : Color = color) -> void:
	line_rect(center, Vector2.ONE * size, drawColor);

##########################################################################
