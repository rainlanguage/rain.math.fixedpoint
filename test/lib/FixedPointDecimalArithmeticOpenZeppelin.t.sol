// SPDX-License-Identifier: CAL
pragma solidity =0.8.23;

import "forge-std/Test.sol";
import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";

import "src/lib/LibFixedPointDecimalArithmeticOpenZeppelin.sol";
import "src/lib/LibWillOverflow.sol";

contract FixedPointDecimalArithmeticOpenZeppelinTest is Test {
    /// Not much to test because we're just wrapping OZ.
    function testFixedPointMul(uint256 a, uint256 b, uint8 roundingInt) external {
        roundingInt = uint8(bound(roundingInt, 0, 2));
        vm.assume(!LibWillOverflow.mulDivWillOverflow(a, b, 1e18));
        Math.Rounding rounding = Math.Rounding(roundingInt);
        assertEq(
            Math.mulDiv(a, b, 1e18, rounding), LibFixedPointDecimalArithmeticOpenZeppelin.fixedPointMul(a, b, rounding)
        );
    }

    function testFixedPointMulOverflow(uint256 a, uint256 b, uint8 roundingInt) external {
        roundingInt = uint8(bound(roundingInt, 0, 2));
        vm.assume(LibWillOverflow.mulDivWillOverflow(a, b, 1e18));
        Math.Rounding rounding = Math.Rounding(roundingInt);

        vm.expectRevert();
        LibFixedPointDecimalArithmeticOpenZeppelin.fixedPointMul(a, b, rounding);
    }

    /// Not much to test because we're just wrapping OZ.
    function testFixedPointDiv(uint256 a, uint256 b, uint8 roundingInt) external {
        roundingInt = uint8(bound(roundingInt, 0, 2));
        vm.assume(!LibWillOverflow.mulDivWillOverflow(a, 1e18, b));
        Math.Rounding rounding = Math.Rounding(roundingInt);
        assertEq(
            Math.mulDiv(a, 1e18, b, rounding), LibFixedPointDecimalArithmeticOpenZeppelin.fixedPointDiv(a, b, rounding)
        );
    }

    function testFixedPointDivOverflow(uint256 a, uint256 b, uint8 roundingInt) external {
        roundingInt = uint8(bound(roundingInt, 0, 2));
        vm.assume(LibWillOverflow.mulDivWillOverflow(a, 1e18, b));
        Math.Rounding rounding = Math.Rounding(roundingInt);

        vm.expectRevert();
        LibFixedPointDecimalArithmeticOpenZeppelin.fixedPointDiv(a, b, rounding);
    }
}
