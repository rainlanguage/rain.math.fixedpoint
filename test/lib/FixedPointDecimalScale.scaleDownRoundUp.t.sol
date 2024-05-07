// SPDX-License-Identifier: CAL
pragma solidity =0.8.23;

import "forge-std/Test.sol";
import "src/lib/LibFixedPointDecimalScale.sol";
import "src/lib/LibWillOverflow.sol";
import "./LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleDown is Test {
    function testScaleDownReferenceImplementation(uint256 a, uint8 scaleDownBy) public {
        assertEq(
            LibFixedPointDecimalScaleSlow.scaleDownRoundUpSlow(a, scaleDownBy),
            LibFixedPointDecimalScale.scaleDownRoundUp(a, scaleDownBy)
        );
    }

    function testScaleDownRoundUpOverflow(uint256 a, uint256 scaleDownBy) public {
        vm.assume(a > 0);
        vm.assume(scaleDownBy >= OVERFLOW_RESCALE_OOMS);

        assertEq(1, LibFixedPointDecimalScale.scaleDownRoundUp(a, scaleDownBy));
    }

    function testScaleDownRoundUpOverflow0(uint256 scaleDownBy) public {
        vm.assume(scaleDownBy >= OVERFLOW_RESCALE_OOMS);

        assertEq(0, LibFixedPointDecimalScale.scaleDownRoundUp(0, scaleDownBy));
    }

    function testScaleDownBy0(uint256 a) public {
        assertEq(a, LibFixedPointDecimalScale.scaleDownRoundUp(a, 0));
    }

    function testScaleDown0(uint256 scaleDownBy) public {
        assertEq(0, LibFixedPointDecimalScale.scaleDownRoundUp(0, scaleDownBy));
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
