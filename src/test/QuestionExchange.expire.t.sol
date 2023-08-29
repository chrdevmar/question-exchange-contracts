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
            'questionUrl', // questionUrl
            _token1, // bidToken
            5000, // bidAmout
            0, // replyTo
            100000, // expiresAt
            false // isPrivate
        );
    }

    function test_ExpireQuestionWithValue() public {
        uint256 _askerBalanceBefore = ERC20(_token1).balanceOf(_askerAddress);
        uint256 _feeReceiverBalanceBefore = ERC20(_token1).balanceOf(questionExchange.feeReceiver());
        uint256 _questionExchangeBalanceBefore = ERC20(_token1).balanceOf(address(questionExchange));

        // expires at 100000
        vm.warp(100001);
        vm.prank(_askerAddress);
        questionExchange.expire(
            _answererAddress,
            0 // questionId
        );

        uint256 _askerBalanceAfter = ERC20(_token1).balanceOf(_askerAddress);
        uint256 _feeReceiverBalanceAfter = ERC20(_token1).balanceOf(questionExchange.feeReceiver());
        uint256 _questionExchangeBalanceAfter = ERC20(_token1).balanceOf(address(questionExchange));

        (
            ,
            ,
            ,
            ,
            uint256 bidAmount,
            ,
            ,
            ,
            uint256 expiryClaimedAt,
            ,
        ) = questionExchange.questions(_answererAddress, 0);

        uint256 feePercentage = questionExchange.feePercentage();
        uint256 feeAmount = bidAmount * feePercentage / 10000;

        assertEq(questionExchange.lockedAmounts(_token1), 0);
        assertEq(expiryClaimedAt, 100001);

        assertEq(_askerBalanceAfter, _askerBalanceBefore + bidAmount - feeAmount);
        assertEq(_feeReceiverBalanceAfter, _feeReceiverBalanceBefore + feeAmount);
        assertEq(_questionExchangeBalanceAfter, _questionExchangeBalanceBefore - bidAmount);
    }

    function test_MustBeAsked() public {
        // expires at 100000
        vm.warp(100001);

        vm.expectRevert(EmptyQuestion.selector);
        vm.prank(_askerAddress);
        questionExchange.expire(_answererAddress, 1);
    }

    function test_MustNotBeAlreadyAnswered() public {
        vm.warp(42070);
        vm.prank(_answererAddress);
        questionExchange.answer(0, 'answerUrl');

        // expires at 100000
        vm.warp(100001);
        vm.expectRevert(AlreadyAnswered.selector);
        vm.prank(_askerAddress);
        questionExchange.expire(_answererAddress, 0);
    }

    function test_MustBePastExpiryDate() public {
        // expires at 100000
        vm.warp(99999);
        vm.expectRevert(NotExpired.selector);
        vm.prank(_askerAddress);
        questionExchange.expire(_answererAddress, 0);
    }

    function test_ExpiryMustNotAlreadyBeClaimed() public {
        // expires at 100000
        vm.warp(100001);
        vm.prank(_askerAddress);
        questionExchange.expire(_answererAddress, 0);

        vm.expectRevert(ExpiryClaimed.selector);
        vm.prank(_askerAddress);
        questionExchange.expire(_answererAddress, 0);
    }

    function test_MustHaveBeenTheAsker() public {
        // expires at 100000
        vm.warp(100001);
        vm.expectRevert(NotAsker.selector);
        vm.prank(_otherAddress);
        questionExchange.expire(_answererAddress, 0);
    }
}
