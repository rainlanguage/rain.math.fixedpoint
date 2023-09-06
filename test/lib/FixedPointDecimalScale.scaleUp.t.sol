// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "src/lib/LibWillOverflow.sol";
import "src/lib/LibFixedPointDecimalScale.sol";
import "./LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleUp is Test {
    // Special case for scale = 0 is that input = output.
    function testScaleUpBy0(uint256 a) public {
        assertEq(a, LibFixedPointDecimalScale.scaleUp(a, 0));
    }

    function testScaleUp0(uint256 scaleUpBy) public {
        // scaling up 0 will never overflow.
        assertEq(0, LibFixedPointDecimalScale.scaleUp(0, scaleUpBy));
    }

    function testScaleUp(uint256 a, uint8 scaleUpBy) public {
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a, scaleUpBy));

        assertEq(
            LibFixedPointDecimalScaleSlow.scaleUpSlow(a, scaleUpBy), LibFixedPointDecimalScale.scaleUp(a, scaleUpBy)
        );
    }

    function testScaleUpOverflow(uint256 a, uint8 scaleUpBy) public {
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a, scaleUpBy));

        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointDecimalScale.scaleUp(a, scaleUpBy);
    }

    function testScaleUpOverflowBoundary(uint256 a) public {
        vm.assume(a > 0);
        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointDecimalScale.scaleUp(a, OVERFLOW_RESCALE_OOMS);
    }

    function testScaleUpSaturatingParity(uint256 a, uint8 scaleUpBy) public {
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a, scaleUpBy));

        assertEq(
            LibFixedPointDecimalScale.scaleUp(a, scaleUpBy), LibFixedPointDecimalScale.scaleUpSaturating(a, scaleUpBy)
        );
    }

    function testScaleUpGas0() public pure {
        LibFixedPointDecimalScale.scaleUp(123, 5);
    }

    function testScaleUpGas1() public pure {
        LibFixedPointDecimalScale.scaleUp(0, 7);
    }

    function testScaleUpSlowGas0() public pure {
        LibFixedPointDecimalScaleSlow.scaleUpSlow(123, 5);
    }

    function testScaleUpSlowGas1() public pure {
        LibFixedPointDecimalScaleSlow.scaleUpSlow(0, 7);
    }
}
