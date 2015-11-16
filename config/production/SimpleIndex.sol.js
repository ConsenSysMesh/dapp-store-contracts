"use strict";

var _get = function get(_x, _x2, _x3) { var _again = true; _function: while (_again) { var object = _x, property = _x2, receiver = _x3; desc = parent = getter = undefined; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x = parent; _x2 = property; _x3 = receiver; _again = true; continue _function; } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var factory = function factory(Pudding) {
  // Inherit from Pudding. The dependency on Babel sucks, but it's
  // the easiest way to extend a Babel-based class. Note that the
  // resulting .js file does not have a dependency on Babel.

  var SimpleIndex = (function (_Pudding) {
    _inherits(SimpleIndex, _Pudding);

    function SimpleIndex() {
      _classCallCheck(this, SimpleIndex);

      _get(Object.getPrototypeOf(SimpleIndex.prototype), "constructor", this).apply(this, arguments);
    }

    return SimpleIndex;
  })(Pudding);

  ;

  // Set up specific data for this class.
  SimpleIndex.abi = [{ "constant": false, "inputs": [{ "name": "key", "type": "uint256" }], "name": "lookup", "outputs": [{ "name": "", "type": "uint256" }], "type": "function" }, { "constant": false, "inputs": [{ "name": "key", "type": "uint256" }, { "name": "value", "type": "uint256" }], "name": "set", "outputs": [], "type": "function" }, { "constant": false, "inputs": [{ "name": "_admin", "type": "address" }], "name": "transfer_ownership", "outputs": [], "type": "function" }, { "constant": true, "inputs": [], "name": "admin", "outputs": [{ "name": "", "type": "address" }], "type": "function" }, { "inputs": [], "type": "constructor" }];
  SimpleIndex.binary = "606060405260018054600160a060020a0319163317905560d88060226000396000f3606060405260e060020a60003504630a874df6811460385780631ab06ee5146055578063f0350c04146089578063f851a4401460c7575b005b6004356000908152602081905260409020545b6060908152602090f35b603660043560243560015433600160a060020a039081169116141560855760008281526020819052604090208190555b5050565b603660043560015433600160a060020a039081169116141560c4576001805473ffffffffffffffffffffffffffffffffffffffff1916821790555b50565b604b600154600160a060020a03168156";

  if ("" != "") {
    SimpleIndex.address = "";

    // Backward compatibility; Deprecated.
    SimpleIndex.deployed_address = "";
  }

  SimpleIndex.generated_with = "1.0.2";
  SimpleIndex.contract_name = "SimpleIndex";

  return SimpleIndex;
};

// Nicety for Node.
factory.load = factory;

if (typeof module != "undefined") {
  module.exports = factory;
} else {
  // There will only be one version of Pudding in the browser,
  // and we can use that.
  window.SimpleIndex = factory;
}