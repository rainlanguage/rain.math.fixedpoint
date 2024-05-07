// SPDX-License-Identifier: CAL
pragma solidity =0.8.25;

import "forge-std/Test.sol";
import "src/lib/LibFixedPointDecimalScale.sol";
import "src/lib/LibWillOverflow.sol";
import "./LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleDown is Test {
    function testScaleDownReferenceImplementation(uint256 a, uint8 scaleDownBy) public {
        assertEq(
            LibFixedPointDecimalScaleSlow.scaleDownSlow(a, scaleDownBy),
            LibFixedPointDecimalScale.scaleDown(a, scaleDownBy)
        );
    }

    function testScaleDownNoRound(uint256 a, uint8 scaleDownBy) public {
        vm.assume(!LibWillOverflow.scaleDownWillRound(a, scaleDownBy));

        assertEq(
            LibFixedPointDecimalScale.scaleDown(a, scaleDownBy),
            LibFixedPointDecimalScale.scaleDownRoundUp(a, scaleDownBy)
        );
    }

    function testScaleDownRoundDiff(uint256 a, uint8 scaleDownBy) public {
        vm.assume(LibWillOverflow.scaleDownWillRound(a, scaleDownBy));

        assertEq(
            LibFixedPointDecimalScale.scaleDown(a, scaleDownBy) + 1,
            LibFixedPointDecimalScale.scaleDownRoundUp(a, scaleDownBy)
        );
    }

    function testScaleDownOverflow(uint256 a, uint256 scaleDownBy) public {
        vm.assume(scaleDownBy >= OVERFLOW_RESCALE_OOMS);

        assertEq(0, LibFixedPointDecimalScale.scaleDown(a, scaleDownBy));
    }

    function testScaleDownBy0(uint256 a) public {
        assertEq(a, LibFixedPointDecimalScale.scaleDown(a, 0));
    }

    function testScaleDown0(uint256 scaleDownBy) public {
        assertEq(0, LibFixedPointDecimalScale.scaleDown(0, scaleDownBy));
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
