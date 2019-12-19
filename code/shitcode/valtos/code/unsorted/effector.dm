/datum/looping_sound/effector_vaper
	start_sound = 'sound/machines/shower/shower_start.ogg'
	start_length = 2
	mid_sounds = list('sound/machines/shower/shower_mid1.ogg'=1,'sound/machines/shower/shower_mid2.ogg'=1,'sound/machines/shower/shower_mid3.ogg'=1)
	mid_length = 10
	end_sound = 'sound/machines/shower/shower_end.ogg'
	volume = 7

/obj/effector
	name = "парилка"
	desc = "Парит. Гы."
	icon = 'code/shitcode/valtos/icons/effector.dmi'
	icon_state = "effector"
	var/datum/looping_sound/effector_vaper/soundloop

/obj/effector/Initialize()
	. = ..()
	emmit()
	soundloop = new(list(src), active)
	soundloop.start()

/obj/effector/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/effector/proc/emmit()
	while(TRUE)
		var/obj/effect/vaper_smoke/S = new(get_turf(src))
		animate(S, pixel_y = 64, pixel_x = rand(-12, 12), transform = matrix()*2, alpha = 0, time = 40)
		sleep(7)

/obj/effect/vaper_smoke
	alpha = 60
	layer = FLY_LAYER
	icon = 'code/shitcode/valtos/icons/effector.dmi'
	icon_state = "smoke"

/obj/effect/vaper_smoke/Initialize()
	. = ..()
	spawn(80)
		qdel(src)
