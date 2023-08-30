// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { ERC20 } from "solmate/tokens/ERC20.sol";

import { QuestionExchange } from "../QuestionExchange.sol";

import { QuestionExchangeTestHelper } from "./QuestionExchangeTestHelper.t.sol";

contract Ask is Test, QuestionExchangeTestHelper {
    QuestionExchange public questionExchange;

    function setUp() override public {
        QuestionExchangeTestHelper.setUp();
        questionExchange = new QuestionExchange(100);
    }

    function test_AskQuestionNoValue() public {

        vm.warp(42069);
        vm.prank(_askerAddress);
        questionExchange.ask(
            _answererAddress, // answererAddress
            _askerAddress, // askerAddress
            'questionUrl', // questionUrl
            _token1, // bidToken
            0, // bidAmout
            1234 // expiresAt
        );

        (
            QuestionExchange.QuestionStatus status,
            string memory questionUrl,
            string memory answerUrl,
            address bidToken,
            uint256 bidAmount,
            uint256 expiresAt,
            address asker
        ) = questionExchange.questions(_answererAddress, 0);

        assertEq(uint(status), uint(QuestionExchange.QuestionStatus.ASKED));
        assertEq(questionUrl, 'questionUrl');
        assertEq(answerUrl, '');
        assertEq(bidToken, _token1);
        assertEq(bidAmount, 0);
        assertEq(expiresAt, 1234);
        assertEq(asker, _askerAddress);

        assertEq(questionExchange.lockedAmounts(_token1), 0);
    }

    function test_AskQuestionWithValue() public {

        vm.warp(123123123);

        vm.prank(_askerAddress);
        ERC20(_token2).approve(address(questionExchange), 100 * 1e18);
        uint256 _askerBalanceBefore = ERC20(_token2).balanceOf(_askerAddress);
        uint256 _questionExchangeBalanceBefore = ERC20(_token2).balanceOf(address(questionExchange));

        vm.prank(_askerAddress);
        questionExchange.ask(
            _answererAddress, // answererAddress
            _askerAddress, // askerAddress
            'questionUrl', // questionUrl
            _token2, // bidToken
            420, // bidAmout
            1234 // expiresAt
        );

        uint256 _askerBalanceAfter = ERC20(_token2).balanceOf(_askerAddress);
        uint256 _questionExchangeBalanceAfter = ERC20(_token2).balanceOf(address(questionExchange));

        (
            QuestionExchange.QuestionStatus status,
            string memory questionUrl,
            string memory answerUrl,
            address bidToken,
            uint256 bidAmount,
            uint256 expiresAt,
            address asker
        ) = questionExchange.questions(_answererAddress, 0);

        assertEq(uint(status), uint(QuestionExchange.QuestionStatus.ASKED));
        assertEq(questionUrl, 'questionUrl');
        assertEq(answerUrl, '');
        assertEq(bidToken, _token2);
        assertEq(bidAmount, 420);
        assertEq(expiresAt, 1234);
        assertEq(asker, _askerAddress);

        assertEq(questionExchange.lockedAmounts(_token2), bidAmount);
        assertEq(_askerBalanceAfter, _askerBalanceBefore - bidAmount);
        assertEq(_questionExchangeBalanceAfter, _questionExchangeBalanceBefore + bidAmount);
    }
}
