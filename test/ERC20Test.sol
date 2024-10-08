// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ERC20Token.sol";

contract ERC20TokenTest is Test
{
    ERC20Token private token;
    address private user1 = address(vm.addr(1));
    address private user2 = address(0x456);
    uint256 public constant feePercent = 5;

    function setUp() public
    {
        token = new ERC20Token();
    }

    function countFee(uint256 amount) private returns (uint256)
    {
        return (amount * feePercent / 100);
    }

    function testDeployment() public {
        assertEq(token.name(), "MyToken");
        assertEq(token.symbol(), "MTKN");
        assertEq(token.totalSupply(), 1000 ether);
        assertEq(token.balanceOf(address(this)), 1000 ether);
    }

    function testTransfer() public
    {
        uint256 amount = 100 ether;
        uint was = token.balanceOf(address(this));
        token.transfer(user1, amount);

        uint256 fee = countFee(amount);

        assertEq(token.balanceOf(user1), amount - fee);
        assertEq(token.balanceOf(address(this)), was - amount + fee);

        assertEq(token.balanceOf(token.owner()), was - amount + fee);
    }


    function testTransferFromWithFee() public
    {
        uint256 toSecondUser = 1000 ether;
        uint256 toFirstUser = 100 ether;
        token.transfer(user2, toSecondUser);

        vm.prank(user2);
        token.approve(address(this), toFirstUser);

        token.transferFrom(user2, user1, toFirstUser);

        assertEq(token.balanceOf(user1), toFirstUser - countFee(toFirstUser));
        assertEq(token.balanceOf(user2), toSecondUser - toFirstUser - countFee(toSecondUser));

        assertEq(token.balanceOf(token.owner()), countFee(toFirstUser) + countFee(toSecondUser));
    }


    function testBuyToken() public
    {
        uint was = token.balanceOf(address(this));
        token.buyToken{value: 1 ether}();
        assertEq(token.balanceOf(address(this)), was + 1 ether);
    }

    function testPermit() public
    {
        uint256 nonce = token.nonces(user1);
        uint256 deadline = block.timestamp + 1 hours;
        uint256 allowance = 100 ether;

        // EIP712
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                user1,
                user2,
                allowance,
                nonce,
                deadline
            )
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                token.DOMAIN_SEPARATOR(),
                structHash
            )
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, hash);

        token.permit(user1, user2, allowance, deadline, v, r, s);

        assertEq(token.allowance(user1, user2), allowance);

        token.transfer(user1, 500 ether);

        uint256 was = token.balanceOf(user1);
        address recipient = vm.addr(3);

        vm.prank(user2);
        token.transferFrom(user1, recipient, allowance);

        assertEq(token.balanceOf(user1), was - allowance);
        assertEq(token.balanceOf(recipient), allowance - countFee(allowance));
    }
}
