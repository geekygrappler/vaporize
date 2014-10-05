$ ->
	# Declare user object
	user =
		subscription:
			price: undefined,
			bottles: undefined,
			flavours:
				1: undefined
		cigarette: true

	### Functions ###

	# Return true if all questions have been answered and the user object is complete
	signupComplete = ->
		user.cigarette != undefined && user.subscription.price != undefined && allFlavoursPicked()

	showSubscription = ->
		showOneMonth()
		$("#offer").removeClass("hidden")
		$('html, body').animate({
			scrollTop: $("#offer").offset().top
		}, 1000);

	showOneMonth = ->
		$(".one-month").find(".price").html("£" + user.subscription.price + "/month")
		if user.cigarette == true
			$(".one-month").find(".cigarette-offer").html("£25 for the e-cigarette kit")
			$(".one-month").find(".pricing-explanation").html("Your first payment will be £" +
					(user.subscription.price + 25) + " to pay for your e-cigarette kit. After this you will pay £" +
					user.subscription.price + " per month.");
		else
			$(".one-month").find(".pricing-explanation").html("You will simply pay £" + user.subscription.price + " per month
			                      for your e-liquid.")

	moveToNextQuestion = (next) ->
		$('html, body').animate({
			scrollTop: $(next).offset().top
		}, 1000);

	showNavigationArrows = ->
		$(".prev-question, .next-question").delay(1000).fadeIn(500)

	# Checks whether the number of flavours required by the subscription have been picked
	allFlavoursPicked = ->
		flavoursCount = user.subscription.bottles
		for i in [1..flavoursCount]
			if user.subscription.flavours[i] == undefined
				return false
		return true

	### Hide stuff on load ###
	$(".prev-question, .next-question, #subscriptionLevel, .e-liquid-box-4, .e-liquid-box-5").hide()
	$("#showMeTheMoney").attr("disabled", true)

	### Listeners ###

	# When anything changes on the form.
	$('#subscription').on 'change', (e) ->
		# Do you have an e-cigarette?
		if $(e.target).data('question') == 'e-cigarette'
			cigaretteprice = $('input:radio[name = "e-cigarette"]:checked').val()

			# Assign cigarette choice to user object
			if cigaretteprice == "true"
				user.cigarette = true
				$("#subscriptionLevel").hide()
				$("#dailyCigarettes").show()
			else
				user.cigarette = false
				$("#dailyCigarettes").hide()
				$("#subscriptionLevel").show()

			moveToNextQuestion('#eLiquid')

		# How much e-liquid do you want?
		if $(e.target).data('question') == 'subscription level'
			user.subscription.price =  parseInt($(e.target).val())
			# empty the flavours object to avoid allowing user to submit a strange set of flavours
			user.subscription.flavours = 1: undefined
			$("#showMeTheMoney").attr("disabled", true)
			# Get bottle number from subscription price. Horrible way to do it, but here's the mapping
			if user.subscription.price == 12
				user.subscription.bottles = 3
				$(".e-liquid-box-4, .e-liquid-box-5").hide()
				$(".e-liquid-box-3").show()
			else if user.subscription.price == 15
				user.subscription.bottles = 4
				$(".e-liquid-box-3, .e-liquid-box-5").hide()
				$(".e-liquid-box-4").show()
			else
				user.subscription.bottles = 5
				$(".e-liquid-box-3, .e-liquid-box-4").hide()
				$(".e-liquid-box-5").show()
			moveToNextQuestion('#flavours')

		if $(e.target).data('question') == "flavour"
			pickNumber = $(e.target).attr("id").split("-")[1]
			user.subscription.flavours[pickNumber] = $(e.target).val()
			# TODO this is shit, can do much better, have done. Check that all subscriptions are full.
			if signupComplete()
				$("#showMeTheMoney").attr("disabled", false)

		showNavigationArrows()

	# TODO all of this shit can be put into a library and use data-attributes to move to the next/prev question.
	$(".prev-question").on 'click', (e) ->
		e.preventDefault()
		currentQuestion = $(e.target).parents(".row").attr("id")

		if currentQuestion == "eLiquid"
			moveToNextQuestion("#eCigarette")
		else if currentQuestion == "flavours"
			moveToNextQuestion("#eLiquid")
		else if currentQuestion == "offer"
			moveToNextQuestion("#flavours")

	$(".next-question").on 'click', (e) ->
		currentQuestion = $(e.target).parents(".row").attr("id")

		if currentQuestion == "eCigarette"
			moveToNextQuestion("#eLiquid")
		else if currentQuestion == "eLiquid"
			moveToNextQuestion("#flavours")

	$("#showMeTheMoney").on 'click', (e) ->
		e.preventDefault()
		showSubscription()