//This contract below is Basic ERC token. It provides basic functionality to transfer tokens, 
//as well as allow tokens to be approved so they can be spent by another on-chain third party.

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.0;

interface ERC20Interface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256 balance);
    function transfer(address to, uint256 tokens) external returns (bool success);
    function allowance(address tokenOwner, address spender) external view returns (uint256 remaining);
    function approve(address spender, uint256 tokens) external returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) external returns (bool success);
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}
contract Sample is ERC20Interface {
    string public name;
    string public symbol;
    uint8 public decimals; 
    
    uint256 public _totalSupply;
    mapping (address => uint256) public balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    /**
     * Constrctor function
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {
        name = "Sample";
        symbol = "SS";
        decimals = 18;
        _totalSupply = 1500000000000000000000000;
        
        balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }
    //Returns the total token supply.
    function totalSupply() override public view returns (uint256) {
        return _totalSupply  - balances[address(0)];
    }
    //Returns the account balance of another account with address tokenowner
    function balanceOf(address tokenOwner) override public view returns (uint256 balance) {
        return balances[tokenOwner];
    }
    //Returns the amount which spender is still allowed to withdraw from tokenOwner
    function allowance(address tokenOwner, address spender) override public view returns (uint256 remaining) {
        return allowed[tokenOwner][spender];
    }
    //Allows spender to withdraw from your account multiple times, up to the token amount
    function approve(address spender, uint256 tokens) override public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    //Transfers token amount of tokens to address to
    function transfer(address to, uint256 tokens) override public returns (bool success) {
        if (balances[msg.sender] >= tokens && tokens > 0){
            balances[msg.sender] -= tokens;
            balances[to] += tokens;
            emit Transfer(msg.sender, to, tokens);
            return true;
        }
        else{ return false;}   
        
    }
    //Transfers token amount of tokens from address from to address to
    function transferFrom(address from, address to, uint256 tokens) override public returns (bool success) {
       
        if (balances[from] >= tokens && allowed[from][msg.sender] >= tokens && tokens> 0) {
            balances[to] += tokens;
            balances[from] -= tokens;
            allowed[from][msg.sender] -= tokens;
            emit Transfer(from, to, tokens);
            return true;
        } else { return false; }

    }
  
    /* Functions below are specific to this sample token and
     * not part of the ERC-20 standard */
    function deposit() public payable returns (bool success) {
        if (msg.value == 0) return false;
        balances[msg.sender] += msg.value;
        _totalSupply += msg.value;
        return true;
    }


    function withdraw(uint256 amount) public {
       require(balances[msg.sender] >= amount); 
       (bool sent, ) = msg.sender.call{value: amount}(""); 
       balances[msg.sender] -= amount; 
  }  

}
