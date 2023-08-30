// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";

import { QuestionExchange } from "../QuestionExchange.sol";

import { QuestionExchangeTestHelper } from "./QuestionExchangeTestHelper.t.sol";

contract Expire is Test, QuestionExchangeTestHelper {
    QuestionExchange public questionExchange;

    function setUp() override public {
        QuestionExchangeTestHelper.setUp();
        questionExchange = new QuestionExchange(100);

        vm.warp(42069);
        vm.prank(_askerAddress);
        ERC20(_token1).approve(address(questionExchange), 5000);

        vm.prank(_askerAddress);
        questionExchange.ask(
            _answererAddress, // answererAddress
            _askerAddress, // askerAddress
            'questionUrl', // questionUrl
            _token1, // bidToken
            5000, // bidAmout
            100000 // expiresAt
        );
    }

    function test_NoTokensToRescue() public {
        uint256 _ownerBalanceBefore = ERC20(_token1).balanceOf(questionExchange.owner());
        uint256 _questionExchangeBalanceBefore = ERC20(_token1).balanceOf(address(questionExchange));
        uint256 _lockedAmountBefore = questionExchange.lockedAmounts(_token1);

        vm.prank(_otherAddress);
        questionExchange.rescueTokens(_token1);

        uint256 _ownerBalanceAfter = ERC20(_token1).balanceOf(questionExchange.owner());
        uint256 _questionExchangeBalanceAfter = ERC20(_token1).balanceOf(address(questionExchange));
        uint256 _lockedAmountAfter = questionExchange.lockedAmounts(_token1);

        assertEq(_ownerBalanceAfter, _ownerBalanceBefore);
        assertEq(_questionExchangeBalanceAfter, _questionExchangeBalanceBefore);
        assertEq(_lockedAmountBefore, _lockedAmountAfter);
    }

    function test_SomeTokensToRescue() public {
        uint256 _amountToRescue = 1234;
        vm.prank(_askerAddress);
        ERC20(_token1).transfer(address(questionExchange), _amountToRescue);

        uint256 _ownerBalanceBefore = ERC20(_token1).balanceOf(questionExchange.owner());
        uint256 _questionExchangeBalanceBefore = ERC20(_token1).balanceOf(address(questionExchange));
        uint256 _lockedAmountBefore = questionExchange.lockedAmounts(_token1);

        vm.prank(_otherAddress);
        questionExchange.rescueTokens(_token1);

        uint256 _ownerBalanceAfter = ERC20(_token1).balanceOf(questionExchange.owner());
        uint256 _questionExchangeBalanceAfter = ERC20(_token1).balanceOf(address(questionExchange));
        uint256 _lockedAmountAfter = questionExchange.lockedAmounts(_token1);

        assertEq(_ownerBalanceAfter, _ownerBalanceBefore + _amountToRescue);
        assertEq(_questionExchangeBalanceAfter, _questionExchangeBalanceBefore - _amountToRescue);
        assertEq(_lockedAmountAfter, _lockedAmountBefore);
    }
}
