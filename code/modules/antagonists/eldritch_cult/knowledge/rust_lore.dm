/datum/eldritch_knowledge/base_rust
	name = "Рассказ Кузнеца"
	desc = "Открывает перед вами Путь Ржавчины. Позволяет трансмутировать кухонный нож и любой мусор в Ржавый Клинок."
	gain_text = "\"Позвольте рассказать вам историю\", - сказал Кузнец, пристально вглядываясь в свой ржавый клинок."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/final/ash_final,/datum/eldritch_knowledge/final/flesh_final,/datum/eldritch_knowledge/final/void_final,/datum/eldritch_knowledge/base_void)
	next_knowledge = list(/datum/eldritch_knowledge/rust_fist)
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/trash)
	result_atoms = list(/obj/item/melee/sickly_blade/rust)
	cost = 1
	route = PATH_RUST

/datum/eldritch_knowledge/rust_fist
	name = "Хватка Ржавчины"
	desc = "Наделяет вашу хватку Мансуса способностью наносить огромный урон неорганике, заставляя её ржаветь, проржавевшие объекты будут разрушаться."
	gain_text = "На потолке Мансуса ржавчина растет, как мох на камне."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen)
	var/rust_force = 500
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava,/turf/open/chasm,/turf/open/floor/plating/rust))
	route = PATH_RUST

/datum/eldritch_knowledge/rust_fist/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	target.rust_heretic_act()
	return TRUE

/datum/eldritch_knowledge/rust_fist/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/datum/status_effect/eldritch/E = H.has_status_effect(/datum/status_effect/eldritch/rust) || H.has_status_effect(/datum/status_effect/eldritch/ash) || H.has_status_effect(/datum/status_effect/eldritch/flesh)  || H.has_status_effect(/datum/status_effect/eldritch/void)
		if(E)
			E.on_effect()
			H.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_EARS,ORGAN_SLOT_EYES,ORGAN_SLOT_LIVER,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_HEART),25)

/datum/eldritch_knowledge/spell/area_conversion
	name = "Агрессивное распространение"
	desc = "Распространяет ржавчину на близлежащие поверхности. Уже проржавевшие поверхности будут подвержены разрушению."
	gain_text = "Все мудрецы хорошо знают, что не следует трогать Связанного короля."
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/aoe_turf/rust_conversion
	next_knowledge = list(/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/curse/corrosion,/datum/eldritch_knowledge/crucible)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_regen
	name = "Походка Пиявки" //Как ещё это назвать я хз
	desc = "Пассивно исцеляет вас, когда вы находитесь на ржавой плитке."
	gain_text = "Сила была несравненной, неестественной. Кузнец улыбался."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/armor,/datum/eldritch_knowledge/essence)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_regen/on_life(mob/user)
	. = ..()
	var/turf/user_loc_turf = get_turf(user)
	if(!istype(user_loc_turf, /turf/open/floor/plating/rust) || !isliving(user))
		return
	var/mob/living/living_user = user
	living_user.adjustBruteLoss(-2, FALSE)
	living_user.adjustFireLoss(-2, FALSE)
	living_user.adjustToxLoss(-2, FALSE)
	living_user.adjustOxyLoss(-0.5, FALSE)
	living_user.adjustStaminaLoss(-2)
	living_user.AdjustAllImmobility(-5)

/datum/eldritch_knowledge/rust_mark
	name = "Метка Ржавчины"
	desc = "Ваша хватка Мансуса теперь накладывает Метку Ржавчины на жертву. Атакуйте пораженных своим Ржавым Клинком, чтобы активировать метку. При активации Метка имеет шанс нанести серьёзный вред оружию вашего врага.."
	gain_text = "Ржавые Холмы помогают тем, кто в этом остро нуждается, за определенную плату."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/area_conversion)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/flesh_mark,/datum/eldritch_knowledge/void_mark)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_mark/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(isliving(target))
		. = TRUE
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/rust)

/datum/eldritch_knowledge/rust_blade_upgrade
	name = "Ядовитый Клинок"
	gain_text = "Клинок проведет тебя сквозь плоть, если ты позволишь ему."
	desc = "Ваш Клинок теперь будет отравлять ваших врагов при попадании."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/spell/entropic_plume)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/void_blade_upgrade)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_blade_upgrade/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.reagents.add_reagent(/datum/reagent/eldritch, 5)

/datum/eldritch_knowledge/spell/entropic_plume
	name = "Шлейф Энтропии"
	desc = "Теперь вы можете вызвать дезориентирующий шлейф чистой энтропии, который ослепляет, отравляет и заставляет врагов атаковать друг друга. Он также поражает ржавчиной плитки, над которыми пролетел."
	gain_text = "Посланники Надежды, бойтесь Ржавоносца!"
	cost = 1
	spell_to_add = /obj/effect/proc_holder/spell/cone/staggered/entropic_plume
	next_knowledge = list(/datum/eldritch_knowledge/final/rust_final,/datum/eldritch_knowledge/spell/cleave,/datum/eldritch_knowledge/summon/rusty)
	route = PATH_RUST

/datum/eldritch_knowledge/armor
	name = "Ритуал Оружейника"
	desc = "Теперь вы можете создавать Сверхъестественные доспехи, трансмутируя стол и противогаз."
	gain_text = "Ржавые Холмы приветствовали Кузнеца своей щедростью."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen,/datum/eldritch_knowledge/cold_snap)
	required_atoms = list(/obj/structure/table,/obj/item/clothing/mask/gas)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch)

/datum/eldritch_knowledge/essence
	name = "Ритуал Священника"
	desc = "Теперь вы можете трансмутировать канистру с водой и осколок стекла в бутылку с обогащенной Богами водой."
	gain_text = "Это старый рецепт. Сова прошептала мне его."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen,/datum/eldritch_knowledge/spell/ashen_shift)
	required_atoms = list(/obj/structure/reagent_dispensers/watertank,/obj/item/shard)
	result_atoms = list(/obj/item/reagent_containers/glass/beaker/eldritch)

/datum/eldritch_knowledge/final/rust_final
	name = "Клятва Ржавоносца"
	desc = "Принесите 3 трупа на руну трансмутации. После того, как вы закончите ритуал, ржавчина будет втоматически распространяться с руны. Ваше исцеление от ржавчины ускорится в разы, и вы станете сильней и устойчивее в целом."
	gain_text = "Чемпион по ржавчине. Разрушитель стали. Бойтесь темноты, ибо пришел несущий Ржавчину! Ржавые Холмы, НАЗОВИТЕ МОЕ ИМЯ!!"
	cost = 3
	required_atoms = list(/mob/living/carbon/human)
	route = PATH_RUST

/datum/eldritch_knowledge/final/rust_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	var/mob/living/carbon/human/H = user
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	H.client?.give_award(/datum/award/achievement/misc/rust_ascension, H)
	priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Бойся коррозии, ибо Ржавоносец, [user.real_name] вознесся! Никто не сможет избежать разложения! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", ANNOUNCER_SPANOMALIES)
	new /datum/rust_spread(loc)
	return ..()


/datum/eldritch_knowledge/final/rust_final/on_life(mob/user)
	. = ..()
	var/turf/user_loc_turf = get_turf(user)
	if(!istype(user_loc_turf, /turf/open/floor/plating/rust) || !isliving(user) || !finished)
		return
	var/mob/living/carbon/human/human_user = user
	human_user.adjustBruteLoss(-4, FALSE)
	human_user.adjustFireLoss(-4, FALSE)
	human_user.adjustToxLoss(-4, FALSE)
	human_user.adjustOxyLoss(-2, FALSE)
	human_user.adjustStaminaLoss(-20)
	human_user.AdjustAllImmobility(-10)

/**
 * #Rust spread datum
 *
 * Simple datum that automatically spreads rust around it
 *
 * Simple implementation of automatically growing entity
 */
/datum/rust_spread
	var/list/edge_turfs = list()
	var/list/turfs = list()
	var/turf/centre
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/open/indestructible,/turf/closed/indestructible,/turf/open/space,/turf/open/lava,/turf/open/chasm))
	var/spread_per_sec = 6


/datum/rust_spread/New(loc)
	. = ..()
	centre = get_turf(loc)
	centre.rust_heretic_act()
	turfs += centre
	START_PROCESSING(SSprocessing,src)

/datum/rust_spread/Destroy(force, ...)
	STOP_PROCESSING(SSprocessing,src)
	return ..()

/datum/rust_spread/process(delta_time)
	var/spread_am = round(spread_per_sec * delta_time)

	if(edge_turfs.len < spread_am)
		compile_turfs()

	var/turf/T
	for(var/i in 0 to spread_am)
		if(!edge_turfs.len)
			continue
		T = pick(edge_turfs)
		edge_turfs -= T
		T.rust_heretic_act()
		turfs += T



/**
 * Compile turfs
 *
 * Recreates all edge_turfs as well as normal turfs.
 */
/datum/rust_spread/proc/compile_turfs()
	edge_turfs = list()
	var/list/removal_list = list()
	var/max_dist = 1
	for(var/turfie in turfs)
		if(!istype(turfie,/turf/closed/wall/rust) && !istype(turfie,/turf/closed/wall/r_wall/rust) && !istype(turfie,/turf/open/floor/plating/rust))
			removal_list +=turfie
		max_dist = max(max_dist,get_dist(turfie,centre)+1)
	turfs -= removal_list
	for(var/turfie in spiral_range_turfs(max_dist,centre,FALSE))
		if(turfie in turfs || is_type_in_typecache(turfie,blacklisted_turfs))
			continue
		for(var/line_turfie_owo in getline(turfie,centre))
			if(get_dist(turfie,line_turfie_owo) <= 1)
				edge_turfs += turfie
		CHECK_TICK
