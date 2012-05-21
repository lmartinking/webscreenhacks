require("coffee-script")
var config = module.exports;

config["Tests"] = {
    tests: ["specs/**/*.spec.*"],
    environment: "node",
    testHelpers: ["specs/spec_helper.coffee"]
};
