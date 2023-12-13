// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IPRC20S.sol";

/**
 * @dev Implementation of the {IPRC20S} interface.
 */
abstract contract PRC20S is ERC20, IPRC20S {
    using Strings for uint256;

    // The token protocol name.
    string private constant PROTOCOL_NAME = "prc-20";

    // The token amount per `mint` ethscription.
    uint256 private _limitPerMint;

    // The total supply of ethscriptions.
    uint256 private _ethscriptionSupply;

    /**
     * @dev Initializes the contract by setting `name`, `symbol`, `totalSupply` AND `limitPerMint` to the token.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 totalSupply_,
        uint256 limitPerMint_
    ) ERC20(name_, symbol_) {
        _limitPerMint = limitPerMint_;
        _ethscriptionSupply = totalSupply_ / limitPerMint_;
    }

    /**
     * @dev See {IPRC20S-protocol}.
     */
    function protocol() public view virtual returns (string memory) {
        return PROTOCOL_NAME;
    }

    /**
     * @dev See {IPRC20S-ethscriptionSupply}.
     */
    function ethscriptionSupply() public view virtual returns (uint256) {
        return _ethscriptionSupply;
    }

    /**
     * @dev See {IPRC20S-limitPerMint}.
     */
    function limitPerMint() public view virtual returns (uint256) {
        return _limitPerMint;
    }

    /**
     * @dev See {IPRC20S-split}.
     */
    function inscribeTransfer(uint256 amount) public virtual {
        uint256 value = amount / 10 ** decimals();
        if (value == 0) {
            revert ERC20SSplitAmountTooSmall();
        }
        _burn(_msgSender(), value * 10 ** decimals());

        bytes memory uri = abi.encodePacked(
            'data:,{"p":"',
            PROTOCOL_NAME,
            '","op":"transfer","tick":"',
            symbol(),
            '","amt":"',
            value.toString(),
            '"}'
        );
        emit ethscriptions_protocol_CreateEthscription(_msgSender(), string(uri));
    }

    /**
     * @dev Deposits the ethscriptions with `depositTx` to the contract address and
     * mint the `amount` of erc20 tokens to `depositor`.
     *
     * Emits a {ethscriptions_protocol_DepositForEthscriptions} event.
     *
     * NOTE: This function is virtual, Oracle or a trusted signature is required to verify the deposit event.
     */
    function _depositEthscriptions(bytes32 depositTx, address depositor, uint256 amount) internal virtual {
        _mint(depositor, amount);

        emit ethscriptions_protocol_DepositForEthscriptions(depositor, depositTx, amount);
    }

    /**
     * @dev Deposits the  transferable ethscriptions with `burnTx` to the zero address and
     * mint the `amount` of erc20 tokens to `to`.
     *
     * Emits a {ethscriptions_protocol_DepositForTransferEthscriptions} event.
     *
     * NOTE: This function is virtual, Oracle or a trusted signature is required to verify the deposit event.
     */
    function _burnTransferEthscriptions(bytes32 burnTx, address to, uint256 amount) internal virtual {
        _mint(to, amount);

        emit ethscriptions_protocol_BurnForTransferEthscriptions(to, burnTx, amount);
    }

    /**
     * @dev Withdraw the `ethscriptionIds` ethscriptions stored in the contract and destroy the same amount of erc-20 tokens.
     *
     * Requirements:
     *
     * - `ethscriptionIds` must be owned by the token contract address.
     * - The caller must owned an erc-20 token equal to the value of the ethscriptions token.
     *
     * Emits a {ethscriptions_protocol_TransferEthscriptionForPreviousOwner} event.
     */
    function _withdrawEthscriptions(bytes32[] calldata ethscriptionIds, address to) internal virtual {
        uint256 length = ethscriptionIds.length;
        _burn(to, length * limitPerMint());

        for (uint256 i = 0; i < length; i++) {
            emit ethscriptions_protocol_TransferEthscription(to, ethscriptionIds[i]);
        }
    }
}