// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

/**
 * @dev Interface of the PRC20S standard as defined in the EIP.
 */
interface IPRC20S {
    /**
     * @dev Emitted when a `contentURI` ethscription is inscribed to `initialOwner`.
     */
    event ethscriptions_protocol_CreateEthscription(address indexed initialOwner, string contentURI);

    /**
     * @dev Emitted when `id` ethscription is transferred to `recipient`.
     */
    event ethscriptions_protocol_TransferEthscription(address indexed recipient, bytes32 indexed id);

    /**
     * @dev Emitted when `id` ethscription is transferred from `previousOwner` to `recipient`.
     */
    event ethscriptions_protocol_TransferEthscriptionForPreviousOwner(
        address indexed previousOwner,
        address indexed recipient,
        bytes32 indexed id
    );

    /**
     * @dev Emitted when `ids` ethscriptions is transferred from `depositor` to the contract address.
     */
    event ethscriptions_protocol_DepositForEthscriptions(address indexed depositor, bytes32 depositTx, uint256 amount);

    /**
     * @dev Emitted when `ids` transferable ethscriptions is transferred from `depositor` to the zero address.
     */
    event ethscriptions_protocol_BurnForTransferEthscriptions(address indexed from, bytes32 burnTx, uint256 amount);

    /**
     * @dev The amount of ethscriptions splits is at least 1 * 10**decimals.
     */
    error ERC20SSplitAmountTooSmall();

    /**
     * @dev Returns the protocol name of the ethscription token.
     */
    function protocol() external view returns (string memory);

    /**
     * @dev Returns the max supply of ethscriptions that can be inscribed.
     */
    function ethscriptionSupply() external view returns (uint256);

    /**
     * @dev Returns the value of ethscriptions per mint.
     */
    function limitPerMint() external view returns (uint256);

    /**
     * @dev Creates a `amount` amount of transferable ethscription tokens and destroy the `amount` of erc-20 tokens.
     *
     * Emits a {ethscriptions_protocol_CreateEthscription} event.
     */
    function inscribeTransfer(uint256 amount) external;
}