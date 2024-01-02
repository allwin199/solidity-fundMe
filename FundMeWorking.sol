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

import {PriceConverter} from "./PriceConverter.sol";

contract FundMe {

    address internal immutable i_priceFeedAddress;
    // price feed address for ETH/USD

    constructor() {
        i_priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
    }

    using PriceConverter for uint256;
    // for all uint256 we can use the PriceConverter library

    uint256 public minimumUsd = 5e18;
    // since priceInUsd will have 18 decimals, minimum USD should also have 18 decimals

    address[] public s_funders;
    // whenver someone funds this contract, their address will be stored in this array to keep trace of all the funders
    // using array, we can keep track of all the funders, but we cannot keep track of the amount each funder funded
    // for that we have to use mapping
    // since funders is a storage variable we use s_funders

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

        if(msg.value.getConversionRate(i_priceFeedAddress) < minimumUsd){
            revert("Not Enough ETH");
        }
        // since we are using PriceConverter library
        // uint256 is the first input variable type to getConversionRate()
        // when we are using library, the first input variable is the type we are using with the library
        // msg.value is of type uint256
        // therfore msg.value is passed inside the getConversionRate() as first variable

        s_funders.push(msg.sender);
        // msg.sender will hold the address of the sender

        addressToAmountFunded[msg.sender] += msg.value;
        // If a address is sending funds for the 2nd time
        // this amount should be added with the previous

    }

    // this is not the efficient way to withdraw
    // refer Foundry_FundMe
    function withdraw() public {
        for(uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // resetting all the amounts to 0

        s_funders = new address[](0);
        // since all the amount funded got withdrawn
        // we have to reset the funders[]
        // (0) -> start at 0. 
    }
}
