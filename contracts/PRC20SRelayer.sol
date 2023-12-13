// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {SignatureChecker} from "./libraries/SignatureChecker.sol";

interface IPRC20Ethscriptions {
    function deposit(bytes32 depositTx, address depositor, uint256 amount) external;

    function burn(bytes32 burnTx, address to, uint256 amount) external;

    function withdraw(bytes32[] calldata ethscriptionIds) external;
}

contract PRC20SRelayer is UUPSUpgradeable, OwnableUpgradeable, EIP712Upgradeable {
    event RelayDepositTx(
        address indexed relayer,
        address indexed ethscription,
        bytes32 depositTx,
        address from,
        uint256 amount
    );
    event DepositTxExecuted(address indexed ethscription, bytes32 depositTx, address from, uint256 amount);
    event RelayBurnTx(
        address indexed relayer,
        address indexed ethscription,
        bytes32 burnTx,
        address from,
        uint256 amount
    );
    event BurnTxExecuted(address indexed ethscription, bytes32 burnTx, address from, uint256 amount);

    bytes32 internal constant PRC20S_RELAYER_DEPOSIT_HASH =
        keccak256("Prc20sRelayerDeposit(address ethscription,bytes32 depositTx,address from,uint256 amount)");

    bytes32 internal constant PRC20S_RELAYER_BURN_HASH =
        keccak256("Prc20sRelayerBurn(address ethscription,bytes32 burnTx,address from,uint256 amount)");

    bytes32 internal constant PRC20S_RELAYER_WITHDRAW_HASH =
        keccak256("Prc20sRelayerWithdraw(address ethscription,bytes32[] ethscriptionIds,address recipient");

    mapping(address => bool) public relayers;
    mapping(bytes32 => bool) public executedTxs;
    mapping(bytes32 => address[]) public relayerSigs;
    uint8 public minRelayerSig;

    function initialize() public initializer {
        __EIP712_init("PRC20SRelayer", "1");
        __Ownable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function deposit(
        address ethscription,
        bytes32 depositTx,
        address from,
        uint256 amount,
        bytes calldata sig
    ) external {
        require(!executedTxs[depositTx], "deposit tx executed");

        (bytes32 r, bytes32 s, uint8 v) = SignatureChecker.splitSignature(sig);
        bytes32 digest = keccak256(abi.encode(PRC20S_RELAYER_DEPOSIT_HASH, ethscription, depositTx, from, amount));
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), digest));
        address signer = SignatureChecker.recover(hash, v, r, s);

        require(relayers[signer], "invalid relayer");
        require(!SignatureChecker.checkRelayer(relayerSigs[depositTx], signer), "duplicate relayer signature");

        relayerSigs[depositTx].push(signer);

        emit RelayDepositTx(signer, ethscription, depositTx, from, amount);

        if (relayerSigs[depositTx].length == minRelayerSig) {
            executedTxs[depositTx] = true;
            IPRC20Ethscriptions(ethscription).deposit(depositTx, from, amount);
            emit DepositTxExecuted(ethscription, depositTx, from, amount);
        }
    }

    function burn(address ethscription, bytes32 burnTx, address from, uint256 amount, bytes calldata sig) external {
        require(!executedTxs[burnTx], "burn tx executed");

        (bytes32 r, bytes32 s, uint8 v) = SignatureChecker.splitSignature(sig);
        bytes32 digest = keccak256(abi.encode(PRC20S_RELAYER_BURN_HASH, ethscription, burnTx, from, amount));
        bytes32 hash = keccak256(abi.encodePacked("\x19\x01", _domainSeparatorV4(), digest));
        address signer = SignatureChecker.recover(hash, v, r, s);

        require(relayers[signer], "invalid relayer");
        require(!SignatureChecker.checkRelayer(relayerSigs[burnTx], signer), "duplicate relayer signature");

        relayerSigs[burnTx].push(signer);

        emit RelayBurnTx(signer, ethscription, burnTx, from, amount);

        if (relayerSigs[burnTx].length == minRelayerSig) {
            executedTxs[burnTx] = true;
            IPRC20Ethscriptions(ethscription).burn(burnTx, from, amount);
            emit BurnTxExecuted(ethscription, burnTx, from, amount);
        }
    }

    function updateMinRelayerSig(uint8 min) external onlyOwner {
        minRelayerSig = min;
    }

    function updateRelayer(address relayer, bool valid) external onlyOwner {
        relayers[relayer] = valid;
    }
}