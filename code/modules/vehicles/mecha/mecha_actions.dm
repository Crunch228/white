/***************** MECHA ACTIONS *****************/

/obj/vehicle/sealed/mecha/generate_action_type()
	. = ..()
	if(istype(., /datum/action/vehicle/sealed/mecha))
		var/datum/action/vehicle/sealed/mecha/mecha = .
		mecha.chassis = src


/datum/action/vehicle/sealed/mecha
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	var/obj/vehicle/sealed/mecha/chassis

/datum/action/vehicle/sealed/mecha/Destroy()
	chassis = null
	return ..()

/datum/action/vehicle/sealed/mecha/mech_eject
	name = "Выход из меха"
	button_icon_state = "mech_eject"

/datum/action/vehicle/sealed/mecha/mech_eject/Trigger()
	if(!owner)
		return
	if(!chassis || !(owner in chassis.occupants))
		return
	chassis.container_resist_act(owner)

/datum/action/vehicle/sealed/mecha/mech_toggle_internals
	name = "Переключить использование внутреннего бака"
	button_icon_state = "mech_internals_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_internals/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.use_internal_tank = !chassis.use_internal_tank
	button_icon_state = "mech_internals_[chassis.use_internal_tank ? "on" : "off"]"
	to_chat(chassis.occupants, "[icon2html(chassis, owner)]<span class='notice'>Теперь берём воздух из [chassis.use_internal_tank?"внутреннего бака":"окружения"].</span>")
	chassis.log_message("Now taking air from [chassis.use_internal_tank?"internal airtank":"environment"].", LOG_MECHA)
	UpdateButtonIcon()

/datum/action/vehicle/sealed/mecha/mech_cycle_equip
	name = "Сменить оборудование"
	button_icon_state = "mech_cycle_equip_off"

/datum/action/vehicle/sealed/mecha/mech_cycle_equip/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	var/list/available_equipment = list()
	for(var/e in chassis.equipment)
		var/obj/item/mecha_parts/mecha_equipment/equipment = e
		if(equipment.selectable)
			available_equipment += equipment

	if(available_equipment.len == 0)
		to_chat(owner, "[icon2html(chassis, owner)]<span class='warning'>Нет оборудования!</span>")
		return
	if(!chassis.selected)
		chassis.selected = available_equipment[1]
		to_chat(owner, "[icon2html(chassis, owner)]<span class='notice'>Выбрано: [chassis.selected].</span>")
		send_byjax(chassis.occupants,"exosuit.browser","eq_list",chassis.get_equipment_list())
		button_icon_state = "mech_cycle_equip_on"
		UpdateButtonIcon()
		return
	var/number = 0
	for(var/equipment in available_equipment)
		number++
		if(equipment != chassis.selected)
			continue
		if(available_equipment.len == number)
			chassis.selected = null
			to_chat(owner, "[icon2html(chassis, owner)]<span class='notice'>Выбрано: ничего.</span>")
			button_icon_state = "mech_cycle_equip_off"
		else
			chassis.selected = available_equipment[number+1]
			to_chat(owner, "[icon2html(chassis, owner)]<span class='notice'>Переключаюсь на [chassis.selected].</span>")
			button_icon_state = "mech_cycle_equip_on"
		send_byjax(chassis.occupants,"exosuit.browser","eq_list",chassis.get_equipment_list())
		UpdateButtonIcon()
		return


/datum/action/vehicle/sealed/mecha/mech_toggle_lights
	name = "Переключить свет"
	button_icon_state = "mech_lights_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_lights/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!(chassis.mecha_flags & HAS_LIGHTS))
		to_chat(owner, span_warning("Свет уничтожен, проклятье!"))
		return
	chassis.mecha_flags ^= LIGHTS_ON
	if(chassis.mecha_flags & LIGHTS_ON)
		button_icon_state = "mech_lights_on"
	else
		button_icon_state = "mech_lights_off"
	chassis.set_light_on(chassis.mecha_flags & LIGHTS_ON)
	to_chat(owner, "[icon2html(chassis, owner)]<span class='notice'>[(chassis.mecha_flags & LIGHTS_ON)?"Включаем":"Выключаем"] свет.</span>")
	chassis.log_message("Toggled lights [(chassis.mecha_flags & LIGHTS_ON)?"on":"off"].", LOG_MECHA)
	UpdateButtonIcon()

/datum/action/vehicle/sealed/mecha/mech_view_stats
	name = "Состояние"
	button_icon_state = "mech_view_stats"

/datum/action/vehicle/sealed/mecha/mech_view_stats/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	var/datum/browser/popup = new(owner , "exosuit")
	popup.set_content(chassis.get_stats_html(owner))
	popup.open()


/datum/action/vehicle/sealed/mecha/strafe
	name = "Переключить стрейф. Отключается, когда зажат Alt."
	button_icon_state = "strafe"

/datum/action/vehicle/sealed/mecha/strafe/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	chassis.toggle_strafe()

/obj/vehicle/sealed/mecha/AltClick(mob/living/user)
	if(!(user in occupants) || !user.canUseTopic(src))
		return
	if(!(user in return_controllers_with_flag(VEHICLE_CONTROL_DRIVE)))
		to_chat(user, span_warning("Неправильное место для взаимодействия с оборудованием!"))
		return

	toggle_strafe()

/obj/vehicle/sealed/mecha/proc/toggle_strafe()
	if(!(mecha_flags & CANSTRAFE))
		to_chat(occupants, "[icon2html(src, occupants)]<span class='notice'>Этот мех не поддерживает стрейф.</span>")
		return

	strafe = !strafe

	to_chat(occupants, "[icon2html(src, occupants)]<span class='notice'>Стрейф: [strafe?"включен":"выключен"].</span>")
	log_message("Toggled strafing mode [strafe?"on":"off"].", LOG_MECHA)

	for(var/occupant in occupants)
		var/datum/action/action = LAZYACCESSASSOC(occupant_actions, occupant, /datum/action/vehicle/sealed/mecha/strafe)
		action?.UpdateButtonIcon()

//////////////////////////////////////// Specific Ability Actions  ///////////////////////////////////////////////
//Need to be granted by the mech type, Not default abilities.

/datum/action/vehicle/sealed/mecha/mech_defense_mode
	name = "Переключить фронтальный энергощит"
	button_icon_state = "mech_defense_mode_off"

/datum/action/vehicle/sealed/mecha/mech_defense_mode/Trigger(forced_state = FALSE)
	SEND_SIGNAL(chassis, COMSIG_MECHA_ACTION_TRIGGER, owner, args) //Signal sent to the mech, to be handed to the shield. See durand.dm for more details

/datum/action/vehicle/sealed/mecha/mech_overload_mode
	name = "Переключить перегрузку ног"
	button_icon_state = "mech_overload_off"

/datum/action/vehicle/sealed/mecha/mech_overload_mode/Trigger(forced_state = null)
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!isnull(forced_state))
		chassis.leg_overload_mode = forced_state
	else
		chassis.leg_overload_mode = !chassis.leg_overload_mode
	button_icon_state = "mech_overload_[chassis.leg_overload_mode ? "on" : "off"]"
	chassis.log_message("Toggled leg actuators overload.", LOG_MECHA)
	if(chassis.leg_overload_mode)
		chassis.movedelay = min(1, round(chassis.movedelay * 0.5))
		chassis.step_energy_drain = max(chassis.overload_step_energy_drain_min,chassis.step_energy_drain*chassis.leg_overload_coeff)
		to_chat(owner, "[icon2html(chassis, owner)]<span class='danger'>Включаю перегрузку ног.</span>")
	else
		chassis.movedelay = initial(chassis.movedelay)
		chassis.step_energy_drain = chassis.normal_step_energy_drain
		to_chat(owner, "[icon2html(chassis, owner)]<span class='notice'>Выключаю перегрузку ног.</span>")
	UpdateButtonIcon()

/datum/action/vehicle/sealed/mecha/mech_smoke
	name = "Дым"
	button_icon_state = "mech_smoke"

/datum/action/vehicle/sealed/mecha/mech_smoke/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_MECHA_SMOKE) && chassis.smoke_charges>0)
		chassis.smoke_system.start()
		chassis.smoke_charges--
		TIMER_COOLDOWN_START(src, COOLDOWN_MECHA_SMOKE, chassis.smoke_cooldown)


/datum/action/vehicle/sealed/mecha/mech_zoom
	name = "Зум"
	button_icon_state = "mech_zoom_off"

/datum/action/vehicle/sealed/mecha/mech_zoom/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	if(owner.client)
		chassis.zoom_mode = !chassis.zoom_mode
		button_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
		chassis.log_message("Toggled zoom mode.", LOG_MECHA)
		to_chat(owner, "[icon2html(chassis, owner)]<font color='[chassis.zoom_mode?"blue":"red"]'>Режим зума: [chassis.zoom_mode?"включен":"отключен"].</font>")
		if(chassis.zoom_mode)
			owner.client.view_size.setTo(4.5)
			SEND_SOUND(owner, sound('sound/mecha/imag_enh.ogg',volume=50))
		else
			owner.client.view_size.resetToDefault() //Let's not let this stack shall we?
		UpdateButtonIcon()

/datum/action/vehicle/sealed/mecha/mech_switch_damtype
	name = "Перенастроить массив микроинструмента руки"
	button_icon_state = "mech_damtype_brute"

/datum/action/vehicle/sealed/mecha/mech_switch_damtype/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	var/new_damtype
	switch(chassis.damtype)
		if(TOX)
			new_damtype = BRUTE
			to_chat(owner, "[icon2html(chassis, owner)]<span class='notice'>Теперь рука будет бить.</span>")
		if(BRUTE)
			new_damtype = FIRE
			to_chat(owner, "[icon2html(chassis, owner)]<span class='notice'>Теперь рука будет жарить.</span>")
		if(FIRE)
			new_damtype = TOX
			to_chat(owner, "[icon2html(chassis, owner)]<span class='notice'>Теперь рука будет вводить токсины.</span>")
	chassis.damtype = new_damtype
	button_icon_state = "mech_damtype_[new_damtype]"
	playsound(chassis, 'sound/mecha/mechmove01.ogg', 50, TRUE)
	UpdateButtonIcon()

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing
	name = "Переключить фазирование"
	button_icon_state = "mech_phasing_off"

/datum/action/vehicle/sealed/mecha/mech_toggle_phasing/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return
	chassis.phasing = chassis.phasing ? "" : "фазирование"
	button_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	to_chat(owner, "[icon2html(chassis, owner)]<font color=\"[chassis.phasing?"#00f\">Включаем":"#f00\">Выключаем"] фазирование.</font>")
	UpdateButtonIcon()

///swap seats, for two person mecha
/datum/action/vehicle/sealed/mecha/swap_seat
	name = "Сменить место"
	button_icon_state = "mech_seat_swap"

/datum/action/vehicle/sealed/mecha/swap_seat/Trigger()
	if(!owner || !chassis || !(owner in chassis.occupants))
		return

	if(chassis.occupants.len == chassis.max_occupants)
		chassis.balloon_alert(owner, "другое место занято!")
		return
	var/list/drivers = chassis.return_drivers()
	chassis.balloon_alert(owner, "перелезаем...")
	chassis.is_currently_ejecting = TRUE
	if(!do_after(owner, chassis.has_gravity() ? chassis.exit_delay : 0 , target = chassis))
		chassis.balloon_alert(owner, "помешали!")
		chassis.is_currently_ejecting = FALSE
		return
	chassis.is_currently_ejecting = FALSE
	if(owner in drivers)
		chassis.balloon_alert(owner, "место стрелка")
		chassis.remove_control_flags(owner, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
		chassis.add_control_flags(owner, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
	else
		chassis.balloon_alert(owner, "место пилота")
		chassis.remove_control_flags(owner, VEHICLE_CONTROL_MELEE|VEHICLE_CONTROL_EQUIPMENT)
		chassis.add_control_flags(owner, VEHICLE_CONTROL_DRIVE|VEHICLE_CONTROL_SETTINGS)
	chassis.update_icon_state()
