// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./PRC20S.sol";

contract PRC20Ethscriptions is PRC20S, Ownable {
    uint16 public taxRate;
    address public taxCollector;
    mapping(address => bool) public whitelist;

    constructor(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint256 limitPerMint
    ) PRC20S(name, symbol, totalSupply, limitPerMint) Ownable() {
        taxRate = 500;
        taxCollector = 0x000000000000000000000000000000000000dEaD;
    }

    fallback() external {}

    receive() external payable {}

    function transfer(address to, uint256 value) public override returns (bool) {
        uint256 tax = 0;
        if (!whitelist[_msgSender()]) {
            tax = (value * taxRate) / 10000;
            if (tax > 0) {
                super.transfer(taxCollector, tax);
            }
        }
        return super.transfer(to, value - tax);
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        uint256 tax = 0;
        if (!whitelist[from]) {
            tax = (value * taxRate) / 10000;
            if (tax > 0) {
                super.transferFrom(from, taxCollector, tax);
            }
        }
        return super.transferFrom(from, to, value - tax);
    }

    function setTax(uint16 _taxRate, address _taxCollector) public onlyOwner {
        taxRate = _taxRate;
        taxCollector = _taxCollector;
    }

    function setWhitelist(address user, bool isWhite) public onlyOwner {
        whitelist[user] = isWhite;
    }

    function deposit(bytes32 depositTx, address depositor, uint256 amount) public onlyOwner {
        _depositEthscriptions(depositTx, depositor, amount);
    }

    function burn(bytes32 burnTx, address to, uint256 amount) public onlyOwner {
        _burnTransferEthscriptions(burnTx, to, amount);
    }

    function withdraw(bytes32[] calldata ethscriptionIds, address to) public onlyOwner {
        _withdrawEthscriptions(ethscriptionIds, to);
    }
}