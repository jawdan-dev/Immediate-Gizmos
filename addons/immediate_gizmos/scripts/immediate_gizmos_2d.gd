extends Node

var color : Color = Color.WHITE;
var transform : Transform2D = Transform2D.IDENTITY;

func reset():
	color = Color.WHITE;
	transform = Transform2D.IDENTITY;
	
##########################################################################

func line(from : Vector2, to : Vector2, drawColor : Color = color) -> void:
	ImmediateGizmosInternal.drawLine2D(from, to);
	ImmediateGizmosInternal.endDraw2D(drawColor, transform);
	
func lineStrip(points : Array[Vector2], drawColor : Color = color) -> void:
	ImmediateGizmosInternal.points2D.append_array(points);
	ImmediateGizmosInternal.endDraw2D(drawColor, transform);
	
func linePolygon(points : Array[Vector2], drawColor : Color = color) -> void:
	ImmediateGizmosInternal.points2D.append_array(points);
	if (points.size() <= 0): return;
	ImmediateGizmosInternal.drawPoint2D(points[0])
	ImmediateGizmosInternal.endDraw2D(drawColor, transform);
	
func lineArc(center : Vector2, startPoint : Vector2, radians : float, drawColor : Color = color) -> void:
	ImmediateGizmosInternal.drawArc2D(center, startPoint, radians);
	ImmediateGizmosInternal.endDraw2D(drawColor, transform);

func lineCircle(center : Vector2, radius : float, drawColor : Color = color) -> void:
	ImmediateGizmosInternal.drawArc2D(center, Vector2.UP * radius, TAU);
	ImmediateGizmosInternal.endDraw2D(drawColor, transform);
	
func lineCapsule(center : Vector2, radius : float, height : float, drawColor : Color = color) -> void:
	height -= radius * 2;
	if (height < 0):
		return lineCircle(center, radius, drawColor);
	
	var topCenter := center + Vector2(0.0, height * 0.5);
	var bottomCenter := center - Vector2(0.0, height * 0.5);
	
	var east := Vector2.RIGHT * radius;
	var west := Vector2.LEFT * radius;
	
	# Zero overlaps, super cool!
	ImmediateGizmosInternal.drawArc2D(topCenter, east, PI);
	ImmediateGizmosInternal.drawArc2D(bottomCenter, west, PI);
	ImmediateGizmosInternal.drawPoint2D(topCenter + east);
	ImmediateGizmosInternal.endDraw2D(drawColor, transform);
	
func lineRect(center : Vector2, size : Vector2, drawColor : Color = color) -> void:
	var tl := center + (Vector2(-1, -1) * size);
	var tr := center + (Vector2(1, -1) * size);
	var bl := center + (Vector2(-1, 1) * size);
	var br := center + (Vector2(1, 1) * size);
	
	# 3 Overlaps. Argh.
	ImmediateGizmosInternal.drawLine2D(tl, tr);
	ImmediateGizmosInternal.drawLine2D(br, bl);
	ImmediateGizmosInternal.drawPoint2D(tl);
	ImmediateGizmosInternal.endDraw2D(drawColor, transform);
	
func lineSquare(center : Vector2, size : float, drawColor : Color = color) -> void:
	lineRect(center, Vector2.ONE * size, drawColor);

##########################################################################
