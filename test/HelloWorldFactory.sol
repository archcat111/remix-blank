// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 方法1：直接将HelloWorld.sol中的HelloWorld合约代码复制过来，一个sol文件中可以有多个contract

// 方法2：引入HelloWorld.sol文件，这里HelloWorld.sol在同目录下，这种方法会将HelloWorld.sol文件里的所有合约都引入进来
// import "./HelloWorld.sol"; 

// 方法3：只引入HelloWorld.sol文件中的HelloWorld合约
 import {HelloWorld} from "./HelloWorld.sol"; 

// 方法4：引入网络上的合约
// import {HelloWorld} from "https://github.com/archcat111/remix-blank/blob/main/test/HelloWorld.sol"; 

// 方法5：引入通过NPM安装的包中的合约
// import {HelloWorld} from "@companyName/product/contract"

contract HelloWorldFactory {

    HelloWorld helloWorld;

    function createHelloWorld() public {
        helloWorld = new HelloWorld();
    }
}