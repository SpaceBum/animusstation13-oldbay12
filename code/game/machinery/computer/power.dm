// the power monitoring computer
// for the moment, just report the status of all APCs in the same powernet

/obj/machinery/power/monitor/attack_ai(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)

/obj/machinery/power/monitor/attack_hand(mob/user)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return
	interact(user)


/obj/machinery/power/monitor/proc/interact(mob/user)

	if ( (get_dist(src, user) > 1 ) || (stat & (BROKEN|NOPOWER)) )
		if (!istype(user, /mob/living/silicon))
			user.machine = null
			user << browse(null, "window=powcomp")
			return


	user.machine = src
	var/t = "<TT><B>Power Monitoring</B><HR>"


	if(!Networks[/obj/cabling/power])
		t += "\red No connection"
	else
		var/datum/UnifiedNetwork/PowerNetwork = Networks[/obj/cabling/power]
		var/datum/UnifiedNetworkController/PowernetController/Controller = PowerNetwork.Controller
		var/list/L = list()
		for(var/obj/machinery/power/terminal/term in PowerNetwork.Nodes)
			if(istype(term.master, /obj/machinery/power/apc))
				var/obj/machinery/power/apc/A = term.master
				L += A

		t += "<PRE>Total power: [Controller.TotalSupply()] W<BR>Total load:  [num2text(Controller.OldDraw,10)] W<BR>"

		t += "<FONT SIZE=-1>"

		if(L.len > 0)

			t += "Area                           Eqp./Lgt./Env.  Load   Cell<HR>"

			var/list/S = list(" Off","AOff","  On", " AOn")
			var/list/chg = list("N","C","F")

			for(var/obj/machinery/power/apc/A in L)

				t += copytext(add_tspace(A.area.name, 30), 1, 30)
				t += " [S[A.equipment+1]] [S[A.lighting+1]] [S[A.environ+1]] [add_lspace(A.lastused_total, 6)]  [A.cell ? "[add_lspace(round(A.cell.percent()), 3)]% [chg[A.charging+1]]" : "  N/C"]<BR>"

		t += "</FONT></PRE>"

	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A></TT>"
	//user << output(t,"pda_1")
	//winshow(user, "pda1",1)
	user << browse(t, "window=powcomp;size=420x700")
	onclose(user, "powcomp")


/obj/machinery/power/monitor/Topic(href, href_list)
	..()
	if( href_list["close"] )
		usr << browse(null, "window=powcomp")
		usr.machine = null
		return

/obj/machinery/power/monitor/process()
	if(!(stat & (NOPOWER|BROKEN)) )
		use_power(250)

	src.updateDialog()


/obj/machinery/power/monitor/power_change()

	if(stat & BROKEN)
		icon_state = "broken"
		ul_SetLuminosity(0,0,2)
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
			ul_SetLuminosity(0,0,2)
		else
			spawn(rand(0, 15))
				src.icon_state = "c_unpowered"
				stat |= NOPOWER
				ul_SetLuminosity(0,0,0)

