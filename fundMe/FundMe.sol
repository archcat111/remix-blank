// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//1：创建一个收款函数
//2：记录投资人并且查看
//3：设置每次投资的最小值
//4：最小值使用USD而不是ETH
//5：修改owner
//6：筹款资金达到目标值，生产商可以提款
//7：筹款资金没有达到目标值，投资人可以退款
//8：锁定期内达到目标值可以替换、锁定期外未达到目标值可以退款
contract FundMe {

    mapping(address => uint256) public fundersToAmount; //投资人以及投资金额

    uint256 constant MINIMUM_VALUE = 100 * 10 ** 18; //USD
    uint256 constant TARGET = 200; //USD

    address owner;
    uint256 deploymentTimestamp; //部署时间，单位为秒
    uint256 lockTime; //锁定时长，单位为秒

    address erc20Addr;
    bool public getFundSuccess = false; //生厂商是否成功获取所有的众筹金额

    AggregatorV3Interface internal dataFeed;

    //构造函数，在合约初始化的时候运行一次，之后不会再运行
    constructor(uint256 _lockTime) { 
        //如果要使用任何第三方的服务就不能够在本地网络中进行测试运行，因为本地chain中没有该第三方服务将自己的合约部署到该chain上
        //所以这里可以使用ChainLink在sepolia网络中部署的Aggregator合约的Address
        dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306); //sepolia

        //设置owner的设置
        //将部署合约的人作为owner
        owner = msg.sender;
        deploymentTimestamp = block.timestamp;
        lockTime = _lockTime;
    }

    function fund() external payable { 
        //每次众筹投资的金额必须大小MINIMUM_VALUE
        require(convertEthToUsd(msg.value)>=MINIMUM_VALUE, "Send more ETH, The minimum ETH value is one"); //revert
        //必须在锁定期内才可以众筹投资
        require(block.timestamp < deploymentTimestamp + lockTime, "Window is closed");
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

    // 生厂商获取合约中的金额
    function getFund() external WindowClosed onlyOwner{
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
        require(result, "Transfer is failed");
        getFundSuccess = true;
    }

    //修改owner
    function transferOwnerShip(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    //退款
    function refund() external WindowClosed{
        require(convertEthToUsd(address(this).balance) < TARGET, "Target is reached!");
        require(fundersToAmount[msg.sender] != 0, "There is no fund for you");
        //投资人必须在锁定期后才可以退款
        

        bool result;
        (result, ) = payable(msg.sender).call{value: fundersToAmount[msg.sender]}("");
        require(result, "Transfer is failed");
        fundersToAmount[msg.sender] = 0;
    }

    // 修改mapping中投资人的投资值，amountToUpdate是修改的结果值
    // 只有ERC20的这个外部合约可以修改该mapping中投资人的投资金额
    function setFunderToAmount(address funder, uint256 amountToUpdate) external  {
        require(msg.sender == erc20Addr, "you do not have permission to call this function");
        fundersToAmount[funder] = amountToUpdate;
    }

    //告诉fundme合约，可以修改mapping中投资人金额的外部合约的地址
    function setERC20Addr(address _erc20Addr) public onlyOwner {
        erc20Addr = _erc20Addr;
    }

    //用于判断锁定期必须结束
    modifier WindowClosed() {
        require(block.timestamp >= deploymentTimestamp + lockTime, "Window is not closed");
        _;  //代表应用该修改器的函数中的其他的操作
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "This function can only be call by owner");
        _;
    }
}