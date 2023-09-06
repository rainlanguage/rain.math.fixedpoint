// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "src/lib/LibFixedPointDecimalScale.sol";
import "src/lib/LibWillOverflow.sol";
import "./LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleDown is Test {
    function testScaleDownReferenceImplementation(uint256 a_, uint8 scaleDownBy_) public {
        assertEq(
            LibFixedPointDecimalScaleSlow.scaleDownRoundUpSlow(a_, scaleDownBy_),
            LibFixedPointDecimalScale.scaleDownRoundUp(a_, scaleDownBy_)
        );
    }

    function testScaleDownRoundUpOverflow(uint256 a_, uint256 scaleDownBy_) public {
        vm.assume(a_ > 0);
        vm.assume(scaleDownBy_ >= OVERFLOW_RESCALE_OOMS);

        assertEq(1, LibFixedPointDecimalScale.scaleDownRoundUp(a_, scaleDownBy_));
    }

    function testScaleDownRoundUpOverflow0(uint256 scaleDownBy_) public {
        vm.assume(scaleDownBy_ >= OVERFLOW_RESCALE_OOMS);

        assertEq(0, LibFixedPointDecimalScale.scaleDownRoundUp(0, scaleDownBy_));
    }

    function testScaleDownBy0(uint256 a_) public {
        assertEq(a_, LibFixedPointDecimalScale.scaleDownRoundUp(a_, 0));
    }

    function testScaleDown0(uint256 scaleDownBy_) public {
        assertEq(0, LibFixedPointDecimalScale.scaleDownRoundUp(0, scaleDownBy_));
    }

    function testScaleDownRoundUpGas1() public pure {
        LibFixedPointDecimalScale.scaleDownRoundUp(0, 13);
    }

    function testScaleDownRoundUpGas3() public pure {
        LibFixedPointDecimalScale.scaleDownRoundUp(
            0x58f0427d0ba9a1b642ae793e3fdcece4dcd5fb0ffa7b6c746afb350c4c1d2709, 13
        );
    }

    function testScaleDownRoundUpGasSlow1() public pure {
        LibFixedPointDecimalScaleSlow.scaleDownRoundUpSlow(0, 13);
    }

    function testScaleDownRoundUpGasSlow3() public pure {
        LibFixedPointDecimalScaleSlow.scaleDownRoundUpSlow(
            0x58f0427d0ba9a1b642ae793e3fdcece4dcd5fb0ffa7b6c746afb350c4c1d2709, 13
        );
    }
}
