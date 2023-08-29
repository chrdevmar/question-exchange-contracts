// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";

import { QuestionExchange } from "../QuestionExchange.sol";

import { QuestionExchangeTestHelper } from "./QuestionExchangeTestHelper.t.sol";

contract Setters is Test, QuestionExchangeTestHelper {
    QuestionExchange public questionExchange;

    function setUp() override public {
        QuestionExchangeTestHelper.setUp();
        questionExchange = new QuestionExchange(100);
    }

    function test_SetsFeePercentage() public {
        questionExchange.setFeePercentage(10);
        assertEq(questionExchange.feePercentage(), 10);
    }

    function test_SetsFeeReceiver() public {
        questionExchange.setFeeReceiver(_otherAddress);
        assertEq(questionExchange.feeReceiver(), _otherAddress);
    }

    function test_SetsProfileUrl() public {
        questionExchange = new QuestionExchange(100);
        vm.prank(_answererAddress);
        questionExchange.setProfileUrl('https://ask.limo');
        assertEq(questionExchange.profileUrls(_answererAddress), 'https://ask.limo');
        assertEq(questionExchange.profileUrls(_otherAddress), '');
    }
}
