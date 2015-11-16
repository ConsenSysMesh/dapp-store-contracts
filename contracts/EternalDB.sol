contract EternalDB {
  address public admin;
  mapping (uint => uint[])[] data;

  modifier restricted { if (msg.sender == admin) _ }

  function EternalDB() {
    admin = msg.sender;
    data.length = 1; // 1-indexed, so things like mappings to ids will work
  }

  function transfer_ownership(address _admin) restricted {
    admin = _admin;
  }

  function count() constant returns(uint) {
    return data.length - 1;
  }

  function has(uint id) constant returns(bool) {
    return id <= count();
  }

  function new_entry() restricted returns(uint) {
    return data.length++;
  }

  function add(uint id, uint key, uint value) restricted {
    uint[] attribute = data[id][key];
    attribute[attribute.length++] = value;
  }

  function get_length(uint id, uint key) constant returns(uint) {
    return data[id][key].length;
  }

  function get_entry(uint id, uint key, uint index) constant returns(uint) {
    return data[id][key][index];
  }

  function get_all(uint id, uint key) constant returns(uint[]) {
    return data[id][key];
  }

  function clear(uint id, uint key) restricted {
    data[id][key].length = 0;
  }

  function delete_entry(uint id, uint key, uint index) restricted {
    uint[] attribute = data[id][key];

    for (uint i = index; i + 1 < attribute.length; i++) {
      attribute[i] = attribute[i + 1];
    }

    attribute.length--;
  }
}
