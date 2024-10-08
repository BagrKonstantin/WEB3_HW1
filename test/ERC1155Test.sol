// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ERC1155Token.sol";

contract ERC1155TokenTest is Test
{
    ERC1155Token token;
    uint256 private tokenId = 1;
    address private user1 = address(0x123);

    function setUp() public
    {
        token = new ERC1155Token();
    }

    function testBuyToken() public
    {
        uint256 amount = 10;
        uint256 price = amount * 0.01 ether;

        token.buyToken{value: price}(user1, tokenId, amount);

        assertEq(token.balanceOf(user1, tokenId), amount);
    }

    function testBuyLess() public
    {
        uint256 amount = 10;
        uint256 price = amount * 0.001 ether;

        try token.buyToken{value: price}(user1, tokenId, amount)
        {
            assert(false);
        }
        catch
        {
            assert(true);
        }
    }

    function testBuyMore() public
    {
        uint256 amount = 10;
        uint256 price = amount * 0.1 ether;

        try token.buyToken{value: price}(user1, tokenId, amount)
        {
            assert(false);
        }
        catch
        {
            assert(true);
        }
    }
}
