Parse.initialize("Gfb36k13JiVKIcDDZAwjOAYUT1m6p1Nl0CddTq03", "QgvFQdy6cDzsB5PB6EZszPw3AEBkVamq95Y7dhm2");
Parse.serverURL = "https://parseapi.back4app.com";
var Event = Parse.Object.extend("Event");

function pictureChanged(picture) {
	if (!ValidateSingleInput(picture)) return;
	readPicture(picture);
}

function readPicture(input) {
	if (input.files && input.files[0]) {
		var reader = new FileReader();
		reader.onload = function (e) {
			$('#chosenPic').attr('src', e.target.result);
		}
		reader.readAsDataURL(input.files[0]);
		$('#chosenPic').show();
	}
}

var _validFileExtensions = [".jpg", ".png"];    
function ValidateSingleInput(oInput) {
    if (oInput.type == "file") {
        var sFileName = oInput.value;
         if (sFileName.length > 0) {
            var blnValid = false;
            for (var j = 0; j < _validFileExtensions.length; j++) {
                var sCurExtension = _validFileExtensions[j];
                if (sFileName.substr(sFileName.length - sCurExtension.length, sCurExtension.length).toLowerCase() == sCurExtension.toLowerCase()) {
                    blnValid = true;
                    break;
                }
            }
             
            if (!blnValid) {
                alert("Sorry, " + sFileName + " is invalid, allowed extensions are: " + _validFileExtensions.join(", "));
                oInput.value = "";
                return false;
            }
        }
    }
    return true;
}

function post() {
	var sure = confirm("Are you sure to post? This will be pushed to users.");
	if (!sure) return;
	var evt = new Event();
	evt.set("isValid", true);
	evt.set("title", $("input[name='title']")[0].value);
	evt.set("detail", $("textarea[name='detail']")[0].value);
	evt.set("where", $("input[name='location']")[0].value);

	var dateInput = $("input[type='date']")[0];
	var timeInput = $("input[type='time']")[0];
	var date = new Date();
	var offset = date.getTimezoneOffset();
	date = new Date(dateInput.valueAsNumber + timeInput.valueAsNumber + offset * 60000);
	evt.set("when", date);
	
	var loaded = document.getElementById("picture");
	var file = loaded.files[0];
	if (file) {
		var name = file.name;
		var parseFile = new Parse.File(name, file);
		evt.set("profilePic", parseFile);
	}

	if ($("#signupurl").is(':visible')) {
		evt.set("needToSignUp", true);
		evt.set("openForSignUp", true);
		evt.set("signUpUrl", $("input[name='url']")[0].value);
	}
	else {
		evt.set("needToSignUp", false);
	}

	evt.save().then( function (newEvent) {
		var push = {
    	"data": {
        "alert": {
            "title": "New Event!",
            "subtitle": date.toLocaleString(),
            "body": evt.get("title")
        },
        "badge": "Increment",
        "sound": "notif1.mp3",
        "message": "New Event",
        "notifType": "newEvent",
        "PFInstanceID": evt.id,
        "content-available": 1,
        "mutable-content": 1
    	}
		}
		return Parse.Cloud.run("push", push);
	}).then( function () {
		$("#description").text("New event successfully posted and pushed to users!");
		$("#description").css({"color": "#0d5d4d"});
		alert("New event successfully posted and pushed to users!");
	}, function(error) {
		$("#description").text("Error, contact developers.");
		$("#description").css({"color": "#5d0d1d"});
		alert("Error, contact developers.");
		console.log(error.message);
	});
}

$(document).ready(function() {
	$('input:radio[name="needSignUp"]').change(function() {
		console.log($(this).val());
		if ($(this).val() == "true") {
			$("#signupurl").show();
		}
		else {
			$("#signupurl").hide();
		}
	});

	$("#post").click(post);
});
