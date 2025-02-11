// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FundToken {
    //通证的名字
    //通证的简称
    //通证的发行数量
    //通证的Owner
    //balance：记录每个address有通证的数量

    //函数1：mint：铸造通证
    //函数2：transfer通证
    //函数3：balanceOf：查看某一个addr的通证数量

    string public tokenName;//通证的名字
    string public tokenSymbol;//通证的简称
    uint256 public tokenTotalSupply;//通证的发型数量
    address public owner;//通证的owner
    mapping(address => uint256) public balances;

    constructor(string memory _tokenName, string memory _tokenSymbol) {
        tokenName=_tokenName;
        tokenSymbol=_tokenSymbol;
        owner=msg.sender;
    }

    function mint(uint256 amountToMint) public {
        balances[msg.sender] += amountToMint;
        tokenTotalSupply += amountToMint;
    }

    function transfer(address payee, uint256 amount) public {
        require(balances[msg.sender]>=amount, "You do not enough balance to transfer");
        balances[msg.sender] -= amount;
        balances[payee] += amount;
    }

    function balanceOf(address addr) public view returns(uint256) {
        return balances[addr];
    }
}