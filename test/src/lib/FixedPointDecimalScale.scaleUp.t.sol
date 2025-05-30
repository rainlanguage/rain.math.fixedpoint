// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test, stdError} from "forge-std/Test.sol";
import {LibWillOverflow, OVERFLOW_RESCALE_OOMS} from "src/lib/LibWillOverflow.sol";
import {LibFixedPointDecimalScale} from "src/lib/LibFixedPointDecimalScale.sol";
import {LibFixedPointDecimalScaleSlow} from "test/lib/LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleUp is Test {
    function scaleUpExternal(uint256 a, uint256 scaleUpBy) external pure returns (uint256) {
        return LibFixedPointDecimalScale.scaleUp(a, scaleUpBy);
    }

    // Special case for scale = 0 is that input = output.
    function testScaleUpBy0(uint256 a) public pure {
        assertEq(a, LibFixedPointDecimalScale.scaleUp(a, 0));
    }

    function testScaleUp0(uint256 scaleUpBy) public pure {
        // scaling up 0 will never overflow.
        assertEq(0, LibFixedPointDecimalScale.scaleUp(0, scaleUpBy));
    }

    function testScaleUp(uint256 a, uint8 scaleUpBy) public pure {
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a, scaleUpBy));

        assertEq(
            LibFixedPointDecimalScaleSlow.scaleUpSlow(a, scaleUpBy), LibFixedPointDecimalScale.scaleUp(a, scaleUpBy)
        );
    }

    function testScaleUpOverflow(uint256 a, uint8 scaleUpBy) public {
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a, scaleUpBy));

        vm.expectRevert(stdError.arithmeticError);
        this.scaleUpExternal(a, scaleUpBy);
    }

    function testScaleUpOverflowBoundary(uint256 a) public {
        vm.assume(a > 0);
        vm.expectRevert(stdError.arithmeticError);
        this.scaleUpExternal(a, OVERFLOW_RESCALE_OOMS);
    }

    function testScaleUpSaturatingParity(uint256 a, uint8 scaleUpBy) public pure {
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
