// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";

import { QuestionExchange } from "../QuestionExchange.sol";

import { QuestionExchangeTestHelper } from "./QuestionExchangeTestHelper.t.sol";

contract Answer is Test, QuestionExchangeTestHelper {
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

    function test_AnswerQuestionWithValue() public {
        uint256 _answererBalanceBefore = ERC20(_token1).balanceOf(_answererAddress);
        uint256 _feeReceiverBalanceBefore = ERC20(_token1).balanceOf(questionExchange.feeReceiver());
        uint256 _questionExchangeBalanceBefore = ERC20(_token1).balanceOf(address(questionExchange));

        vm.warp(42070);
        vm.prank(_answererAddress);
        questionExchange.answer(
            0, // questionId
            'answerUrl' // questionUrl
        );

        uint256 _answererBalanceAfter = ERC20(_token1).balanceOf(_answererAddress);
        uint256 _feeReceiverBalanceAfter = ERC20(_token1).balanceOf(questionExchange.feeReceiver());
        uint256 _questionExchangeBalanceAfter = ERC20(_token1).balanceOf(address(questionExchange));

        (
            ,
            ,
            string memory answerUrl,
            ,
            uint256 bidAmount,
            ,
            ,
            ,
            ,
            uint256 answeredAt,
        ) = questionExchange.questions(_answererAddress, 0);

        uint256 feePercentage = questionExchange.feePercentage();
        uint256 feeAmount = bidAmount * feePercentage / 10000;

        assertEq(answerUrl, 'answerUrl');
        assertEq(answeredAt, 42070);

        assertEq(questionExchange.lockedAmounts(_token1), 0);
        assertEq(_answererBalanceAfter, _answererBalanceBefore + bidAmount - feeAmount);
        assertEq(_feeReceiverBalanceAfter, _feeReceiverBalanceBefore + feeAmount);
        assertEq(_questionExchangeBalanceAfter, _questionExchangeBalanceBefore - bidAmount);
    }

    function test_MustBeAsked() public {
        vm.warp(42070);

        vm.expectRevert(EmptyQuestion.selector);
        vm.prank(_answererAddress);
        questionExchange.answer(
            1, // questionId
            'answerUrl' // questionUrl
        );
    }

    function test_MustNotBeAlreadyAnswered() public {
        vm.warp(42070);
        vm.prank(_answererAddress);
        questionExchange.answer(
            0, // questionId
            'answerUrl1' // questionUrl
        );

        vm.expectRevert(AlreadyAnswered.selector);
        vm.prank(_answererAddress);
        questionExchange.answer(
            0, // questionId
            'answerUrl2' // questionUrl
        );
    }

    function test_MustNotBeExpired() public {
        // expires at 100000
        vm.warp(100001);

        vm.expectRevert(QuestionExpired.selector);
        vm.prank(_answererAddress);
        questionExchange.answer(
            0, // questionId
            'answerUrl' // questionUrl
        );
    }
}
