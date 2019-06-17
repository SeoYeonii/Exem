pragma solidity ^0.4.23;
import "./ownable.sol";
contract MyVote is Ownable{
     string public subject; // ���� Token�� ���� ��� ����
     uint public totalProposals; // ���� �ĺ��� ����
     mapping (address => voter) public voters; // ��ǥ���� ����
     mapping (uint => proposal) public proposals; // �ĺ��� ����
     mapping (string => uint) internal proposalIndex; 
struct proposal {// �ĺ��� ���� ����
          string name; // �ĺ��� �̸�
          address proposer; // �ĺ��� ������ ����� ADDRESS
          uint numOfVotes; // ��ǥ ��
     }
     struct voter {// ��ǥ���� ���� ����
          bool vote; // ��ǥ�� �ߴ��� ����
          string votedProposal; // ��ǥ�� �ĺ�
     }
     constructor(string _subject) public{// ��ǥ CA�� ������ �� ��ǥ�� ���� ���� ����
          subject = _subject; 
          totalProposals = 0;
     }
     modifier alreadyVoted() {//��ǥ�ڰ� �̹� ��ǥ�� �ߴ��� üũ
          require(voters[msg.sender].vote == false);
          _;
     }
     function killcontract() onlyOwner public {
          selfdestruct(owner);
     }
function propose(string _proposalName)public alreadyVoted {// �ĺ� ��ϰ� ���ÿ� �ĺ��� ��ǥ
          uint nullUint;
          uint _proposalIndex = proposalIndex[_proposalName];
require(_proposalIndex == nullUint && keccak256(proposals[_proposalIndex].name) != keccak256(_proposalName)); // �ĺ� �ߺ� üũ
proposals[totalProposals].name = _proposalName; // �ĺ� �̸� ���
proposals[totalProposals].proposer = msg.sender; // �ĺ��� ���
proposals[totalProposals].numOfVotes = 1; // �ĺ��� ��ǥ
proposalIndex[_proposalName] = totalProposals; // �ĺ��� ���� INDEX ����
voters[msg.sender].vote = true; // �ĺ��� ������ EOA�� ��ǥ ���� ����
voters[msg.sender].votedProposal = _proposalName; // ��ǥ�� �ĺ� ����
totalProposals++; // �� �ĺ��� �� ����
}
function vote(string _proposalName)public alreadyVoted {// �ĺ��� ���� ��ǥ, �̹� ��ǥ�ߴ��� üũ
uint _proposalIndex = proposalIndex[_proposalName]; // �ĺ��� ã�� ���� INDEXã�� �� ����
require(keccak256(proposals[_proposalIndex].name) == 	keccak256(_proposalName)); // ��ǥ �Ϸ��� �ĺ��� �´��� üũ

proposals[_proposalIndex].numOfVotes ++; // �ĺ��� ��ǥ
voters[msg.sender].vote = true; // �ĺ��� ������ �̹� ��ǥ�� �ߴ��� ����
voters[msg.sender].votedProposal = _proposalName;
}
}