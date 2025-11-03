extends CharacterBody2D

# ความเร็วในการเคลื่อนที่ของกระทง (หน่วยเป็น pixels/second)
@export var speed: float = 300.0

# ฟังก์ชัน _physics_process จะถูกเรียกใช้ทุกเฟรมของระบบฟิสิกส์
func _physics_process(delta: float) -> void:
	# 1. รับค่า Input จากผู้เล่น
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# 2. คำนวณความเร็ว (Velocity)
	if direction:
		# ถ้ามีการกดปุ่ม ให้กำหนดความเร็วตามทิศทางและความเร็วที่กำหนด
		velocity = direction * speed
		# (เสริม) ถ้าเธออยากให้กระทงหมุนตามทิศทางที่เคลื่อนที่
		# rotation = direction.angle()
	else:
		# ถ้าไม่มี input ให้ค่อยๆ ชะลอความเร็ว (จำลองแรงต้านของน้ำ)
		# การใช้ lerp ช่วยให้การชะลอเป็นไปอย่างราบรื่น
		velocity = velocity.lerp(Vector2.ZERO, delta * 5.0)

	# 3. ใช้ move_and_slide() เพื่อเคลื่อนที่กระทงและจัดการการชน
	move_and_slide()
	pass
