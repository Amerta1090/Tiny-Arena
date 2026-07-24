# Tiny Arena — Sprint Planning

## Overview

13 sprint, masing-masing scope kecil dan testable secara independen.
Cover Prioritas 1–5 dari analisis gameplay.
Setelah setiap sprint, build APK dan test di Android.

---

## Prioritas Map

| Prioritas | Sprint | Items |
|-----------|--------|-------|
| P1 — Wire Dead Code | 1–2 | Wave banner, overlay, shake, transitions |
| P2 — Gameplay Loop | 3–5 | Boss visual, enemy variety, HP carry-over |
| P3 — UI/UX | 6–7 | Shop stats, gold real-time, mobile touch |
| P4 — Polish & Game Feel | 8–9 | Hit-stop, flash, arrow fix, SFX, particles |
| P5 — New Features | 10–13 | Skill tree, wave preview, achievements, settings |

---

## Sprint 1 — Wave Banner
**Goal**: Tampilkan "WAVE N" di awal setiap wave.

### Tasks
1. `battle_scene_script.gd` — Di `_on_start_timer()`, spawn node dengan `wave_banner.gd` sebagai script
2. Panggil `show_wave_banner(GameState.current_wave)` setelah spawn
3. Test: mulai game → "WAVE 1" muncul di tengah layar dengan animasi scale-in

### Files
- `scenes/battle_scene_script.gd`

### Estimasi: ~10 baris

---

## Sprint 2 — Battle Overlay (Victory/Defeat)
**Goal**: Tampilkan "VICTORY" atau "DEFEAT" saat wave selesai.

### Tasks
1. `battle_manager.gd` — Di `_on_wave_cleared()`, spawn node dengan `battle_overlay.gd`, panggil `show_result("victory")`
2. `battle_manager.gd` — Di `_on_soldier_died()`, spawn node dengan `battle_overlay.gd`, panggil `show_result("defeat")`
3. Test: menang → "VICTORY" gold muncul 1.5s lalu shop. Kalah → "DEFEAT" merah muncul 2s lalu menu

### Files
- `scripts/systems/battle_manager.gd`

### Estimasi: ~15 baris

---

## Sprint 3 — Camera Shake
**Goal**: Hit/kill/boss ada camera shake.

### Tasks
1. `camera_effects.gd` — Pastikan `setup_camera()` dipanggil di `_ready()` (saat ini tidak dipanggil)
2. `unit.gd` — Di `take_damage()`, panggil `CameraEffects.shake_hit()`
3. `unit.gd` — Di `die()`, panggil `CameraEffects.shake_kill()`
4. `wave_spawner.gd` — Di `start_wave()`, cek `wave % 5 == 0` → panggil `CameraEffects.shake_boss()`
5. Test: kena hit → shake kecil. Kill → shake sedikit. Boss spawn → shake besar

### Files
- `scripts/autoload/camera_effects.gd`
- `scripts/units/unit.gd`
- `scripts/systems/wave_spawner.gd`

### Estimasi: ~10 baris

---

## Sprint 4 — Scene Transitions
**Goal**: Ganti scene pakai fade-to-black, bukan hard cut.

### Tasks
1. `main_menu.gd` — Ganti `get_tree().change_scene_to_file()` jadi `Transition.change_scene()`
2. `battle_scene_script.gd` — Di `_on_battle_lost()`, ganti `change_scene_to_file()` jadi `Transition.change_scene()`
3. `battle_scene_script.gd` — Di `_on_next_wave_pressed()`, ganti `change_scene_to_file()` jadi `Transition.change_scene()`
4. Test: quit → fade hitam → keluar. Kalah → fade hitam → menu. Next wave → fade hitam → battle baru

### Files
- `scenes/main_menu.gd`
- `scenes/battle_scene_script.gd`

### Estimasi: ~10 baris

---

## Sprint 5 — Boss Visual Differentiation
**Goal**: Boss keliatan beda dari grunt/brute.

### Tasks
1. `unit_data.gd` — Tambah field `boss_scale: float = 1.0` dan `boss_tint: Color = Color.WHITE`
2. `orc_boss.tres` — Set `boss_scale = 1.5`, `boss_tint = Color(1.0, 0.8, 0.3)` (emas)
3. `unit.gd` — Di `_ready()`, kalau `unit_data.boss_scale != 1.0` → apply scale ke AnimatedSprite2D
4. `unit.gd` — Di `_ready()`, apply `boss_tint` ke sprite modulate
5. Test: wave 5 → boss 1.5x lebih besar dengan tint emas. Grunt/Brute tetap normal

### Files
- `resources/unit_data/unit_data.gd`
- `resources/unit_data/orc_boss.tres`
- `scripts/units/unit.gd`

### Estimasi: ~15 baris

---

## Sprint 6 — Enemy Variety (Ranged Orc)
**Goal**: Tambah 1 tipe enemy baru: Orc Archer (ranged).

### Tasks
1. `orc_archer.tres` — Buat resource baru: HP rendah (40), ATK sedang (12), DEF rendah (1), speed lambat (25), range jauh (300), gold 15
2. `wave_spawner.gd` — Di `_get_wave_groups()`, tambah orc_archer muncul mulai wave 7, jumlah `wave / 6`
3. `orc.gd` — Tambah logic: kalau `unit_data.attack_range > 100`, jangan walk ke player, berhenti di range dan tembak (reuse arrow scene dari soldier)
4. Test: wave 7+ → ada orc yang berhenti di jarak jauh dan tembak panah ke player

### Files
- `resources/unit_data/orc_archer.tres` (baru)
- `scripts/systems/wave_spawner.gd`
- `scripts/units/orc.gd`

### Estimasi: ~40 baris

---

## Sprint 7 — HP Carry-Over & Partial Heal
**Goal**: HP tidak reset full antar wave. Ada healing terbatas.

### Tasks
1. `game_state.gd` — Hapus `current_hp = player_stats.max_hp` dari `start_battle()`
2. `game_state.gd` — Di `end_battle(true)`, heal `maxi(20, int(max_hp * 0.3))` (heal 30% atau minimal 20 HP)
3. `game_state.gd` — Pastikan HP ga melebihi max_hp setelah heal
4. `hud.gd` — HP label tampilkan warna berubah: hijau (>50%), kuning (25-50%), merah (<25%)
5. Test: sengaja kalah HP di wave 1, cek HP di wave 2 harusnya ~30% dari max. Ulangi sampai mati

### Files
- `scripts/autoload/game_state.gd`
- `scripts/ui/hud.gd`

### Estimasi: ~15 baris

---

## Sprint 8 — Game Over Screen
**Goal**: Ada layar Game Over proper dengan stats dan tombol Retry.

### Tasks
1. `battle_scene_script.gd` — Di `_on_battle_lost()`, buat game over UI (bukan langsung ke menu):
   - "GAME OVER" (merah, 32px)
   - "Wave reached: N" (putih)
   - "Gold earned: N" (emas)
   - Tombol "RETRY" → `reset_game()` lalu load battle.tscn
   - Tombol "MENU" → fade ke main_menu
2. `battle_overlay.gd` — Extend atau buat scene terpisah untuk game over (termasuk tombol)
3. Test: kalah → lihat stats → Retry mulai dari wave 1. Menu → kembali ke main menu

### Files
- `scenes/battle_scene_script.gd`
- `scripts/ui/battle_overlay.gd`

### Estimasi: ~50 baris

---

## Sprint 9 — Shop Stats & HP Display
**Goal**: Shop tampilkan current stats dan HP player.

### Tasks
1. `battle_scene_script.gd` — Di shop, tambah panel "Your Stats" di atas upgrade list:
   - ATK, DEF, Speed, Crit%, Max HP
   - Tampilkan angka aktual (bukan +5, tapi total stat)
2. `battle_scene_script.gd` — Tambah HP bar atau HP text di shop header: "HP: 65/100"
3. `battle_scene_script.gd` — Gold label update real-time saat beli (panggil `_update_gold_label()` langsung, jangan rebuild shop)
4. Test: beli upgrade ATK → stat ATK naik di panel. Gold berkurang实时. HP display sesuai

### Files
- `scenes/battle_scene_script.gd`

### Estimasi: ~45 baris

---

## Sprint 10 — Combat Polish (Hit-Stop, Flash, Arrow Fix)
**Goal**: Combat terasa lebih punchy.

### Tasks
1. `unit.gd` — Hit-stop: saat crit, freeze `get_tree().paused = true` selama 0.05s lalu resume
2. `unit.gd` — Flash effect: saat `take_damage()`, set `sprite.modulate = Color.RED` lalu tween kembali ke WHITE dalam 0.1s
3. `arrow.gd` — Tambah hit radius dari `20px` ke `28px`
4. `arrow.gd` — Arrow speed naik dari `350` ke `400`
5. Test: crit → ada pause sesaat. Kena damage → sprite flash merah. Arrow lebih jarang miss

### Files
- `scripts/units/unit.gd`
- `scripts/combat/arrow.gd`

### Estimasi: ~25 baris

---

## Sprint 11 — SFX Variation & Volume Balance
**Goal**: SFX tidak monoton. Volume lebih seimbang.

### Tasks
1. `audio_manager.gd` — Tambah method `play_sfx_varied(stream, base_db, pitch_range)` dengan pitch random `1.0 ± pitch_range`
2. `audio_manager.gd` — Ganti semua `play_sfx()` calls di `soldier.gd` dan `orc.gd` jadi `play_sfx_varied()`
3. `audio_manager.gd` — Set default: `hit ±0.1`, `arrow_shoot ±0.05`, `enemy_death ±0.15`
4. Test: dengarkan 10x arrow shoot → harusnya beda-beda pitch-nya. Tidak monoton

### Files
- `scripts/autoload/audio_manager.gd`
- `scripts/units/soldier.gd`
- `scripts/units/orc.gd`

### Estimasi: ~20 baris

---

## Sprint 12 — Passive Skill Tree
**Goal**: Tambah 3 passive skill baru yang bisa di-unlock di shop.

### Tasks
1. Buat 3 resource `.tres` baru:
   - `skill_lifesteal.tres` — Heal 5% max HP setiap kill. Wave 20, 500G
   - `skill_multi_shot.tres` — 20% chance tembak 2 arrow sekaligus. Wave 25, 600G
   - `skill_thorns.tres` — Melee attacker kena 3 damage. Wave 15, 350G
2. `soldier.gd` — Tambah logic multi-shot: kalau `has_skill("multi_shot")` dan `randf() < 0.2`, fire 2 arrow
3. `soldier.gd` — Tambah logic lifesteal: di `_on_arrow_hit()`, heal 5% max_hp
4. `orc.gd` — Tambah logic thorns: saat melee attack, kalau player `has_skill("thorns")`, orcs kena 3 damage
5. `battle_scene_script.gd` — Load 3 new upgrade resources ke `all_upgrades`
6. Test: unlock multi-shot → kadang tembak 2. Unlock thorns → orcs kena damage balik. Unlock lifesteal → HP naik tiap kill

### Files
- `resources/upgrade_data/skill_lifesteal.tres` (baru)
- `resources/upgrade_data/skill_multi_shot.tres` (baru)
- `resources/upgrade_data/skill_thorns.tres` (baru)
- `scripts/units/soldier.gd`
- `scripts/units/orc.gd`
- `scenes/battle_scene_script.gd`

### Estimasi: ~50 baris

---

## Sprint 13 — Enemy Wave Preview
**Goal**: Sebelum mulai wave, tampilkan preview enemy types.

### Tasks
1. `battle_scene_script.gd` — Di shop (sebelum "NEXT WAVE"), tambah baris "Next wave: 5 Grunts, 2 Brutes"
2. `wave_spawner.gd` — Tambah method `get_wave_preview(wave) -> String` yang return deskripsi wave
3. `wave_spawner.gd` — Format: "X Grunts" / "X Brutes" / "BOSS!" / "X Orc Archers"
4. Test: di shop, lihat preview → tekan next wave → composition harusnya sesuai preview

### Files
- `scripts/systems/wave_spawner.gd`
- `scenes/battle_scene_script.gd`

### Estimasi: ~25 baris

---

## Execution Order

```
Sprint  1 → Sprint  2 → Sprint  3 → Sprint  4 → Sprint  5 → Sprint  6 → Sprint  7
  ↓           ↓           ↓           ↓           ↓           ↓           ↓
 Wave        Victory     Camera      Fade        Boss        Ranged     HP
 Banner      Defeat      Shake       Transitions Visual      Orc        Carry-over

Sprint  8 → Sprint  9 → Sprint 10 → Sprint 11 → Sprint 12 → Sprint 13
  ↓           ↓           ↓           ↓           ↓           ↓
 Game Over   Shop        Combat      SFX         Skill       Wave
 Screen      Stats       Polish      Variation   Tree        Preview
```

Setiap sprint: edit → test → commit → push → build APK → tag
