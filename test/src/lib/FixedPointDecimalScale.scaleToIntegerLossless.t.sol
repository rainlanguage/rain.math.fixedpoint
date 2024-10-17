// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 thedavidmeister
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {LibFixedPointDecimalScale} from "src/lib/LibFixedPointDecimalScale.sol";
import {ErrScaleDownPrecisionLoss} from "src/error/ErrScale.sol";

contract FixedPointDecimalScaleScaleToIntegerLosslessTest is Test {
    function testScaleToIntegerLossless(uint256 a) external pure {
        a = a - (a % 1e18);

        uint256 b = LibFixedPointDecimalScale.scaleToIntegerLossless(a);
        assertEq(a, b * 1e18);
    }

    function testScaleToIntegerLosslessPrecisionLoss(uint256 a) external {
        vm.assume(a % 1e18 != 0);

        vm.expectRevert(abi.encodeWithSelector(ErrScaleDownPrecisionLoss.selector, a));
        uint256 b = LibFixedPointDecimalScale.scaleToIntegerLossless(a);
        (b);
    }
}
