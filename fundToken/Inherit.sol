// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Parent {
    uint256 public a;

    function addOne() public virtual  {
        a++;
    }

}

contract child is Parent {
    function addTwo() public {
        a+=2;
    }

    function addOne() public override  {
        a++;
    }
}