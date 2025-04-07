extends Node2D

##################################################
const CHAIN_SCENE: PackedScene = preload("res://scenes/chain_platform/chain/chain.tscn")
const PLATFORM_SCENE: PackedScene = \
	preload("res://scenes/chain_platform/platform/platform.tscn")
# 체인 씬과 플랫폼 씬을 미리 로드
# 위 두 씬을 합쳐야 하나의 체인 플랫폼 씬이 완성됨

const CHAIN_SIZE: Vector2 = Vector2(0.0, 16.0)
# 각 체인+플랫폼 간의 간격

const CHAIN_LINK_COUNT: int = 6
# 체인의 링크 개수

##################################################
func _ready() -> void:
	init_chain_platform()
	# 체인과 플랫폼을 초기화하는 함수

##################################################
func init_chain_platform() -> void:
	var anchor: StaticBody2D = StaticBody2D.new()
	add_child(anchor)
	# 앵커를 생성하여 체인 위쪽을 고정
	
	var top_chain: RigidBody2D = CHAIN_SCENE.instantiate()
	top_chain.position = anchor.position + Vector2(0.0, 8.0)
	top_chain.set_collision_layer_value(1, false)
	top_chain.set_collision_mask_value(1, false)
	top_chain.set_collision_layer_value(2, true)
	top_chain.set_collision_mask_value(2, true)
	add_child(top_chain)
	# 첫 번째 체인 생성 및 설정
	# 플레이어가 있다면 서로 충돌하지 않도록 충돌 레이어와 마스크 설정
	
	var top_joint: PinJoint2D = PinJoint2D.new()
	top_joint.node_a = anchor.get_path()
	top_joint.node_b = top_chain.get_path()
	top_joint.position = (anchor.position + top_chain.position) * 0.5
	add_child(top_joint)
	# 첫 번째 핀 조인트를 생성하여 앵커와 첫 번째 체인을 연결
	
	var upper_chain: RigidBody2D = top_chain
	# 연결할 체인들 중 위 체인을 담을 변수
	
	for i in range(1, CHAIN_LINK_COUNT):
	# CHAIN_LINK_COUNT 만큼 반복
		var chain: RigidBody2D = CHAIN_SCENE.instantiate()
		chain.position = upper_chain.position + CHAIN_SIZE
		chain.set_collision_layer_value(1, false)
		chain.set_collision_mask_value(1, false)
		chain.set_collision_layer_value(2, true)
		chain.set_collision_mask_value(2, true)
		add_child(chain)
		# 연결할 체인 중 아래 체인을 생성 및 설정
		# 플레이어가 있다면 서로 충돌하지 않도록 충돌 레이어와 마스크 설정
		chain.add_to_group("Chain")
		# 키 입력 시 흔들기 위해 체인을 그룹에 추가
		
		var joint: PinJoint2D = PinJoint2D.new()
		joint.node_a = upper_chain.get_path()
		joint.node_b = chain.get_path()
		joint.position = \
			(upper_chain.position + chain.position) * 0.5
		add_child(joint)
		# 위 체인과 아래 체인을 연결하는 조인트 생성 및 설정
		# 위 아래 체인 중간 지점에 위치하도록 설정
		
		upper_chain = chain
		# 아래 체인을 upper_chain으로 설정
	
	var platform: RigidBody2D = PLATFORM_SCENE.instantiate()
	platform.position = upper_chain.position + CHAIN_SIZE
	platform.lock_rotation = true
	add_child(platform)
	# 가장 아래 위치할 발판 플랫폼 생성 및 설정
	
	var bottom_joint: PinJoint2D = PinJoint2D.new()
	bottom_joint.node_a = upper_chain.get_path()
	bottom_joint.node_b = platform.get_path()
	bottom_joint.position = (upper_chain.position + platform.position) * 0.5
	add_child(bottom_joint)
	# 가장 아래 체인과 발판을 연결하는 조인트 생성 및 설정
	# 체인과 발판의 중간 지점에 위치하도록 설정

##################################################
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
	# 스페이스나 엔터 키를 눌렀을 때
		for chain in get_tree().get_nodes_in_group("Chain"):
		# Chain 그룹인 노드를 찾아서
			var rand_i = randi_range(0, 1)
			if rand_i == 0:
				chain.apply_central_force(Vector2(10000.0, -1000.0))
			else:
				chain.apply_central_force(Vector2(-10000.0, -1000.0))
			# 좌우 우로 임의의 방향으로 힘을 가함
