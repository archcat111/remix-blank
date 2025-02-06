// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {HelloWorld} from "./HelloWorld.sol"; 

contract HelloWorldFactory {

    HelloWorld[] helloWorlds;

    function createHelloWorld() public {
        helloWorlds.push(new HelloWorld());
    }

    function getHelloWorldByIndex(uint256 _index) public view returns(HelloWorld){
        return helloWorlds[_index];
    }

    function callSayHelloFromFactory(uint256 _index, uint256 _id) public view returns(string memory) {
        return helloWorlds[_index].sayHello(_id);
    }

    function callSetHelloWorldFromFactory(uint256 _index, string memory _newString, uint256 _id) public {
        helloWorlds[_index].setHelloWorld(_newString, _id);
    }
}