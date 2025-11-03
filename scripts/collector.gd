# krathong_collector_enemy.gd
# ศัตรูผู้ไล่ล่าที่ใช้ Object Pooling
extends CharacterBody2D

@export var speed: float = 350.0

# ตัวแปรสำหรับการเคลื่อนที่
var _travel_direction: Vector2 = Vector2.ZERO
var _pool_manager: Node = null # Reference ไปยัง CollectorPool

# ขนาดหน้าจอเกม
const SCREEN_SIZE: Vector2 = Vector2(512, 512)
# ระยะเผื่อสำหรับหายตัวไปนอกจอ
const BOUNDARY_TOLERANCE: float = 50.0

# [NEW] ฟังก์ชันสำหรับกำหนด Pool Manager Reference
func set_pool_manager(manager: Node) -> void:
	_pool_manager = manager

# ฟังก์ชันนี้ถูกเรียกโดย Pool เมื่อมีการนำกลับมาใช้ (กำหนดทิศทาง)
func initialize(target_pos: Vector2, pool_manager: Node) -> void:
	# ไม่ต้องกำหนด _pool_manager ที่นี่อีกแล้ว เพราะ pre_populate_pool กำหนดไว้แล้ว
	# แต่เรายังคงรับ pool_manager เป็น Argument เผื่อเรียกใช้แบบไม่ผ่าน pre-populate
	
	# คำนวณทิศทางเคลื่อนที่แบบตรงครั้งเดียว (จากตำแหน่งปัจจุบันไปยังเป้าหมาย)
	_travel_direction = global_position.direction_to(target_pos)
	
	# เคลื่อนที่ไปตามทิศทางนั้นเลย
	velocity = _travel_direction * speed

func _physics_process(delta: float) -> void:
	# ตรวจสอบความปลอดภัย: ถ้า _pool_manager ยังเป็น null แสดงว่ามีการเรียกใช้ผิดพลาด
	if _pool_manager == null:
		push_error("Collector Node is active but _pool_manager is Nil. Cannot return to pool.")
		return # ออกจากฟังก์ชันเพื่อป้องกัน Invalid call
	
	# 1. เคลื่อนที่
	move_and_slide()
	
	# 2. ตรวจสอบการหายตัวไปนอกจอ
	if !is_inside_screen():
		# ถ้าหลุดออกนอกจอ ให้คืนตัวเองกลับเข้า Pool
		_pool_manager.return_collector(self)
	
	# 3. ตรวจสอบการชนกับผู้เล่น (ถ้าชน ให้คืนตัวเองกลับ Pool)
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		# สมมติว่ากระทงผู้เล่นอยู่ใน Group "krathong"
		if collision.get_collider() and collision.get_collider().is_in_group("krathong"):
			print("Collector ชนกระทงผู้เล่น! คืนตัวเองเข้า Pool.")
			_pool_manager.return_collector(self)

# ฟังก์ชันตรวจสอบว่า Collector ยังอยู่ในบริเวณหน้าจอหรือไม่
func is_inside_screen() -> bool:
	var x = global_position.x
	var y = global_position.y
	
	# ขอบเขตที่อนุญาต (รวมระยะเผื่อ)
	return (x > -BOUNDARY_TOLERANCE and x < SCREEN_SIZE.x + BOUNDARY_TOLERANCE and
			y > -BOUNDARY_TOLERANCE and y < SCREEN_SIZE.y + BOUNDARY_TOLERANCE)
