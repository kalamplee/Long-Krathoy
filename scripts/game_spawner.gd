# GameSpawner.gd
# โค้ดสำหรับจัดการการเกิดของ Collector
extends Node2D

@export var krathong_path: NodePath = "../krathong"
var krathong_player: CharacterBody2D = null

# ตัวจับเวลาสำหรับการเกิดของศัตรู
var spawn_timer: Timer = Timer.new()

# ช่วงเวลาการเกิด (วินาที)
@export var spawn_interval: float = 1.0
# ขนาดหน้าจอเกม
const SCREEN_SIZE: Vector2 = Vector2(512, 512)

# ฟังก์ชันที่สร้างตำแหน่งการเกิดแบบสุ่มที่ขอบจอ
func get_random_spawn_position() -> Vector2:
	# 0: Top, 1: Bottom, 2: Left, 3: Right
	var side = randi_range(0, 3)
	var pos: Vector2 = Vector2.ZERO
	
	match side:
		0: # Top Edge (y=0)
			pos.x = randf_range(0, SCREEN_SIZE.x)
			pos.y = -10 # เกิดนอกขอบจอนิดหน่อย
		1: # Bottom Edge (y=512)
			pos.x = randf_range(0, SCREEN_SIZE.x)
			pos.y = SCREEN_SIZE.y + 10
		2: # Left Edge (x=0)
			pos.x = -10
			pos.y = randf_range(0, SCREEN_SIZE.y)
		3: # Right Edge (x=512)
			pos.x = SCREEN_SIZE.x + 10
			pos.y = randf_range(0, SCREEN_SIZE.y)
			
	return pos

func _ready() -> void:
	# 1. หา Node กระทงผู้เล่น
	krathong_player = get_node(krathong_path)
	if krathong_player == null:
		push_error("Krathong Player not found at path: %s" % krathong_path)
		return
	
	# 2. (Optional) ลองสร้าง Collector ล่วงหน้า 5 ตัว
	if CollectorPool:
		CollectorPool.pre_populate_pool(5)
	
	# 3. ตั้งค่า Timer สำหรับการเกิด
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.autostart = true
	spawn_timer.connect("timeout", _on_spawn_timer_timeout)

# เมื่อ Timer หมดเวลา ให้สั่งให้ Collector เกิด
func _on_spawn_timer_timeout() -> void:
	if krathong_player and CollectorPool:
		# 1. สุ่มตำแหน่งการเกิดที่ขอบจอ
		var start_pos = get_random_spawn_position()
		
		# 2. ตำแหน่งเป้าหมาย (ใช้ตำแหน่งของผู้เล่น ณ ขณะเกิด)
		var target_pos = krathong_player.global_position
		
		# 3. สั่งให้ Pool สร้าง/เรียกใช้ Collector
		CollectorPool.spawn_collector(start_pos, target_pos)
		
		# (เสริม) ปรับค่า Timer เพื่อให้เกมยากขึ้นเรื่อยๆ
		# spawn_timer.wait_time = max(0.2, spawn_timer.wait_time - 0.01)
