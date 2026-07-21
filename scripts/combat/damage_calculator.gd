class_name DamageCalculator

static func calculate(attacker_atk: int, defender_def: int, crit_chance: float = 0.05, crit_multiplier: float = 1.5) -> Dictionary:
	var base_damage: float = attacker_atk
	var reduction: float = defender_def * 0.4
	var damage: float = maxf(1.0, base_damage - reduction)
	var is_crit: bool = randf() < crit_chance
	if is_crit:
		damage *= crit_multiplier
	var variance: float = randf_range(0.9, 1.1)
	damage *= variance
	return {
		"damage": int(damage),
		"is_crit": is_crit,
	}

static func scale_enemy(enemy_data: UnitData, wave: int) -> Dictionary:
	var multiplier: float = 1.0 + (wave - 1) * 0.15
	return {
		"max_hp": int(enemy_data.max_hp * multiplier),
		"attack": int(enemy_data.attack * multiplier),
		"defense": int(enemy_data.defense * multiplier),
	}
