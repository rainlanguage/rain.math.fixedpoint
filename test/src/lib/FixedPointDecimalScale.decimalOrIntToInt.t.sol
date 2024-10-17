// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibFixedPointDecimalScale} from "src/lib/LibFixedPointDecimalScale.sol";
import {DECIMAL_MAX_SAFE_INT, FIXED_POINT_ONE} from "src/lib/FixedPointDecimalConstants.sol";
import {IntegerOverflow, ErrScaleDownPrecisionLoss} from "src/error/ErrScale.sol";

contract FixedPointDecimalScaleDecimalOrIntToIntTest is Test {
    /// Test that decimalOrIntToInt rescales a decimal
    function testDecimalOrIntToIntRescalesDecimal(uint256 a) external pure {
        a = bound(a, 0, DECIMAL_MAX_SAFE_INT);
        a *= FIXED_POINT_ONE;

        assertEq(
            LibFixedPointDecimalScale.decimalOrIntToInt(a, DECIMAL_MAX_SAFE_INT),
            LibFixedPointDecimalScale.scaleToIntegerLossless(a)
        );
    }

    /// Test that decimalOrIntToInt does not rescale an integer
    function testDecimalOrIntToIntNotRescalesInt(uint256 a) external pure {
        a = bound(a, 0, DECIMAL_MAX_SAFE_INT);

        assertEq(LibFixedPointDecimalScale.decimalOrIntToInt(a, DECIMAL_MAX_SAFE_INT), a);
    }

    /// Test that integers above max error.
    function testDecimalOrIntToIntAboveMaxError(uint256 a, uint256 max) external {
        a = bound(a, 1, DECIMAL_MAX_SAFE_INT);
        max = bound(max, 0, a - 1);

        vm.expectRevert(abi.encodeWithSelector(IntegerOverflow.selector, a, max));
        LibFixedPointDecimalScale.decimalOrIntToInt(a, max);
    }

    /// Test that decimals above max error.
    function testDecimalOrIntToIntAboveMaxErrorDecimal(uint256 a, uint256 max) external {
        a = bound(a, 1, DECIMAL_MAX_SAFE_INT);
        max = bound(max, 0, a - 1);
        a *= FIXED_POINT_ONE;

        vm.expectRevert(abi.encodeWithSelector(IntegerOverflow.selector, a / FIXED_POINT_ONE, max));
        LibFixedPointDecimalScale.decimalOrIntToInt(a, max);
    }

    /// Test that decimals that incur precision loss error.
    function testDecimalOrIntToIntPrecisionLoss(uint256 a) external {
        a = bound(a, 1e18, DECIMAL_MAX_SAFE_INT * FIXED_POINT_ONE);
        vm.assume(a % FIXED_POINT_ONE != 0);

        vm.expectRevert(abi.encodeWithSelector(ErrScaleDownPrecisionLoss.selector, a));
        LibFixedPointDecimalScale.decimalOrIntToInt(a, DECIMAL_MAX_SAFE_INT);
    }
}
