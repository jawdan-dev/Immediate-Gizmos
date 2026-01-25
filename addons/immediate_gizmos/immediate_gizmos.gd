extends Node

var color : Color = Color.WHITE;
var transform : Transform3D = Transform3D.IDENTITY;

func reset():
	color = Color.WHITE;
	transform = Transform3D.IDENTITY;

##########################################################################

func line(from : Vector3, to : Vector3, drawColor : Color = color) -> void:
	ImmediateGizmosInternal.drawLine(from, to);
	ImmediateGizmosInternal.endDraw(drawColor, transform);

func lineStrip(points : Array[Vector3], drawColor : Color = color) -> void:
	ImmediateGizmosInternal.points.append_array(points);
	ImmediateGizmosInternal.endDraw(drawColor, transform);

func linePolygon(points : Array[Vector3], drawColor : Color = color) -> void:
	ImmediateGizmosInternal.points.append_array(points);
	if (points.size() <= 0): return;
	ImmediateGizmosInternal.drawPoint(points[0])
	ImmediateGizmosInternal.endDraw(drawColor, transform);

func lineArc(center : Vector3, axis : Vector3, startPoint : Vector3, radians : float, drawColor : Color = color) -> void:
	ImmediateGizmosInternal.drawArc(center, axis, startPoint, radians);
	ImmediateGizmosInternal.endDraw(drawColor, transform);

func lineCircle(center : Vector3, axis : Vector3, radius : float, drawColor : Color = color) -> void:
	var against := Vector3.RIGHT if axis.is_equal_approx(Vector3.UP) else Vector3.UP;
	var startDirection := axis.cross(against).normalized();
	ImmediateGizmosInternal.drawArc(center, axis, startDirection * radius, TAU);
	ImmediateGizmosInternal.endDraw(drawColor, transform);

func lineSphere(center : Vector3, radius : float, drawColor : Color = color) -> void:
	ImmediateGizmosInternal.drawArc(center, Vector3.RIGHT, Vector3.UP * radius, TAU);
	ImmediateGizmosInternal.drawArc(center, Vector3.UP, Vector3.UP * radius, TAU);
	ImmediateGizmosInternal.drawArc(center, Vector3.FORWARD, Vector3.UP * radius, TAU);
	ImmediateGizmosInternal.endDraw(drawColor, transform);

func lineCapsule(center : Vector3, radius : float, height : float, drawColor : Color = color) -> void:
	height -= radius * 2;
	if (height < 0):
		return lineSphere(center, radius, drawColor);

	var topCenter := center + Vector3(0.0, height * 0.5, 0.0);
	var bottomCenter := center - Vector3(0.0, height * 0.5, 0.0);

	var north := Vector3.FORWARD * radius;
	var east := Vector3.RIGHT * radius;
	var south := Vector3.BACK * radius;
	var west := Vector3.LEFT * radius;

	# Zero overlaps, super cool!
	ImmediateGizmosInternal.drawArc(topCenter, Vector3.RIGHT, north, PI);
	ImmediateGizmosInternal.drawArc(bottomCenter, Vector3.RIGHT, south, PI);
	ImmediateGizmosInternal.drawArc(topCenter, Vector3.UP, north, TAU * 0.25);
	ImmediateGizmosInternal.drawArc(topCenter, Vector3.FORWARD, west, PI);
	ImmediateGizmosInternal.drawArc(bottomCenter, Vector3.FORWARD, east, PI);
	ImmediateGizmosInternal.drawArc(bottomCenter, Vector3.UP, west, TAU);
	ImmediateGizmosInternal.drawArc(topCenter, Vector3.UP, west, TAU * 0.75);
	ImmediateGizmosInternal.endDraw(drawColor, transform);

func lineCuboid(center : Vector3, radius : Vector3, drawColor : Color = color) -> void:
	var tlb := center + (Vector3(1, 1, -1) * radius);
	var tlf := center + (Vector3(1, 1, 1) * radius);
	var trb := center + (Vector3(-1, 1, -1) * radius);
	var trf := center + (Vector3(-1, 1, 1) * radius);
	var blb := center + (Vector3(1, -1, -1) * radius);
	var blf := center + (Vector3(1, -1, 1) * radius);
	var brb := center + (Vector3(-1, -1, -1) * radius);
	var brf := center + (Vector3(-1, -1, 1) * radius);

	# 3 Overlaps. Argh.
	ImmediateGizmosInternal.drawLine(tlb, tlf);
	ImmediateGizmosInternal.drawLine(blf, blb);
	ImmediateGizmosInternal.drawLine(tlb, trb);
	ImmediateGizmosInternal.drawPoint(trf);
	ImmediateGizmosInternal.drawPoint(tlf);
	ImmediateGizmosInternal.drawLine(trf, brf);
	ImmediateGizmosInternal.drawPoint(blf);
	ImmediateGizmosInternal.drawLine(brf, brb);
	ImmediateGizmosInternal.drawPoint(blb);
	ImmediateGizmosInternal.drawLine(brb, trb);
	ImmediateGizmosInternal.endDraw(drawColor, transform);

func lineCube(center : Vector3, radius : float, drawColor : Color = color) -> void:
	lineCuboid(center, Vector3.ONE * radius, drawColor);

##########################################################################
