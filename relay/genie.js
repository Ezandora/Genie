function genieButtonClicked(id, command, hash)
{
	//choice.php?pwd=&option=1&whichchoice=1267&wish=the+wish
	
	//window.location.assign()
	
	var wish = "";
	if (command != "")
		wish = command;
	else
	{
		if (id == "monster_selection_button")
		{
			//monster_selection_div
			var desired_target = document.getElementById("monster_selection_div").value;
			
			if (desired_target != "-1" && desired_target != "")
			{
				wish = "I was fighting a " + desired_target;
			}
		}
		else if (id == "effect_selection_button" || id == "avatar_selection_button")
		{
			//effect_selection_div
			//avatar_selection_div
			var selection_div = "effect_selection_div";
			if (id == "avatar_selection_button")
				selection_div = "avatar_selection_div";
			var desired_target = document.getElementById(selection_div).value;
			if (desired_target != "-1" && desired_target != "")
			{
				wish = "to be " + desired_target;
			}
			//console.log("Want effect \"" + desired_target + "\"");
		}
	}
	
	if (wish != "")
		console.log("Wishing for \"" + wish + "\".");// from " + id + ".");
	
	if (wish != "")
	{
		var form = document.createElement("form");
		form.setAttribute("method", "POST");
		form.setAttribute("action", "choice.php");
		
		var parameters = {"pwd":hash, "option":"1", "whichchoice":"1267", "wish":wish};
		
		for (var key in parameters)
		{
			if (!parameters.hasOwnProperty(key)) continue;
			var input = document.createElement("input");
			input.setAttribute("type", "hidden");
			input.setAttribute("name", key);
			input.setAttribute("value", parameters[key]);
			form.appendChild(input);
		}
			
		document.body.appendChild(form);
		form.submit();
		/*var encoded_wish = encodeURIComponent(wish).replace(/%20/g, "+");
		
		var url = "choice.php?pwd=" + hash + "&option=1&whichchoice=1267&wish=" + encoded_wish;
		console.log("url = \"" + url + "\"");*/
		//window.location.assign(url);
	}
}

function genieSelectionChanged(div_id)
{
	var new_image_src = "";
	
	var selection_div = document.getElementById(div_id);
	var option_div = selection_div.options[selection_div.selectedIndex];
	
	new_image_src = option_div.getAttribute("data-replacement-image");
	
	//new_image_src = "images/otherimages/witchywoman.gif";
	if (new_image_src.length > 0)
		document.getElementById("genie_image").src = new_image_src;
}