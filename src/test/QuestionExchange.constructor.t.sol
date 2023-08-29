// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";

import { QuestionExchange } from "../QuestionExchange.sol";

import { QuestionExchangeTestHelper } from "./QuestionExchangeTestHelper.t.sol";

contract Constructor is Test, QuestionExchangeTestHelper {
    QuestionExchange public questionExchange;

    function setUp() override public {
        QuestionExchangeTestHelper.setUp();
    }

    function test_SetsFeePercentage() public {
        questionExchange = new QuestionExchange(100);
        assertEq(questionExchange.feePercentage(), 100);
    }

    function test_SetsFeeReceiver() public {
        questionExchange = new QuestionExchange(100);
        assertEq(questionExchange.feeReceiver(), questionExchange.owner());
    }
}
