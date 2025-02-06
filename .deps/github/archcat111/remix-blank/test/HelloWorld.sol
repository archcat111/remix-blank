// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// contract关键字用来定义一个合约
contract HelloWorld {
	string strVal = "Hello World";  

    struct Info {
        string phrase;
        uint256 id;
        address addr;   //谁创建的该结构体元素
    }

    mapping(uint256 id => Info info) infoMapping;

    function setHelloWorld(string memory _newString, uint256 _id) public {
        //msg.sender：当前transaction发起的账户的addr
        Info memory info  = Info(_newString, _id, msg.sender);
        infoMapping[_id] = info;
    }
    
    function sayHello(uint256 _id) public view returns(string memory) {
        if(infoMapping[_id].addr == address(0x0)){
            return addInfo(strVal);
        }else{
            return addInfo(infoMapping[_id].phrase);
        }
    }

    function addInfo(string memory helloWorldStr) internal pure returns(string memory) {
        return string.concat(helloWorldStr, " from Frank's contract");
    }
}