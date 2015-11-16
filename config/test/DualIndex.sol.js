"use strict";

var _get = function get(_x, _x2, _x3) { var _again = true; _function: while (_again) { var object = _x, property = _x2, receiver = _x3; _again = false; if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { _x = parent; _x2 = property; _x3 = receiver; _again = true; desc = parent = undefined; continue _function; } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } } };

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var factory = function factory(Pudding) {
  // Inherit from Pudding. The dependency on Babel sucks, but it's
  // the easiest way to extend a Babel-based class. Note that the
  // resulting .js file does not have a dependency on Babel.

  var DualIndex = (function (_Pudding) {
    _inherits(DualIndex, _Pudding);

    function DualIndex() {
      _classCallCheck(this, DualIndex);

      _get(Object.getPrototypeOf(DualIndex.prototype), "constructor", this).apply(this, arguments);
    }

    return DualIndex;
  })(Pudding);

  ;

  // Set up specific data for this class.
  DualIndex.abi = [{ "constant": false, "inputs": [{ "name": "key1", "type": "uint256" }, { "name": "key2", "type": "uint256" }, { "name": "value", "type": "uint256" }], "name": "set", "outputs": [], "type": "function" }, { "constant": false, "inputs": [{ "name": "key1", "type": "uint256" }, { "name": "key2", "type": "uint256" }], "name": "lookup", "outputs": [{ "name": "", "type": "uint256" }], "type": "function" }, { "constant": false, "inputs": [{ "name": "_admin", "type": "address" }], "name": "transfer_ownership", "outputs": [], "type": "function" }, { "constant": true, "inputs": [], "name": "admin", "outputs": [{ "name": "", "type": "address" }], "type": "function" }, { "inputs": [], "type": "constructor" }];
  DualIndex.binary = "606060405260018054600160a060020a0319163317905560f0806100236000396000f3606060405260e060020a600035046343b0e8df81146038578063b4b9d1f1146079578063f0350c041460a1578063f851a4401460df575b005b603660043560243560443560015433600160a060020a039081169116141560745760008381526020818152604080832085845290915290208190555b505050565b60043560009081526020818152604080832060243584529091529020545b6060908152602090f35b603660043560015433600160a060020a039081169116141560dc576001805473ffffffffffffffffffffffffffffffffffffffff1916821790555b50565b6097600154600160a060020a03168156";

  if ("" != "") {
    DualIndex.address = "";

    // Backward compatibility; Deprecated.
    DualIndex.deployed_address = "";
  }

  DualIndex.generated_with = "1.0.2";
  DualIndex.contract_name = "DualIndex";

  return DualIndex;
};

// Nicety for Node.
factory.load = factory;

if (typeof module != "undefined") {
  module.exports = factory;
} else {
  // There will only be one version of Pudding in the browser,
  // and we can use that.
  window.DualIndex = factory;
}