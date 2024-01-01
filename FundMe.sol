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

// cutom errors
error FundMe__NOT_OWNER();
error FundMe__WITHDRAW_FAILED();
error FundMe__NOT_ENOUGH_ETH();

contract FundMe {

    address internal immutable  i_owner;

    using PriceConverter for uint256;
    // we are attaching PriceConverter library to all uin256
    // now all uint256 will have access to PriceConverter library

    uint256 public constant MINIMUM_USD = 5 * 1e18;
    // since priceInUsd will have 18 deciamls, we also need minimum usd to have 18 decimals;

    address[] public s_funders;
    mapping(address funder => uint256 amountFunded) public addresToAmountFunded;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable{
        uint256 ethPriceInUsd = (msg.value).getConversionRate();
        // require(ethPriceInUsd >= MINIMUM_USD, "Minimum of 5 USD is required");
        if(ethPriceInUsd < MINIMUM_USD) revert FundMe__NOT_ENOUGH_ETH();
        s_funders.push(msg.sender);
        addresToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for(uint256 funderIndex = 0 ; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            addresToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // we are resetting the array.
        // (0) -> we are asking to start at 0.

        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}("");
        // require(sent, "Withdraw Failed!");
        // this has been modified to below statement for gas optimization
        // see onlyowner fn for more details
        if(!sent) revert FundMe__WITHDRAW_FAILED();
    }

    modifier onlyOwner {
        // require(msg.sender == i_owner, "Only owner can withdraw");
        // we are storing this string as string array in memory
        // For example, a string "Hello" would be stored as an array of bytes [72, 101, 108, 108, 111], 
        // where each byte represents the ASCII value of the corresponding character.

        // By using revert, we can return the error code instead of string
        if(msg.sender != i_owner) revert FundMe__NOT_OWNER();
        _;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
        fund();
    }

    // Fallback function is called when msg.data is not empty
    // when we send some data, it will check whether it matches with any of the functions defined.
    // If none of the function is matched, it will look for the fallback()
    fallback() external payable {
        fund();
    }
}

/*
           send Ether
               |
         msg.data is empty?
              / \
            yes  no
            /     \
receive() exists?  fallback()
         /   \
        yes   no
        /      \
    receive()   fallback()
    */
