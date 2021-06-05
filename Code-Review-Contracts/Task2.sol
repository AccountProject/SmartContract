//SPDX MIT license identifier
pragma solidity ^0.7.0;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {  
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {  
    require(b!=0);
    uint256 c = a / b;  
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {  
    require(b <= a);  
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) { 
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}
// Simpler version of ERC20 interface
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// Basic version of StandardToken, with no allowances.
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;
  mapping(address => uint256) balances;
 //transfer token for a specified address
 function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value); 
    return true;
  }
//Gets the balance of the specified address.
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) internal allowed;
//Transfer tokens from one address to another
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0 && _value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);  
    return true;
  }
//Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);  
    return true;
  }
//Function to check the amount of tokens that an owner allowed to a spender.
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}
//The Ownable contract has an owner address, and provides basic authorization control
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
//The Ownable constructor sets the original `owner` of the contract to the sender
  constructor () public {  
    owner = msg.sender;
  }
}
//Base contract which allows children to implement an emergency stop mechanism.
contract Pausable is Ownable {
  event Pause();
  event Unpause();
  bool public paused = false;
// Modifier to make a function callable only when the contract is not paused.
  modifier whenNotPaused() {
    require(!paused);
    _;
  }
//Modifier to make a function callable only when the contract is paused.
  modifier whenPaused() {
    require(paused);
    _;
  }
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();  
  }
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();  
  }
}
//StandardToken modified with pausable transfers.
contract PausableToken is StandardToken, Pausable {
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
     return super.transfer(_to, _value);
  }
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
     return super.transferFrom(_from, _to, _value);
  }
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
     return super.approve(_spender, _value);
  }
  
  function batchTransfer(address[] _receivers, uint256 _value) public whenNotPaused returns (bool) {
    uint cnt = _receivers.length;
    uint256 amount = uint256(cnt) * _value;
    require(cnt > 0 && cnt <= 20);
    require(_value > 0 && balances[msg.sender] >= amount);
    balances[msg.sender] = balances[msg.sender].sub(amount);
    for (uint i = 0; i < cnt; i++) {
        balances[_receivers[i]] = balances[_receivers[i]].add(_value);
        emit Transfer(msg.sender, _receivers[i], _value);  
    }
    return true;
  }
}
contract Sample is PausableToken {
    string public name = "SampleChain";
    string public symbol = "SSC";
    string public version = '1.0.0';
    uint8 public decimals = 18;
    constructor() public {  
      totalSupply = 7000000000 * (10**(uint256(decimals)));
      balances[msg.sender] = totalSupply;   
    }
    function () external{   
        revert();
    }
}
