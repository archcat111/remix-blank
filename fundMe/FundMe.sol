// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//1：创建一个收款函数
//2：记录投资人并且查看
//3：设置每次投资的最小值
//4：最小值使用USD而不是ETH
//5：修改owner
//6：筹款资金达到目标值，生产商可以提款
contract FundMe {

    mapping(address => uint256) public fundersToAmount; //投资人以及投资金额

    uint256 constant MINIMUM_VALUE = 100 * 10 ** 18; //USD
    uint256 constant TARGET = 200; //USD

    address owner;

    AggregatorV3Interface internal dataFeed;

    //构造函数，在合约初始化的时候运行一次，之后不会再运行
    constructor() { 
        //如果要使用任何第三方的服务就不能够在本地网络中进行测试运行，因为本地chain中没有该第三方服务将自己的合约部署到该chain上
        //所以这里可以使用ChainLink在sepolia网络中部署的Aggregator合约的Address
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306); //sepolia

        //设置owner的设置
        //将部署合约的人作为owner
        owner = msg.sender;
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

    function getFund() external {
        //限制可以调用该getFund()的人
        require(msg.sender == owner, "This function can only be call by owner");

        //address(this)表示当前合约
        //这里address(this).balance取到的值的单位是wei
        //需要将该合约中的ETH转换位USD来对比是否达到目标金额
        require(convertEthToUsd(address(this).balance) >= TARGET, "Target is not reached!");

        //将智能合约中的余额transfer到owner
        //// transfer方式
        //payable(msg.sender).transfer(address(this).balance);
        //// send方式
        //bool result = payable(msg.sender).send(address(this).balance);
        //require(result, "transfer failed");

        //// call方式
        bool result;
        (result, ) = payable(msg.sender).call{value: address(this).balance}("");
    }

    //修改owner
    function transferOwnerShip(address _newOwner) public {
        require(msg.sender == owner, "This function can only be call by owner");
        owner = _newOwner;
    }
}