// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "src/lib/LibFixedPointDecimalScale.sol";
import "src/lib/FixedPointDecimalConstants.sol";
import "src/lib/LibWillOverflow.sol";

contract FixedPointDecimalScaleScaleRatioTest is Test {
    function testScaleRatioSame(uint256 ratio_, uint8 decimals_, uint256 flags_) public {
        vm.assume(flags_ <= FLAG_MAX_INT);
        assertEq(ratio_, LibFixedPointDecimalScale.scaleRatio(ratio_, decimals_, decimals_, flags_));
    }

    // Ported from legacy tests.
    function testScaleRatioExamples() public {
        assertEq(LibFixedPointDecimalScale.scaleRatio(1e18, 6, 18, FLAG_SATURATE), 1e30);
        assertEq(LibFixedPointDecimalScale.scaleRatio(1e18, 18, 6, FLAG_SATURATE), 1e6);
        assertEq(
            LibFixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 12, 10, FLAG_SATURATE | FLAG_ROUND_UP),
            1_00000_00000_003676
        );
        assertEq(
            LibFixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 10, 12, FLAG_SATURATE | FLAG_ROUND_UP),
            1_00000_00000_00367589_00
        );
        assertEq(
            LibFixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 12, 12, FLAG_SATURATE | FLAG_ROUND_UP),
            1_00000_00000_00367589
        );
        assertEq(
            LibFixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 12, 10, FLAG_SATURATE), 1_00000_00000_003675
        );
        assertEq(
            LibFixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 10, 12, FLAG_SATURATE),
            1_00000_00000_00367589_00
        );
        assertEq(
            LibFixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 12, 12, FLAG_SATURATE), 1_00000_00000_00367589
        );
        assertEq(LibFixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 18, 0, FLAG_SATURATE), 1);
        assertEq(
            LibFixedPointDecimalScale.scaleRatio(1_00000_00000_00367589, 0, 18, FLAG_SATURATE),
            1_00000_00000_00367589_000000_000000_000000
        );
    }

    function testScaleRatioOverflow(uint256 ratio_, uint8 aDecimals_, uint8 bDecimals_, uint256 flags_) public {
        vm.assume(flags_ <= FLAG_MAX_INT);
        vm.assume(LibWillOverflow.scaleRatioWillOverflow(ratio_, aDecimals_, bDecimals_, flags_));

        vm.expectRevert(stdError.arithmeticError);
        LibFixedPointDecimalScale.scaleRatio(ratio_, aDecimals_, bDecimals_, flags_);
    }

    function testScaleRatioGas0() public pure {
        LibFixedPointDecimalScale.scaleRatio(0, 0, 0, 0);
    }

    function testScaleRatioGas1() public pure {
        LibFixedPointDecimalScale.scaleRatio(1, 0, 0, 0);
    }

    function testScaleRatioGas2() public pure {
        LibFixedPointDecimalScale.scaleRatio(1, 1, 2, 0);
    }

    function testScaleRatioGas3() public pure {
        LibFixedPointDecimalScale.scaleRatio(1, 2, 1, 0);
    }

    // Worst case on scale down is 128 scale by
    function testScaleRatioGas4() public pure {
        LibFixedPointDecimalScale.scaleRatio(1, 128, 0, 0);
    }

    function testScaleRatioGas5() public pure {
        LibFixedPointDecimalScale.scaleRatio(1, 0, 127, FLAG_SATURATE);
    }
}
