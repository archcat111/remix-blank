// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//1：创建一个收款函数
//2：记录投资人并且查看
//3：设置每次投资的最小值
//4：最小值使用USD而不是ETH
//5：在锁定期内，没有达到目标值，投资人在锁定期后退款
contract FundMe {

    mapping(address => uint256) public fundersToAmount; //投资人以及投资金额

    uint256 MINIMUM_VALUE = 100 * 10 ** 18; //USD

    AggregatorV3Interface internal dataFeed;

    //构造函数，在合约初始化的时候运行一次，之后不会再运行
    constructor() { 
        //如果要使用任何第三方的服务就不能够在本地网络中进行测试运行，因为本地chain中没有该第三方服务将自己的合约部署到该chain上
        //所以这里可以使用ChainLink在sepolia网络中部署的Aggregator合约的Address
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306); //sepolia
    }

    function fund() external payable {
        require(convertEthToUsd(msg.value)>=MINIMUM_VALUE, "Send more ETH, The minimum ETH value is one"); //revert
        fundersToAmount[msg.sender] = msg.value;
    }

    //获取ETH的价格
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    function convertEthToUsd(uint256 _ethAmount) internal view returns(uint256) {
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        // ETH / USD：10^8wei的价格
        // XXX / ETH：10^18wei的价格
        return _ethAmount * ethPrice/(10**8); //_ethAmount的单位是wei
    }
}