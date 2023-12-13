// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../libraries/BatchOrder.sol";
import "../libraries/OrderTypes.sol";

interface IPolsMarket {
    error CurrencyInvalid();
    error MsgValueInvalid();
    error NoncesInvalid();
    error RecipientInvalid();
    error OrderExpired();
    error SignerInvalid();
    error SignatureInvalid();
    error TrustedSignatureInvalid();
    error ETHTransferFailed();
    error EmptyOrderCancelList();
    error OrderNonceTooLow();
    error EthscriptionInvalid();
    error ExpiredSignature();
    error InsufficientConfirmations();
    error MerkleProofTooLarge(uint256 length);
    error MerkleProofInvalid();

    event CancelAllOrders(address user, uint256 newMinNonce, uint64 timestamp);
    event CancelMultipleOrders(address user, uint256[] orderNonces, uint64 timestamp);
    event NewTrustedVerifier(address trustedVerifier);
    event EthscriptionOrderExecuted(
        bytes32 indexed orderHash,
        uint256 orderNonce,
        bytes32 ethscriptionId,
        uint256 quantity,
        address seller,
        address buyer,
        address currency,
        uint256 price,
        uint64 endTime
    );
    event EthscriptionWithdrawn(address indexed owner, bytes32 indexed ethscriptionId, uint64 timestamp);
    event ethscriptions_protocol_TransferEthscriptionForPreviousOwner(
        address indexed previousOwner,
        address indexed recipient,
        bytes32 indexed id
    );

    function executeOrderWithMerkle(
        BatchOrder.EthscriptionOrder calldata order,
        BatchOrder.MerkleTree calldata merkleTree,
        address recipient
    ) external payable;

    function cancelAllOrders() external;

    function cancelMultipleMakerOrders(uint256[] calldata orderNonces) external;

    function withdrawEthscription(bytes32 ethscriptionId, uint64 expiration, bytes calldata trustedSign) external;

    function withdrawMultipleEthscriptions(
        bytes32[] calldata ethscriptionIds,
        uint64 expiration,
        bytes calldata trustedSign
    ) external;
}