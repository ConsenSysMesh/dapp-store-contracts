contract DualIndex {
  mapping(uint => mapping(uint => uint)) data;
  address public admin;

  modifier restricted { if (msg.sender == admin) _ }

  function DualIndex() {
    admin = msg.sender;
  }

  function set(uint key1, uint key2, uint value) restricted {
    data[key1][key2] = value;
  }

  function transfer_ownership(address _admin) restricted {
    admin = _admin;
  }

  function lookup(uint key1, uint key2) returns(uint) {
    return data[key1][key2];
  }
}
