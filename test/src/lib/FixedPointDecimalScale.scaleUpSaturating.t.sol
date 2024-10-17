// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibWillOverflow} from "src/lib/LibWillOverflow.sol";
import {LibFixedPointDecimalScale} from "src/lib/LibFixedPointDecimalScale.sol";
import {LibFixedPointDecimalScaleSlow} from "test/lib/LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleUpSaturating is Test {
    // Special case for scale = 0 is that input = output.
    function testScaleUpSaturatingBy0(uint256 a) public pure {
        assertEq(a, LibFixedPointDecimalScale.scaleUpSaturating(a, 0));
    }

    function testScaleUpSaturating0(uint256 scaleUpBy) public pure {
        assertEq(0, LibFixedPointDecimalScale.scaleUpSaturating(0, scaleUpBy));
    }

    function testScaleUpSaturatingReferenceImplementation(uint256 a, uint8 scaleUpBy) public pure {
        assertEq(
            LibFixedPointDecimalScaleSlow.scaleUpSaturatingSlow(a, scaleUpBy),
            LibFixedPointDecimalScale.scaleUpSaturating(a, scaleUpBy)
        );
    }

    function testScaleUpSaturatingParity(uint256 a, uint8 scaleUpBy) public pure {
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a, scaleUpBy));

        assertEq(
            LibFixedPointDecimalScale.scaleUp(a, scaleUpBy), LibFixedPointDecimalScale.scaleUpSaturating(a, scaleUpBy)
        );
    }

    function testScaleUpSaturatingSaturates(uint256 a, uint8 scaleUpBy) public pure {
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a, scaleUpBy));

        assertEq(type(uint256).max, LibFixedPointDecimalScale.scaleUpSaturating(a, scaleUpBy));
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
