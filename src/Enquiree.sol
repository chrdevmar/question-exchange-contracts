// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title Enquiree
/// @notice A social contract allowing users to pay to have questions answered from other users
/// @dev tokens sold via this contract should be considered burnt as they are non recoverable
contract Enquiree {
    struct Enquiry {
        uint256 replyTo;
        bytes32 questionHash;
        bytes32 answerHash;
        address bidToken;
        uint256 bidAmount;
        uint256 expiresAt;
        address asker;
        bool isPrivate;
    }

    mapping(address => mapping(uint256 => Enquiry)) enquiries;
    mapping(address => uint256) questionCounts;
    mapping(address => uint256) acceptedTokenCounts;
    mapping(address => address) acceptedTokens;
    mapping(address => mapping(address => uint256)) minimumBids;

    mapping(address => mapping(address => uint256)) claimable;

    /// @notice emitted when a question is asked
    event Ask(
        address indexed answerer,
        uint256 indexed questionId
    );

    /// @notice emitted when a question is answered
    event Answer(
        address indexed answerer,
        uint256 indexed questionId
    );

    /// @notice thrown when question bid is less than minimum
    error BelowMinimumBid();

    function ask(
        address answerer, 
        bytes32 questionHash, 
        address bidToken, 
        uint256 bidAmount,
        uint256 replyTo,
        uint256 expiresAt,
        bool isPrivate
    ) public {
        if(bidAmount < minimumBids[answerer][bidToken]) revert BelowMinimumBid();

        uint256 nextQuestionId = questionCounts[answerer];
        questionCounts[answerer] = nextQuestionId;

        enquiries[answerer][nextQuestionId] = Enquiry({
            replyTo: replyTo,
            questionHash: questionHash,
            bidToken: bidToken,
            bidAmount: bidAmount,
            expiresAt: expiresAt,
            asker: msg.sender,
            isPrivate: isPrivate,
            answerHash: 0
        });
    }
}
