// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Solidity only works with whole numbers

library PriceConverter{

    function getPrice() internal view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 price,,,) = priceFeed.latestRoundData();

        // this price will return a number with 8 decimal places.
        // msg.value will be 18 decimal places, because of wei
        // we have to convert this price to wei.
        // we have to add 10 deciamls
        // if we do price * 1e10 it will get matched
        // we are converting price into a 18 deciaml number
        // since price is int256 and msg.value is uint256
        // we have to convert price to uint256

        return uint256(price * 1e10);
    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        // 1 ETH ?
        // To get the price of 1 ETH in USD, we are calling the getPrice()
        
        uint256 ethPrice = getPrice();
        // It will return something like
        // 2000_000000000000000000 // 2000*1e18

        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        // user will send some amount to the contract and it will be in wei
        // now we have to convert that value to USD
        // we already know the price of 1ETH in USD
        // if the user sent 1ETH it will be 1e18
        // now to get the value of 1ETH in USD we have to multiple.
        // since both the units will contain 18 decimals by multiplying we will get total of 36 decimals
        // so we are diving by 1e18 to negate 18 decimals.

        return ethAmountInUsd;
    }
}
