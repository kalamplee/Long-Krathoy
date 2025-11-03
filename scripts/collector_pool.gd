# CollectorPool.gd
# ตั้งค่า Node นี้ให้เป็น Autoload (Singleton) ใน Project Settings
extends Node

# Scene ของ Collector ที่จะถูกสร้างและเก็บไว้ใน Pool
@export var collector_scene: PackedScene = load("res://nodes/collector.tscn")

# สระน้ำสำหรับเก็บ Node ของ Collector ที่ไม่ได้ใช้งาน
var inactive_collectors: Array[CharacterBody2D] = []

# Node ที่เป็น Container หลักของ Collector ทั้งหมดใน Scene
@export var collectors_parent_node_path: NodePath = "../CollectorsContainer"
var collectors_parent: Node2D = null

# ขนาดหน้าจอเกม
const SCREEN_SIZE: Vector2 = Vector2(512, 512)

func _ready() -> void:
	# เราจะใช้ Scene Root ที่ถูกโหลดแทนการพึ่งพา NodePath
	var scene_root = get_tree().get_current_scene()
	
	if scene_root is Node2D:
		collectors_parent = scene_root as Node2D
	elif scene_root != null:
		# ถ้า Root Node ไม่ใช่ Node2D เช่น เป็น Node ธรรมดา หรือ Control
		# เราอาจจะต้องใช้ scene_root.get_parent() เพื่อหา Node2D ที่เหมาะสม
		push_error("Scene Root (ชื่อ %s) ไม่ใช่ Node2D! กรุณาตรวจสอบโครงสร้าง Scene ฮ่ะ" % scene_root.name)
		
	if collectors_parent == null:
		push_error("ไม่สามารถกำหนด Parent Node2D สำหรับ Collector ได้ฮะ")
# ฟังก์ชันสาธารณะสำหรับเรียกใช้ Collector จาก Pool
func spawn_collector(start_pos: Vector2, target_pos: Vector2) -> void:
	var collector: CharacterBody2D
	
	if inactive_collectors.size() > 0:
		# 1. นำ Collector จาก Pool กลับมาใช้ใหม่
		collector = inactive_collectors.pop_back()
		print("Recycling Collector (Pool Size: %d)" % inactive_collectors.size())
		
	else:
		# 2. ถ้า Pool ว่าง ให้สร้าง Collector ใหม่
		collector = collector_scene.instantiate() as CharacterBody2D
		# เพิ่ม Collector ใหม่เข้าสู่ Scene Tree
		collectors_parent.add_child(collector)
		print("Instantiating New Collector (Pool Size: %d)" % inactive_collectors.size())

	# 3. ตั้งค่าและเปิดใช้งาน Collector
	collector.global_position = start_pos
	# ต้องแน่ใจว่า Collector มีฟังก์ชัน 'initialize'
	if collector.has_method("initialize"):
		collector.initialize(target_pos, self)
		collector.show() # ทำให้มองเห็นได้
		collector.set_process(true) # เปิดใช้งาน process (ถ้าปิดไว้)
		collector.set_physics_process(true) # เปิดใช้งาน physics process
	else:
		push_error("Collector scene is missing the 'initialize' method.")
	
# ฟังก์ชันสาธารณะสำหรับส่ง Collector กลับเข้าสู่ Pool
func return_collector(collector: CharacterBody2D) -> void:
	if collector.is_inside_tree():
		# 1. ซ่อนและปิดการทำงานของ Collector
		collector.hide()
		collector.set_process(false)
		collector.set_physics_process(false)
		
		# 2. ตรวจสอบว่ายังไม่ได้อยู่ใน Pool (เพื่อป้องกันการคืนซ้ำ)
		if !inactive_collectors.has(collector):
			inactive_collectors.append(collector)
			print("Collector Returned to Pool (Pool Size: %d)" % inactive_collectors.size())
		else:
			# ถ้ามีข้อผิดพลาด ให้ลบออกไปเลย
			collector.queue_free()

# ฟังก์ชันเสริม: สร้าง Collector ล่วงหน้าเมื่อเริ่มเกม
func pre_populate_pool(count: int) -> void:
	for i in range(count):
		var collector = collector_scene.instantiate() as CharacterBody2D
				# *** [KEY FIX] กำหนด Pool Manager Reference ทันทีหลังจากสร้าง ***
		if collector.has_method("set_pool_manager"):
			collector.set_pool_manager(self)
		
		# สั่งให้ Godot เพิ่ม Node เข้า Scene Tree หลังจากที่กำลังจัดฉากเสร็จแล้ว
		if collectors_parent != null:
			collectors_parent.add_child.call_deferred(collector)
		# ซ่อนไว้ก่อน
		collector.hide()
		collector.set_process(false)
		collector.set_physics_process(false)
		collectors_parent.add_child.call_deferred(collector)
		inactive_collectors.append(collector)
	print("Pool pre-populated with %d collectors." % count)
