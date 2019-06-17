pragma solidity ^0.4.23;
import "./ownable.sol";
contract MyVote is Ownable{
     string public subject; // 현재 Token의 남은 재고량 차감
     uint public totalProposals; // 현재 후보의 개수
     mapping (address => voter) public voters; // 투표자의 정보
     mapping (uint => proposal) public proposals; // 후보의 정보
     mapping (string => uint) internal proposalIndex; 
struct proposal {// 후보의 정보 저장
          string name; // 후보의 이름
          address proposer; // 후보를 제안한 사람의 ADDRESS
          uint numOfVotes; // 득표 수
     }
     struct voter {// 투표자의 정보 저장
          bool vote; // 투표를 했는지 저장
          string votedProposal; // 투표한 후보
     }
     constructor(string _subject) public{// 투표 CA를 생성할 때 투표에 대한 주제 설정
          subject = _subject; 
          totalProposals = 0;
     }
     modifier alreadyVoted() {//투표자가 이미 투표를 했는지 체크
          require(voters[msg.sender].vote == false);
          _;
     }
     function killcontract() onlyOwner public {
          selfdestruct(owner);
     }
function propose(string _proposalName)public alreadyVoted {// 후보 등록과 동시에 후보에 투표
          uint nullUint;
          uint _proposalIndex = proposalIndex[_proposalName];
require(_proposalIndex == nullUint && keccak256(proposals[_proposalIndex].name) != keccak256(_proposalName)); // 후보 중복 체크
proposals[totalProposals].name = _proposalName; // 후보 이름 등록
proposals[totalProposals].proposer = msg.sender; // 후보자 등록
proposals[totalProposals].numOfVotes = 1; // 후보에 투표
proposalIndex[_proposalName] = totalProposals; // 후보에 대한 INDEX 설정
voters[msg.sender].vote = true; // 후보를 제안한 EOA의 투표 여부 설정
voters[msg.sender].votedProposal = _proposalName; // 투표한 후보 설정
totalProposals++; // 총 후보의 수 증가
}
function vote(string _proposalName)public alreadyVoted {// 후보에 대한 투표, 이미 투표했는지 체크
uint _proposalIndex = proposalIndex[_proposalName]; // 후보를 찾기 위한 INDEX찾기 및 설정
require(keccak256(proposals[_proposalIndex].name) == 	keccak256(_proposalName)); // 투표 하려는 후보가 맞는지 체크

proposals[_proposalIndex].numOfVotes ++; // 후보에 투표
voters[msg.sender].vote = true; // 후보자 정보의 이미 투표를 했는지 설정
voters[msg.sender].votedProposal = _proposalName;
}
}