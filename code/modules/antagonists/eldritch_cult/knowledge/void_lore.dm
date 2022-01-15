/datum/eldritch_knowledge/base_void
	name = "Мерцание Зимы"
	desc = "Открывает перед вами Путь Пустоты. Позволяет трансмутировать кухонный нож при минусовой температуре в Пустотный Клинок."
	gain_text = "Я чувствую мерцание в воздухе, атмосфера вокруг меня становится холоднее. Я чувствую, как мое тело осознает пустоту существования. Что-то наблюдает за мной"
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/final/ash_final,/datum/eldritch_knowledge/final/flesh_final,/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/final/rust_final)
	next_knowledge = list(/datum/eldritch_knowledge/void_grasp)
	required_atoms = list(/obj/item/kitchen/knife)
	result_atoms = list(/obj/item/melee/sickly_blade/void)
	cost = 1
	route = PATH_VOID

/datum/eldritch_knowledge/base_void/recipe_snowflake_check(list/atoms, loc)
	. = ..()
	var/turf/open/turfie = loc
	if(turfie.GetTemperature() > T0C)
		return FALSE

/datum/eldritch_knowledge/void_grasp
	name = "Хватка Пустоты"
	desc = "Временно заглушает вашу жертву, а также снижает температуру ее тела."
	gain_text = "Я нашел холодного наблюдателя, который следит за мной. Резонанс холода нарастает во мне. Это еще не конец тайны."
	cost = 1
	route = PATH_VOID
	next_knowledge = list(/datum/eldritch_knowledge/cold_snap)

/datum/eldritch_knowledge/void_grasp/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon_target = target
	var/turf/open/turfie = get_turf(carbon_target)
	turfie.TakeTemperature(-20)
	carbon_target.adjust_bodytemperature(-40)
	carbon_target.silent += 4
	return TRUE

/datum/eldritch_knowledge/void_grasp/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	var/datum/status_effect/eldritch/E = H.has_status_effect(/datum/status_effect/eldritch/rust) || H.has_status_effect(/datum/status_effect/eldritch/ash) || H.has_status_effect(/datum/status_effect/eldritch/flesh)  || H.has_status_effect(/datum/status_effect/eldritch/void)
	if(!E)
		return
	E.on_effect()
	H.silent += 3

/datum/eldritch_knowledge/cold_snap
	name = "Путь Аристократа"
	desc = "Делает вас невосприимчивым к холодным температурам, и вы больше не испытываете потребность в дыхание, вы все еще можете получить урон от низкого давления."
	gain_text = "Я услышал отголоски холодного дыхания. Это привело меня к странному святилищу, полностью сделанному из кристаллов. Полупрозрачное и белое изображение дворянина стояло передо мной."
	cost = 1
	route = PATH_VOID
	next_knowledge = list(/datum/eldritch_knowledge/void_cloak,/datum/eldritch_knowledge/void_mark,/datum/eldritch_knowledge/armor)

/datum/eldritch_knowledge/cold_snap/on_gain(mob/user)
	. = ..()
	ADD_TRAIT(user,TRAIT_RESISTCOLD,MAGIC_TRAIT)
	ADD_TRAIT(user, TRAIT_NOBREATH, MAGIC_TRAIT)

/datum/eldritch_knowledge/cold_snap/on_lose(mob/user)
	. = ..()
	REMOVE_TRAIT(user,TRAIT_RESISTCOLD,MAGIC_TRAIT)
	REMOVE_TRAIT(user, TRAIT_NOBREATH, MAGIC_TRAIT)

/datum/eldritch_knowledge/void_cloak
	name = "Плащ Пустоты"
	desc = "Плащ, который может становиться невидимым по желанию, скрывая предметы, которые вы храните в нем. Чтобы создать его, трансмутируйте осколок стекла, любой предмет одежды, который вы можете надеть поверх униформы, и любой тип простыни."
	gain_text = "Сова - хранительница вещей, которые совсем не являются таковыми на практике, но в теории являются."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/flesh_ghoul,/datum/eldritch_knowledge/cold_snap)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/void)
	required_atoms = list(/obj/item/shard,/obj/item/clothing/suit,/obj/item/bedsheet)

/datum/eldritch_knowledge/void_mark
	name = "Метка Пустоты"
	gain_text = "Порыв ветра? Может быть, мерцание в воздухе. Присутствие ошеломляет, мои чувства предали меня, мой разум - мой враг."
	desc = "Ваша хватка накладывает Метку Пустоты при попадании. Ударьте отмеченного человека своим клинком, чтобы значительно снизить температуру его тела."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/void_phase)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/flesh_mark)
	route = PATH_VOID

/datum/eldritch_knowledge/void_mark/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!isliving(target))
		return
	. = TRUE
	var/mob/living/living_target = target
	living_target.apply_status_effect(/datum/status_effect/eldritch/void)

/datum/eldritch_knowledge/spell/void_phase
	name = "Фаза Пустоты"
	gain_text = "Реальность сгибается под властью памяти, ибо все мимолетно, а что еще остается?"
	desc = "Вы можете телепортироваться, создаст пузырь урона 3x3 вокруг указанного вами пункта назначения и вашего текущего местоположения. Он имеет минимальный диапазон из 3 тайлов и максимальный диапазон из 9 плиток."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/pointed/void_blink
	next_knowledge = list(/datum/eldritch_knowledge/rune_carver,/datum/eldritch_knowledge/crucible,/datum/eldritch_knowledge/void_blade_upgrade)
	route = PATH_VOID

/datum/eldritch_knowledge/rune_carver
	name = "Нож для резьбы"
	gain_text = "Выгравированный, вырезанный... вечный. Я могу вырезать монолит и призвать их силы!"
	desc = "Вы можете создать нож для резьбы, который позволяет создавать до 3 рун на полу, которые оказывают различное воздействие на неверующих, которые ходят по ним. Также нож можно использовать в качестве метательного оружия. Чтобы создать разделочный нож, трансмутируйте нож, осколок стекла и лист бумаги."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/spell/void_phase,/datum/eldritch_knowledge/summon/raw_prophet)
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/shard,/obj/item/paper)
	result_atoms = list(/obj/item/melee/rune_knife)

/datum/eldritch_knowledge/crucible
	name = "Тигель"
	gain_text = "Это чистая агония, я не смог вызвать изгнание императора, но я наткнулся на другой рецепт..."
	desc = "Позволяет создать тигель, сверхъестественную структуру, которая позволяет создавать зелья различных эффектов, для этого трансмутируйте стол и канистру с водой."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/spell/void_phase,/datum/eldritch_knowledge/spell/area_conversion)
	required_atoms = list(/obj/structure/reagent_dispensers/watertank,/obj/structure/table)
	result_atoms = list(/obj/structure/eldritch_crucible)

/datum/eldritch_knowledge/void_blade_upgrade
	name = "Ищущий Клинок"
	gain_text = "Мимолетные воспоминания. Я могу отметить свой путь замерзшей кровью на снегу. Прикрытый и забытый."
	desc = "Теперь вы можете использовать свой клинок на удаленной отмеченной цели, чтобы телепортироваться к ней и атаковать её."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/voidpull)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/rust_blade_upgrade)
	route = PATH_VOID

/datum/eldritch_knowledge/void_blade_upgrade/on_ranged_attack_eldritch_blade(atom/target, mob/user, click_parameters)
	. = ..()
	if(!ishuman(target) || !iscarbon(user))
		return
	var/mob/living/carbon/carbon_human = user
	var/mob/living/carbon/human/human_target = target
	var/datum/status_effect/eldritch/effect = human_target.has_status_effect(/datum/status_effect/eldritch/rust) || human_target.has_status_effect(/datum/status_effect/eldritch/ash) || human_target.has_status_effect(/datum/status_effect/eldritch/flesh) || human_target.has_status_effect(/datum/status_effect/eldritch/void)
	if(!effect)
		return
	var/dir = angle2dir(dir2angle(get_dir(user,human_target))+180)
	carbon_human.forceMove(get_step(human_target,dir))
	var/obj/item/melee/sickly_blade/blade = carbon_human.get_active_held_item()
	blade.melee_attack_chain(carbon_human,human_target)

/datum/eldritch_knowledge/spell/voidpull
	name = "Пустотная Тяга"
	gain_text = "Это существо называет себя аристократом, я близок к тому, чтобы закончить то, что было начато."
	desc = "Вызовите пустоту, это притянет всех ближайших людей ближе к вам, оглушит людей, которые уже окружают вас. Если они стоят в диапазоне 4 тайлов или ближе, то их собьёт с ног и на мгновение оглушит."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/targeted/void_pull
	next_knowledge = list(/datum/eldritch_knowledge/final/void_final,/datum/eldritch_knowledge/spell/blood_siphon,/datum/eldritch_knowledge/summon/rusty)
	route = PATH_VOID

/datum/eldritch_knowledge/final/void_final
	name = "Вальс Конца Времён"
	desc = "Преобразуйте 3 трупа, чтобы вознестись. Теперь вы автоматически заставляете замолчать окружающих вас людей. Кроме того, вокруг вас образуется смертельная снежная буря. Шторм не причинит вреда вам."
	gain_text = "Мир погружается во тьму. Я стою в пустом самолете, с неба падают маленькие хлопья льда. Аристократ стоит передо мной, он дает мне знак. Мы сыграем вальс под шепот умирающей реальности, когда мир разрушится на наших глазах."
	cost = 3
	required_atoms = list(/mob/living/carbon/human)
	route = PATH_VOID
	///soundloop for the void theme
	var/datum/looping_sound/void_loop/sound_loop
	///Reference to the ongoing voidstrom that surrounds the heretic
	var/datum/weather/void_storm/storm

/datum/eldritch_knowledge/final/void_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	ADD_TRAIT(H, TRAIT_RESISTLOWPRESSURE, MAGIC_TRAIT)
	H.client?.give_award(/datum/award/achievement/misc/void_ascension, H)
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Пустотный Барин [H.real_name] прибыл, станцуй Вальс конца света! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", ANNOUNCER_SPANOMALIES) //Дворянин Пустоты, как варик

	sound_loop = new(user, TRUE, TRUE)
	return ..()

/datum/eldritch_knowledge/final/void_final/on_death()
	if(sound_loop)
		sound_loop.stop()
	if(storm)
		storm.end()
		QDEL_NULL(storm)

/datum/eldritch_knowledge/final/void_final/on_life(mob/user)
	. = ..()
	if(!finished)
		return

	for(var/mob/living/carbon/livies in spiral_range(7,user)-user)
		if(IS_HERETIC_MONSTER(livies) || IS_HERETIC(livies))
			return
		livies.silent += 1
		livies.adjust_bodytemperature(-20)

	var/turf/turfie = get_turf(user)
	if(!isopenturf(turfie))
		return
	var/turf/open/open_turfie = turfie
	open_turfie.TakeTemperature(-20)

	var/area/user_area = get_area(user)
	var/turf/user_turf = get_turf(user)

	if(!storm)
		storm = new /datum/weather/void_storm(list(user_turf.z))
		storm.telegraph()

	storm.area_type = user_area.type
	storm.impacted_areas = list(user_area)
	storm.update_areas()
