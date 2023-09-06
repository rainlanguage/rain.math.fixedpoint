// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "src/lib/LibWillOverflow.sol";
import "src/lib/LibFixedPointDecimalScale.sol";
import "./LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleUpSaturating is Test {
    // Special case for scale = 0 is that input = output.
    function testScaleUpSaturatingBy0(uint256 a_) public {
        assertEq(a_, LibFixedPointDecimalScale.scaleUpSaturating(a_, 0));
    }

    function testScaleUpSaturating0(uint256 scaleUpBy_) public {
        assertEq(0, LibFixedPointDecimalScale.scaleUpSaturating(0, scaleUpBy_));
    }

    function testScaleUpSaturatingReferenceImplementation(uint256 a_, uint8 scaleUpBy_) public {
        assertEq(
            LibFixedPointDecimalScaleSlow.scaleUpSaturatingSlow(a_, scaleUpBy_),
            LibFixedPointDecimalScale.scaleUpSaturating(a_, scaleUpBy_)
        );
    }

    function testScaleUpSaturatingParity(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        assertEq(
            LibFixedPointDecimalScale.scaleUp(a_, scaleUpBy_),
            LibFixedPointDecimalScale.scaleUpSaturating(a_, scaleUpBy_)
        );
    }

    function testScaleUpSaturatingSaturates(uint256 a_, uint8 scaleUpBy_) public {
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a_, scaleUpBy_));

        assertEq(type(uint256).max, LibFixedPointDecimalScale.scaleUpSaturating(a_, scaleUpBy_));
    }

    function testScaleUpSaturatingGas0() public pure {
        LibFixedPointDecimalScale.scaleUpSaturating(123, 5);
    }

    function testScaleUpSaturatingGas1() public pure {
        LibFixedPointDecimalScale.scaleUpSaturating(0, 7);
    }

    // This hits saturation
    function testScaleUpSaturatingGas2() public pure {
        LibFixedPointDecimalScale.scaleUpSaturating(
            11579208924889540434846052544353396039762338070540290210999787421892, 11
        );
    }

    function testScaleUpSaturatingSlowGas0() public pure {
        LibFixedPointDecimalScaleSlow.scaleUpSaturatingSlow(123, 5);
    }

    function testScaleUpSaturatingSlowGas1() public pure {
        LibFixedPointDecimalScaleSlow.scaleUpSaturatingSlow(0, 7);
    }

    // This hits saturation
    function testScaleUpSaturatingSlowGas2() public pure {
        LibFixedPointDecimalScaleSlow.scaleUpSaturatingSlow(
            11579208924889540434846052544353396039762338070540290210999787421892, 11
        );
    }
}
