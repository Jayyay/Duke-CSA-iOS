
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
	console.log("Hello at", Date.now());
  response.success("Hello world!");
});
