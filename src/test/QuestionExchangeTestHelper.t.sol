// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { QuestionExchange } from "../QuestionExchange.sol";

import {ERC20} from "solmate/tokens/ERC20.sol";

contract ConcreteERC20 is ERC20 {
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(_name, _symbol, _decimals) {}

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}

contract QuestionExchangeTestHelper is Test {

    address _askerAddress = vm.addr(0x01);
    address _answererAddress = vm.addr(0x02);
    address _otherAddress = vm.addr(0x03);

    address _token1;
    address _token2;

    // enum QuestionStatus{ NONE, ASKED, ANSWERED }

    error EmptyQuestion();
    error InvalidStatus();
    error AlreadyAnswered();
    error NotExpired();
    error ExpiryClaimed();
    error QuestionExpired();
    error EmptyAnswer();
    error NotAsker();
    error FallbackNotPayable();
    error ReceiveNotPayable();

    // struct Question {
    //     QuestionStatus status;
    //     string questionUrl;
    //     string answerUrl;
    //     address bidToken;
    //     uint256 bidAmount;
    //     uint256 expiresAt;
    //     address asker;
    // }

    function setUp() public virtual {
        // warp to a reasonable date to avoid underflows
        // caused by block.timestamp being 0
        vm.warp(1687944748); // Wed Jun 28 2023 09:32:28 GMT+0000

        // deploy dummy erc20 tokens used throughout tests
        _token1 = address(new ConcreteERC20("Token 1", "TOK1", 18));
        _token2 = address(new ConcreteERC20("Token 2", "TOK2", 18));

        // mint some tokens to relevant addresses
        ConcreteERC20(_token1).mint(_askerAddress, 100 * 1e18);
        ConcreteERC20(_token2).mint(_askerAddress, 100 * 1e18);

        ConcreteERC20(_token1).mint(_answererAddress, 100 * 1e18);
        ConcreteERC20(_token2).mint(_answererAddress, 100 * 1e18);

        ConcreteERC20(_token1).mint(_otherAddress, 100 * 1e18);
        ConcreteERC20(_token2).mint(_otherAddress, 100 * 1e18);
    }
}
