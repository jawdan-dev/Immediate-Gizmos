extends Node

var color : Color = Color.WHITE;
var transform : Transform3D = Transform3D.IDENTITY;

func reset():
	color = Color.WHITE;
	transform = Transform3D.IDENTITY;
	
##########################################################################

func line(from : Vector3, to : Vector3, drawColor : Color = color) -> void:
	ImmediateGizmosInternal.drawLine3D(from, to);
	ImmediateGizmosInternal.endDraw3D(drawColor, transform);
	
func lineStrip(points : Array[Vector3], drawColor : Color = color) -> void:
	ImmediateGizmosInternal.points3D.append_array(points);
	ImmediateGizmosInternal.endDraw3D(drawColor, transform);
	
func linePolygon(points : Array[Vector3], drawColor : Color = color) -> void:
	ImmediateGizmosInternal.points3D.append_array(points);
	if (points.size() <= 0): return;
	ImmediateGizmosInternal.drawPoint3D(points[0])
	ImmediateGizmosInternal.endDraw3D(drawColor, transform);
	
func lineArc(center : Vector3, axis : Vector3, startPoint : Vector3, radians : float, drawColor : Color = color) -> void:
	ImmediateGizmosInternal.drawArc3D(center, axis, startPoint, radians);
	ImmediateGizmosInternal.endDraw3D(drawColor, transform);

func lineCircle(center : Vector3, axis : Vector3, radius : float, drawColor : Color = color) -> void:
	var against := Vector3.RIGHT if axis.is_equal_approx(Vector3.UP) else Vector3.UP;
	var startDirection := axis.cross(against).normalized();
	ImmediateGizmosInternal.drawArc3D(center, axis, startDirection * radius, TAU);
	ImmediateGizmosInternal.endDraw3D(drawColor, transform);

func lineSphere(center : Vector3, radius : float, drawColor : Color = color) -> void:
	ImmediateGizmosInternal.drawArc3D(center, Vector3.RIGHT, Vector3.UP * radius, TAU);
	ImmediateGizmosInternal.drawArc3D(center, Vector3.UP, Vector3.UP * radius, TAU);
	ImmediateGizmosInternal.drawArc3D(center, Vector3.FORWARD, Vector3.UP * radius, TAU);
	ImmediateGizmosInternal.endDraw3D(drawColor, transform);
	
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
	ImmediateGizmosInternal.drawArc3D(topCenter, Vector3.RIGHT, north, PI);
	ImmediateGizmosInternal.drawArc3D(bottomCenter, Vector3.RIGHT, south, PI);
	ImmediateGizmosInternal.drawArc3D(topCenter, Vector3.UP, north, TAU * 0.25);
	ImmediateGizmosInternal.drawArc3D(topCenter, Vector3.FORWARD, west, PI);
	ImmediateGizmosInternal.drawArc3D(bottomCenter, Vector3.FORWARD, east, PI);
	ImmediateGizmosInternal.drawArc3D(bottomCenter, Vector3.UP, west, TAU);
	ImmediateGizmosInternal.drawArc3D(topCenter, Vector3.UP, west, TAU * 0.75);
	ImmediateGizmosInternal.endDraw3D(drawColor, transform);
	
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
	ImmediateGizmosInternal.drawLine3D(tlb, tlf);
	ImmediateGizmosInternal.drawLine3D(blf, blb);
	ImmediateGizmosInternal.drawLine3D(tlb, trb);
	ImmediateGizmosInternal.drawPoint3D(trf);
	ImmediateGizmosInternal.drawPoint3D(tlf);
	ImmediateGizmosInternal.drawLine3D(trf, brf);
	ImmediateGizmosInternal.drawPoint3D(blf);
	ImmediateGizmosInternal.drawLine3D(brf, brb);
	ImmediateGizmosInternal.drawPoint3D(blb);
	ImmediateGizmosInternal.drawLine3D(brb, trb);
	ImmediateGizmosInternal.endDraw3D(drawColor, transform);
	
func lineCube(center : Vector3, radius : float, drawColor : Color = color) -> void:
	lineCuboid(center, Vector3.ONE * radius, drawColor);

##########################################################################
