pragma solidity ^0.4.23;
import "./ownable.sol";
import "./MyToken.sol";

contract VotingGame is Ownable{
     string public subject;
     uint public totalInstances; 
     uint    public endTime;
     uint    public Fee;
     address public tokenAddr;
     uint private counting;
     mapping (address => voter) public voters;
     mapping (uint => instance) public instances; 
     mapping (string => uint) internal instanceIndex;
    
     struct instance {
          string name;
          uint numOfVotes;
         
     }
     struct voter {
          bool vote;
          string votedinstance;
     }
    
constructor(uint _endHour, uint _endMinutes, uint _Fee, address _tokenAddr, string _subject) public {
        endTime = ((_endHour * 1 hours) + (_endMinutes * 1 minutes) - 9 hours) % 86400;
        totalInstances = 0;
        subject=_subject;
        tokenAddr = _tokenAddr;
         Fee = _Fee;

    }
     
     modifier alreadyVoted() { 
          require(voters[msg.sender].vote == false);
          _;
     }
     function killcontract() onlyOwner public {
          selfdestruct(owner);
     }

    function addinstance(string _instanceName) public onlyOwner {
        uint _instanceIndex = instanceIndex[_instanceName];
        instances[totalInstances].name = _instanceName;
    instances[totalInstances].numOfVotes = 0;
    instanceIndex[_instanceName] = totalInstances;
    voters[msg.sender].vote =false;
   
   
     totalInstances++;
     
      
  }
  
function vote(string _instanceName)public alreadyVoted {
   require(now > endTime);
uint _instanceIndex = instanceIndex[_instanceName];
instances[_instanceIndex].numOfVotes ++;
voters[msg.sender].vote = true;
voters[msg.sender].votedinstance = _instanceName;
 MyToken contractET = MyToken(tokenAddr);
        contractET.consume(msg.sender,Fee);
        
       
        
}
function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint i = 0; i < totalInstances; i++) {
            if (instances[i].numOfVotes > winningVoteCount) {
                winningVoteCount = instances[i].numOfVotes;
                winningProposal_ = i;
            }
        }
    }
function winner() public view
            returns (string _WinnerName)
    {
        _WinnerName = instances[winningProposal()].name;
    }
    // winningProposal() 함수를 호출하여
    // 제안 배열에 포함된 승자의 index를 가져온 다음
    // 승자의 이름을 반환합니다.
}