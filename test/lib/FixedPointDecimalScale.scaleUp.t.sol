// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "src/lib/LibWillOverflow.sol";
import "src/lib/LibFixedPointDecimalScale.sol";
import "./LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleUp is Test {
    // Special case for scale = 0 is that input = output.
    function testScaleUpBy0(uint256 a_) public {
        assertEq(a_, LibFixedPointDecimalScale.scaleUp(a_, 0));
    }

    function testScaleUp0(uint256 scaleUpBy_) public {
        // scaling up 0 will never overflow.
        assertEq(0, LibFixedPointDecimalScale.scaleUp(0, scaleUpBy_));
    }

    function testScaleUp(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        assertEq(
            LibFixedPointDecimalScaleSlow.scaleUpSlow(a_, scaleUpBy_), LibFixedPointDecimalScale.scaleUp(a_, scaleUpBy_)
        );
    }

    function testScaleUpOverflow(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointDecimalScale.scaleUp(a_, scaleUpBy_);
    }

    function testScaleUpOverflowBoundary(uint256 a_) public {
        vm.assume(a_ > 0);
        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointDecimalScale.scaleUp(a_, OVERFLOW_RESCALE_OOMS);
    }

    function testScaleUpSaturatingParity(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        assertEq(
            LibFixedPointDecimalScale.scaleUp(a_, scaleUpBy_),
            LibFixedPointDecimalScale.scaleUpSaturating(a_, scaleUpBy_)
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
