extends RefCounted
const SHEET := preload("res://assets/retro_shooter/sheet.png")
static var coin_frames: Array[Texture2D] = []
static var rifle: AtlasTexture
static var energy: AtlasTexture

static func _crop(region: Rect2) -> AtlasTexture:
	var result := AtlasTexture.new()
	result.atlas = SHEET
	result.region = region
	result.filter_clip = true
	return result

static func coin(time: float, phase: float) -> Texture2D:
	if coin_frames.is_empty():
		for center in [66,172,279,386,494,609,729,843,969]:
			coin_frames.append(_crop(Rect2(center-44,410,88,108)))
	return coin_frames[posmod(int((time+phase)*10.0),coin_frames.size())]

static func rifle_round() -> Texture2D:
	if rifle == null: rifle = _crop(Rect2(242,52,80,34))
	return rifle

static func energy_round() -> Texture2D:
	if energy == null: energy = _crop(Rect2(224,195,164,62))
	return energy
