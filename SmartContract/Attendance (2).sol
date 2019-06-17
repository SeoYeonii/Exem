pragma solidity ^0.4.21;

import "./ownable.sol";
import "./MyToken.sol";

contract Attendance is Ownable { 
   uint    public  count = 0; // 출석부의 정원
   uint    public  endTime; // 약속시간 설정 
   uint    public  lateFee; //  지각비 
   uint    private nulluint; 
   address public  tokenAddr; // 앞에서 생성한 TOKEN의 CA주소

   event Attend(string name, address personAddress); // 출석할 경우 log기록
   event gotLateFee(string name, address personAddress, uint lateFee); // 지각비의 log기록

   struct Person {// 출석하는 사람의 정보
      address personAddr; // EOA 주소
      string name; // 이름
      uint countAttendance; // 출석 횟수
      uint lastAttendance; // 마지막 출석한 날짜 
   }
   
   mapping (address => uint) public peopleIndex; // 출석자의 Index등록 
   mapping (uint => Person) public people; // Index를 이용한 출석자의 정보 등록

   // 출석부를 생성할 때 지각비와 시간을 설정, Token의 주소 입력 (시, 분, 지각비, 토큰 주소)
   constructor(uint _endHour, uint _endMinutes, uint _lateFee, address _tokenAddr) public {
      endTime = ((_endHour * 1 hours) + (_endMinutes * 1 minutes)) % 86400;
      tokenAddr = _tokenAddr;
      lateFee = _lateFee ;
   } 

   function attend(string _name) public {// 출석(이름 입력)
      if (peopleIndex[msg.sender] == nulluint){// 새로운 사람인지 체크
         peopleIndex[msg.sender] = count;
         count++;
	 emit Attend(_name, msg.sender);

      }
   
       if((now + 9 hours) % 24 hours > endTime){// 지각비를 내야하는지 체크
          MyToken contractET = MyToken(tokenAddr); 
          contractET.transferFrom(msg.sender,address(this),lateFee); // 해당 CA에 지각비 송금
       }

       Person storage _Person = people[peopleIndex[msg.sender]]; // 출석자의 등록된 정보 검색
       require(_Person.lastAttendance + 12 hours < now); // 마지막으로 출석한 지 12시간이 지나야 출석 가능
       _Person.personAddr = msg.sender; // 출석자의 주소
       _Person.name = _name; // 출석자의 이름
       _Person.countAttendance ++; // 출석 횟수 증가
       _Person.lastAttendance = now ; // 마지막 출석 날짜
   }

   function rewards(uint _amount) public {// 출석을 한 만큼 Token의 보상, 1 출석 = 1 Token
      Person storage _Person = people[peopleIndex[msg.sender]];
      require(_Person.countAttendance >= _amount); // 입력한 양이 출석 횟수보다 많거나 같은지 체크
      _Person.countAttendance -= _amount; // 출석 횟수 차감
      MyToken contractET = MyToken(tokenAddr);
      contractET.transferFrom(address(this),msg.sender,_amount); // 입력한 만큼 Token 지급
   }
}