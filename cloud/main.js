Parse.Cloud.define("push", function (request, response) {
    var query;
    var toUser = request.params.toUser; // this is the id of target user
    if (request.user && request.user.id == toUser) {
        return;
    }
    if (toUser) {
        var targetUser = new Parse.User();
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
            response.success("Successfully pushed notification.");
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
                var authorID = post.get("author").id;
                if (!posters[authorID]) posters[authorID] = 0;
                posters[authorID]++;
            }
            var max = 0, most = "hwAxx0IwM7";
            var people = Object.keys(posters);
            for (var i = 0; i < people.length; i++) {
                if (posters[people[i]] > max) {
                    max = posters[people[i]];
                    most = people[i];
                }
            }
            console.log(Object.keys(posters));
            console.log(most);
            var result = {"userID": most, "max": max};
            response.success(result);
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
				var authorID = post.get("author").id;
				if (!posters[authorID]) posters[authorID] = 0;
				posters[authorID] += post.get("vote");
			}
			var max = 0, most = "hwAxx0IwM7";
			var people = Object.keys(posters);
			for (var i = 0; i < people.length; i++) {
				if (posters[people[i]] > max) {
					max = posters[people[i]];
					most = people[i];
				}
			}
			console.log(Object.keys(posters));
			console.log(most);
			var result = {"userID": most, "max": max};
			response.success(result);
		},
		error: function(error) {
			console.log("Error: " + error.code + " " + error.message);
		}
	});
});
