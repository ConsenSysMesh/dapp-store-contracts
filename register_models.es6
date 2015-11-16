var coordinator = ModelCoordinator.deployed();

var models = {
  "dapp": DappModel,
  "developer": DeveloperModel,
  "review": ReviewModel,
  "version": VersionModel,
  "attribute": AttributeModel,
  "license": LicenseModel,
  "user": UserModel
};

var registrations = [];
var model_names = Object.keys(models);

for (var i = 0; i < model_names.length; i++) {
  var name = model_names[i];
  var model = models[name].deployed();
  registrations.push(coordinator.register(web3.fromAscii(name), model.address, 0));
  registrations.push(model.set_coordinator(coordinator.address));
}

Promise.all(registrations).then(function() {
  process.exit();
}).catch(function(err) {
  console.log(err);
  process.exit(1);
})
