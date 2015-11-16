contract SimpleIndex {
  mapping(uint => uint) data;
  address public admin;

  modifier restricted { if (msg.sender == admin) _ }

  function SimpleIndex() {
    admin = msg.sender;
  }

  function set(uint key, uint value) restricted {
    data[key] = value;
  }

  function transfer_ownership(address _admin) restricted {
    admin = _admin;
  }

  function lookup(uint key) returns(uint) {
    return data[key];
  }
}
