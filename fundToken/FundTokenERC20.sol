// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {FundMe} from "../fundMe/FundMe.sol";


// FundMe的投资人，可以基于mapping中记录的投资金额 领取相应数据的 通证
// FundMe的投资人，可以transfer 通证
// FundMe的投资人，在使用完成通证后，需要burn通证
contract FundTokenERC20 is ERC20 {

    FundMe fundMe;
    
    constructor(address fundMeAddr) ERC20("FundTokenERC20", "FT") {
        // FundTokenERC20 合约并不是在部署 FundMe 合约，而是依赖于一个已经部署的 FundMe 合约实例
        // 因此，FundTokenERC20 只需要知道 FundMe 合约的部署地址（fundMeAddr），并通过该地址与 FundMe 合约交互
        // 这里是将 fundMeAddr 地址指向的 已经部署的FundMe合约 实例 赋值给 fundMe 变量
        fundMe = FundMe(fundMeAddr);
    }

    function mint(uint256 amountToMint) public {
        //该投资人想要铸造的token数量必须<=投资人的投资金额
        require(fundMe.fundersToAmount(msg.sender) >= amountToMint, "You can not mint this many tokens");
        require(fundMe.getFundSuccess(), "The FundMe is not completed yet");

        //铸造Token
        _mint(msg.sender, amountToMint);

        //修改fundme合约中该投资人剩余没有兑换token的投资金额
        fundMe.setFunderToAmount(msg.sender, fundMe.fundersToAmount(msg.sender) - amountToMint);
    }

    //transfer函数可以直接使用ERC20中的transfer函数
    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `value`.
     */
    // function transfer(address to, uint256 value) public virtual returns (bool) {
    //     address owner = _msgSender();
    //     _transfer(owner, to, value);
    //     return true;
    // }

    //投资人使用ERC20的Token找生产商兑换商品
    function claim(uint256 amountToClaim) public {
        //complete claim  
        require(balanceOf(msg.sender) >= amountToClaim, "You dont have enough ERC20 tokens");
        require(fundMe.getFundSuccess(), "The FundMe is not completed yet");
        //TODO 具体的兑换逻辑

        //burn amountToClaim Tokens
        _burn(msg.sender, amountToClaim);
    }

}