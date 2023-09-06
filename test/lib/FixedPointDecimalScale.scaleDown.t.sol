// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "src/lib/LibFixedPointDecimalScale.sol";
import "src/lib/LibWillOverflow.sol";
import "./LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleDown is Test {
    function testScaleDownReferenceImplementation(uint256 a_, uint8 scaleDownBy_) public {
        assertEq(
            LibFixedPointDecimalScaleSlow.scaleDownSlow(a_, scaleDownBy_),
            LibFixedPointDecimalScale.scaleDown(a_, scaleDownBy_)
        );
    }

    function testScaleDownNoRound(uint256 a_, uint8 scaleDownBy_) public {
        vm.assume(!LibWillOverflow.scaleDownWillRound(a_, scaleDownBy_));

        assertEq(
            LibFixedPointDecimalScale.scaleDown(a_, scaleDownBy_),
            LibFixedPointDecimalScale.scaleDownRoundUp(a_, scaleDownBy_)
        );
    }

    function testScaleDownRoundDiff(uint256 a_, uint8 scaleDownBy_) public {
        vm.assume(LibWillOverflow.scaleDownWillRound(a_, scaleDownBy_));

        assertEq(
            LibFixedPointDecimalScale.scaleDown(a_, scaleDownBy_) + 1,
            LibFixedPointDecimalScale.scaleDownRoundUp(a_, scaleDownBy_)
        );
    }

    function testScaleDownOverflow(uint256 a_, uint256 scaleDownBy_) public {
        vm.assume(scaleDownBy_ >= OVERFLOW_RESCALE_OOMS);

        assertEq(0, LibFixedPointDecimalScale.scaleDown(a_, scaleDownBy_));
    }

    function testScaleDownBy0(uint256 a_) public {
        assertEq(a_, LibFixedPointDecimalScale.scaleDown(a_, 0));
    }

    function testScaleDown0(uint256 scaleDownBy_) public {
        assertEq(0, LibFixedPointDecimalScale.scaleDown(0, scaleDownBy_));
    }

    function testScaleDownGas0() public pure {
        LibFixedPointDecimalScale.scaleDown(0, 13);
    }

    function testScaleDownGas2() public pure {
        LibFixedPointDecimalScale.scaleDown(0x58f0427d0ba9a1b642ae793e3fdcece4dcd5fb0ffa7b6c746afb350c4c1d2709, 13);
    }

    function testScaleDownGasSlow0() public pure {
        LibFixedPointDecimalScaleSlow.scaleDownSlow(0, 13);
    }

    function testScaleDownGasSlow2() public pure {
        LibFixedPointDecimalScaleSlow.scaleDownSlow(
            0x58f0427d0ba9a1b642ae793e3fdcece4dcd5fb0ffa7b6c746afb350c4c1d2709, 13
        );
    }
}
