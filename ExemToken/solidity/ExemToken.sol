pragma solidity ^0.4.0;

import "./ownable.sol";

contract ExemToken is Ownable {
    string public name      = "ExemToken";
    string public symbol    = "ET";    
    uint24 public totalET   = 100000 ;
    uint8  public decimals  = 17     ; // 1ETH = 10ET
    uint   public balanceET = 100000 ;
    uint   public ETPrice   = 10 ** 17;
    uint   public salesStatus;
    uint   public startTime;
    uint   public deadline;
    
    mapping (address => uint) public balanceOf;

    constructor (uint _salesMinutes) public{   
        startTime = now;
        deadline  = startTime + _salesMinutes * 1 minutes;
    }        

    event Transfer(address indexed _from, address indexed _to, uint _value, uint _time);

    modifier meetDeadline() {
        require(now < deadline);
        _;
    }

    function transfer(address _to, uint _value) public{
        require(balanceOf[msg.sender] >= _value);                
        balanceOf[msg.sender] -= _value;                    
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value, now);
    }

    function transferFrom(address _from, address _to, uint _value) public{
        require(balanceOf[_from] >= _value);                
        balanceOf[_from] -= _value;                    
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value, now);
    }

    function () payable external meetDeadline {
        uint amountET = msg.value / ETPrice;
        require(balanceET >= amountET );
        balanceOf[msg.sender]+= amountET;
        salesStatus+=amountET;
        balanceET -= amountET;
    }  

    function withdraw(uint _amount) onlyOwner public{ 
        require(now > deadline); 
        msg.sender.transfer(_amount);
    }
    
    function refunds() public meetDeadline {
        balanceET += balanceOf[msg.sender];
        uint ethValue = (balanceOf[msg.sender] * ETPrice);
        balanceOf[msg.sender] = 0;
        msg.sender.transfer(ethValue); 
    }

    function killcontract() onlyOwner public {
        selfdestruct(owner);
    }
}

