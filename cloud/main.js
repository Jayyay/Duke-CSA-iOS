Parse.Cloud.define("push", function (request, response) {
    var query, targetUser;
    var toUser = request.params.toUser; // this is the id of target user
    if (request.user && request.user.id == toUser) {
        return;
    }
    if (toUser) {
        targetUser = new Parse.User();
        targetUser.id = toUser;
        query = new Parse.Query(Parse.Installation)   
        query.equalTo('user', targetUser);
    }

    Parse.Push.send({
        where: query,
        channels: request.params.channels,
        data: request.params.data
    }, {
        useMasterKey: true,
        success: function () {
            if (targetUser) {
                var NotifData = Parse.Object.extend("NotifData");
                var qry = new Parse.Query(NotifData);
                var type = request.params.data.notifType;
                var instanceID = request.params.data.PFInstanceID;
                qry.equalTo('UserID', targetUser.id);
                console.log("query for notif data set up");
                qry.find({
                    success: function (results) {
                        console.log("found " + results.length + " notif data");
                        var notifData;
                        if (results.length == 0) {
                            notifData = new NotifData();
                            notifData.set("UserID", targetUser.id);
                        } else {
                            notifData = results[0];
                        }
                        var notifOfType = notifData.get(type);
                        console.log(notifOfType);
                        if (!notifOfType) {
                            notifData.set(type, []);
                            notifOfType = notifData.get(type);
                        }
                        if (!notifOfType.includes(instanceID)) {
                            notifOfType.push(instanceID);
                        }
                        console.log(notifOfType);
                        notifData.save(null, {
                            success: function(user) {
                                console.log("user notif data saved.");
                                response.success("Successfully pushed notification to " + user.get("displayName") 
                            + " with type " + type + " and id " + instanceID);
                            },
                            error: function(user, error) {
                                console.log("saving user notif data error: " + error.message);
                                response.error("saving user notif data error " + error.message);
                            }
                        });
                    },
                    error: function (error) {
                        response.error("Error when finding notif data " + error.message);
                    }
                });
            }
        },
        error: function (error) {
            response.error("Error! " + error.message);
        }
    });
});

// request.params.type can be "Question" or "Answer"
Parse.Cloud.define("mostPosts", function (request, response) {
    var posters = {};
    var type = request.params.type;
    var query = new Parse.Query("QAPost");
    query.find({
        success: function(results) {
            console.log("Successfully retrieved " + results.length + " posts.");
            // Do something with the returned Parse.Object values
            for (var i = 0; i < results.length; i++) {
                var post = results[i];
                if (post.get("type") != type) continue;
                var author = post.get("author").id;
                if (!posters[author]) posters[author] = 0;
                posters[author]++;
            }
            var max = 0, most;
            var people = Object.keys(posters);
            for (var i = 0; i < people.length; i++) {
                if (posters[people[i]] > max) {
                    max = posters[people[i]];
                    most = people[i];
                }
            }
            console.log(Object.keys(posters));
            console.log(most);
            var User = Parse.Object.extend("_User");
            var qry = new Parse.Query(User);
            qry.get(most, {
                success: function (user) {
                    var result = {"user": user, "max": max};
                    response.success(result);
                }
            })
        },
        error: function(error) {
            console.log("Error: " + error.code + " " + error.message);
        }
    });
});

// request.params.type can be "Question" or "Answer"
Parse.Cloud.define("mostVote", function (request, response) {
	var posters = [];
	var type = request.params.type;
	var query = new Parse.Query("QAPost");
	query.find({
		success: function(results) {
			console.log("Successfully retrieved " + results.length + " posts.");
			for (var i = 0; i < results.length; i++) {
				var post = results[i];
				if (post.get("type") != type) continue;
				var author = post.get("author").id;
				if (!posters[author]) posters[author] = 0;
				posters[author] += post.get("vote");
			}
			var max = 0, most;
			var people = Object.keys(posters);
			for (var i = 0; i < people.length; i++) {
				if (posters[people[i]] > max) {
					max = posters[people[i]];
					most = people[i];
				}
			}
			console.log(Object.keys(posters));
			console.log(most);
			var User = Parse.Object.extend("_User");
            var qry = new Parse.Query(User);
            qry.get(most, {
                success: function (user) {
                    var result = {"user": user, "max": max};
                    response.success(result);
                }
            })
		},
		error: function(error) {
			console.log("Error: " + error.code + " " + error.message);
		}
	});
});
