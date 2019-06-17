pragma solidity ^0.4.21;

import "./ownable.sol";
import "./MyToken.sol";

contract Attendance is Ownable { 
   uint    public  count = 0; // �⼮���� ����
   uint    public  endTime; // ��ӽð� ���� 
   uint    public  lateFee; //  ������ 
   uint    private nulluint; 
   address public  tokenAddr; // �տ��� ������ TOKEN�� CA�ּ�

   event Attend(string name, address personAddress); // �⼮�� ��� log���
   event gotLateFee(string name, address personAddress, uint lateFee); // �������� log���

   struct Person {// �⼮�ϴ� ����� ����
      address personAddr; // EOA �ּ�
      string name; // �̸�
      uint countAttendance; // �⼮ Ƚ��
      uint lastAttendance; // ������ �⼮�� ��¥ 
   }
   
   mapping (address => uint) public peopleIndex; // �⼮���� Index��� 
   mapping (uint => Person) public people; // Index�� �̿��� �⼮���� ���� ���

   // �⼮�θ� ������ �� ������� �ð��� ����, Token�� �ּ� �Է� (��, ��, ������, ��ū �ּ�)
   constructor(uint _endHour, uint _endMinutes, uint _lateFee, address _tokenAddr) public {
      endTime = ((_endHour * 1 hours) + (_endMinutes * 1 minutes)) % 86400;
      tokenAddr = _tokenAddr;
      lateFee = _lateFee ;
   } 

   function attend(string _name) public {// �⼮(�̸� �Է�)
      if (peopleIndex[msg.sender] == nulluint){// ���ο� ������� üũ
         peopleIndex[msg.sender] = count;
         count++;
	 emit Attend(_name, msg.sender);

      }
   
       if((now + 9 hours) % 24 hours > endTime){// ������ �����ϴ��� üũ
          MyToken contractET = MyToken(tokenAddr); 
          contractET.transferFrom(msg.sender,address(this),lateFee); // �ش� CA�� ������ �۱�
       }

       Person storage _Person = people[peopleIndex[msg.sender]]; // �⼮���� ��ϵ� ���� �˻�
       require(_Person.lastAttendance + 12 hours < now); // ���������� �⼮�� �� 12�ð��� ������ �⼮ ����
       _Person.personAddr = msg.sender; // �⼮���� �ּ�
       _Person.name = _name; // �⼮���� �̸�
       _Person.countAttendance ++; // �⼮ Ƚ�� ����
       _Person.lastAttendance = now ; // ������ �⼮ ��¥
   }

   function rewards(uint _amount) public {// �⼮�� �� ��ŭ Token�� ����, 1 �⼮ = 1 Token
      Person storage _Person = people[peopleIndex[msg.sender]];
      require(_Person.countAttendance >= _amount); // �Է��� ���� �⼮ Ƚ������ ���ų� ������ üũ
      _Person.countAttendance -= _amount; // �⼮ Ƚ�� ����
      MyToken contractET = MyToken(tokenAddr);
      contractET.transferFrom(address(this),msg.sender,_amount); // �Է��� ��ŭ Token ����
   }
}