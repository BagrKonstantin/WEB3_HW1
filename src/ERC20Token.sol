// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

/// @title ERC20 Token with Transfer Fee and Permit Functionality
/// @notice Implements an ERC20 token that includes a transfer fee mechanism and supports gasless approvals via ERC2612 Permit.
/// @dev The transfer fee is collected and sent to the contract owner.
contract ERC20Token is ERC20, ERC20Permit
{
    address public owner;
    uint256 public constant feePercent = 5;

    /// @notice Constructor that mints the initial supply
    constructor()
    ERC20("MyToken", "MTKN")
    ERC20Permit("MyToken")
    {
        _mint(msg.sender, 1000 * 10 ** 18);
        owner = msg.sender;
    }

    function calcFeeAndSend(address sender, address recipient, uint256 amount) private
    {
        uint256 fee = (amount * feePercent) / 100;
        uint256 toTransfer = amount - fee;
        _transfer(sender, recipient, toTransfer);
        _transfer(sender, owner, fee);
    }

    /// @notice Transfers tokens while applying a fee.
    /// @dev Overrides the ERC20 `transfer` function to implement a fee deduction mechanism.
    /// @param recipient The address receiving the tokens.
    /// @param amount The total amount of tokens to transfer (before fee deduction).
    /// @return Returns true if the transfer is successful.
    function transfer(address recipient, uint256 amount) public override returns (bool)
    {
        calcFeeAndSend(_msgSender(), recipient, amount);
        return (true);
    }

    /// @notice Transfers tokens on behalf of the sender, applying a fee.
    /// @dev Overrides the ERC20 `transferFrom` function to implement a fee deduction mechanism.
    /// @param sender The address from which the tokens are sent.
    /// @param recipient The address receiving the tokens.
    /// @param amount The total amount of tokens to transfer (before fee deduction).
    /// @return Returns true if the transfer is successful.
    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool)
    {
        calcFeeAndSend(sender, recipient, amount);
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "Allowance exceeded");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return (true);
    }

    /// @notice Enables users to purchase tokens by sending Ether to the contract.
    /// @dev Mints tokens proportional to the amount of Ether sent (`msg.value`).
    function buyToken() external payable
    {
        uint256 tokensToBuy = msg.value;
        _mint(msg.sender, tokensToBuy);
    }

    /// @notice Allows the owner to withdraw all Ether held by the contract.
    /// @dev Restricted to the owner of the contract.
    function withdrawEther() external
    {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(owner).transfer(address(this).balance);
    }
}
