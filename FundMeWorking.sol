// Todo
// Get funds from users
// Allow owner to withdraw funds
// Set a minimum funding value in USD

// Note
// similar to wallets, Smart Contracts can hold funds as well
// To receive funds, we have to make the function payable

// 1 ETH = 1e18 = 1000000000000000000 WEI = 1 * 10 ** 18 


// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    uint256 public minimumUsd = 5e18;
    // since priceInUsd will have 18 decimals, minimum USD should also have 18 decimals

    address[] public funders;
    // whenver someone funds this contract, their address will be stored in this array to keep trace of all the funders
    // using array, we can keep track of all the funders, but we cannot keep track of the amount each funder funded
    // for that we have to use mapping

    mapping (address funder => uint256 amountFunded) public addressToAmountFunded;

    // Anyone can call fund() so we have to make it as public
    // Todo
    // Allow users to send money
    // Set a minimum amount of $5

    // 1. How do we send ETH to this contract?
    // Whenever we send a transaction on the blockchain there is a "VALUE" field populated
    // most of the time it is sent with 0 WEI if no ether is sent

    // To make a function receive ether we have to make the function "PAYABLE"
    // To access the funds sent to the contract we can use "msg.value"

    // Revert -> undo any actions that have been done, and send the remaining gas back
    // If a tx reverts in the middle of a process, any changes done to the blockchain will be reverted 
    // However let's say user sent 2100 gas to make a tx and before reverting 1000 gas has been used
    // Remaining 1100 gas will be reverted to the user.

    function fund() public payable {
        if(getConversionRate(msg.value) < minimumUsd){
            revert("Not Enough ETH");
        }

        funders.push(msg.sender);
        // msg.sender will hold the address of the sender

        addressToAmountFunded[msg.sender] += msg.value;
        // If a address is sending funds for the 2nd time
        // this amount should be added with the previous

    }

    // get the price for ETH/USD
    function getPrice() public view returns(uint256) {
        // To find the price of ETH/USD
        // we need that contact address and
        // ABI -> ABI exposes all the functions available in that contract
        // using this ABI, external contracts can interact with that contract

        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int price,,,) = priceFeed.latestRoundData();

        // Note
        // this price will give the Price of ETH in terms of USD
        // price will have 8 deciaml places
        // msg.value will be in terms of WEI which means 18 decimal places
        // to matchup price and msg.value we have to convert price to 18 deciamls
        // price has already 8 decimal places we have to add another 10 decimals
        // price * 1e10 will convert price into 18 decimals
        // price is int and msg.value is uint
        // let's convert everything into uint256

        return uint256(price*1e10);

        // Now this getPrice() will return price of 1 ETH in terms of USD
        
    }

    // get the conversion rate
    // If msg.value = 0.1 ETH then what is the value in USD?

    function getConversionRate(uint256 ethAmount) public view returns(uint256) {

        // this getConversionRate will get msg.value and ethPrice can be obtained from getPrice()

        // step1
        // get the price of ETH using getPrice()
        uint256 ethPrice = getPrice();

        
        // if msg.value is 1 ETH then 1e18*return val of getPrice()
        // for eg return value of getPrice() is 2000e18
        // then 1e18 * 2000e18 = 2000e36
        // since we need only 18 decimals we have to divide it by 18
        // 2000e36/1e18 = 2000e18
        // if msg.value is 0.5 ETH
        // then 0.5e18 * 2000e18 = 1000e36
        // 1000e36/1e18 = 1000e18

        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1e18;

        // let's say ethAmount is 0.5e18
        // ethPrice = 2000e18
        // ethAmountInUsd = (0.5e18 * 2000e18)/1e18
        // ethAmountInusd = 1000e18

        return ethAmountInUsd;

    }


    // function withdraw() public {}
}
