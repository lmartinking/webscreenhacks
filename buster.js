require("coffee-script")
var config = module.exports;

config["Tests"] = {
    tests: ["specs/**/*.spec.*"],
    environment: "node",
    extensions: [require("buster-coffee")],
    testHelpers: ["specs/spec_helper.coffee"]
};

config["Browser"] = {
    tests: ["specs/**/*.spec.*"],
    sources: ["assets/js/**/*"],
    environment: "browser",
    extensions: [require("buster-coffee")],
    testHelpers: ["specs/spec_helper.coffee"]
};
