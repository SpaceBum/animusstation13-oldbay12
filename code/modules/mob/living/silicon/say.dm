/mob/living/silicon/say(var/message)
	if (!message || muted || stat == 1)
		return

	if (stat == 2)
		message = trim(copytext(sanitize_spec(message), 1, MAX_MESSAGE_LEN))
		return say_dead(message)

	if (length(message) >= 2)
		if (copytext(message, 1, 3) == ":s")
			message = copytext(message, 3)
			message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			robot_talk(message)
		else if(copytext(message,1,2) == ";" && isrobot(src))
			message = copytext(message, 2)
			message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			radio_talk(message)
			return ..(message)
		else if(copytext(message,1,3) == ":h" && isrobot(src))
			message = copytext(message, 3)
			message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			secure_talk(message)
			return ..(message)
		else
			return ..(message)
	else
		return ..(message)

/mob/living/silicon/proc/radio_talk(var/message)
	if(src:radio)
		src:radio.talk_into(src,message)

/mob/living/silicon/proc/secure_talk(var/message)
	if(src:radio)
		src:radio.security_talk_into(src,message)

/mob/living/proc/robot_talk(var/message)

	log_say("[key_name(src)] : [message]")

	message = trim(message)

	if (!message)
		return

	var/message_a = say_quote(message)
	var/rendered = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"
	for (var/mob/living/silicon/S in world)
		if(!S.stat && S.client)
			S.show_message(rendered, 2)

	var/list/listening = hearers(1, src)
	listening -= src
	listening += src

	var/list/heard = list()
	for (var/mob/M in listening)
		if(!istype(M, /mob/living/silicon))
			heard += M


	if (length(heard))
		var/message_b

		message_b = "beep beep beep"
		message_b = say_quote(message_b)
		message_b = "<i>[message_b]</i>"

		rendered = "<i><span class='game say'><span class='name'>[voice_name]</span> <span class='message'>[message_b]</span></span></i>"

		for (var/mob/M in heard)
			M.show_message(rendered, 2)

	message = say_quote(message)

	rendered = "<i><span class='game say'>Robotic Talk, <span class='name'>[name]</span> <span class='message'>[message_a]</span></span></i>"

	for (var/client/C)
		if (istype(C.mob, /mob/new_player))
			continue
		if (C.mob.stat > 1)
			C.mob.show_message(rendered, 2)