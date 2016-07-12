Parse.Cloud.define("push", function (request, response) {
    var query;
    var toUser = request.params.toUser; // this is the id of target user
    console.log(request.user);
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
            response.success("Success!");
        },
        error: function (error) {
            response.error("Error! " + error.message);
        }
    });
});