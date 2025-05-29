// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test, stdError} from "forge-std/Test.sol";
import {LibWillOverflow, FLAG_MAX_INT, FLAG_SATURATE, FLAG_ROUND_UP} from "src/lib/LibWillOverflow.sol";
import {LibFixedPointDecimalScale, FIXED_POINT_DECIMALS} from "src/lib/LibFixedPointDecimalScale.sol";
import {LibFixedPointDecimalScaleSlow} from "test/lib/LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScaleN is Test {
    function scaleNExternal(uint256 a, uint256 decimals, uint256 flags) external pure returns (uint256) {
        return LibFixedPointDecimalScale.scaleN(a, decimals, flags);
    }

    function testScaleNReferenceImplementation(uint256 a, uint256 decimals, uint256 flags) public pure {
        vm.assume(flags <= FLAG_MAX_INT);
        vm.assume(!LibWillOverflow.scaleNWillOverflow(a, decimals, flags));

        assertEq(
            LibFixedPointDecimalScaleSlow.scaleNSlow(a, decimals, flags),
            LibFixedPointDecimalScale.scaleN(a, decimals, flags)
        );
    }

    function testScaleN18(uint256 a, uint256 flags) public pure {
        vm.assume(flags <= FLAG_MAX_INT);
        assertEq(a, LibFixedPointDecimalScale.scale18(a, FIXED_POINT_DECIMALS, flags));
    }

    function testScaleNLt18(uint256 a, uint8 targetDecimals, uint256 flags) public pure {
        // Only keep saturating flags.
        flags = flags & FLAG_SATURATE;
        vm.assume(targetDecimals < FIXED_POINT_DECIMALS);

        uint256 scaleDownBy = FIXED_POINT_DECIMALS - targetDecimals;

        assertEq(
            LibFixedPointDecimalScale.scaleN(a, targetDecimals, flags),
            LibFixedPointDecimalScale.scaleDown(a, scaleDownBy)
        );
    }

    function testScaleNLt18RoundUp(uint256 a, uint8 targetDecimals, uint256 flags) public pure {
        // Keep saturating flags.
        flags = FLAG_ROUND_UP | flags & FLAG_SATURATE;
        vm.assume(targetDecimals < FIXED_POINT_DECIMALS);

        uint256 scaleDownBy = FIXED_POINT_DECIMALS - targetDecimals;

        assertEq(
            LibFixedPointDecimalScale.scaleN(a, targetDecimals, flags),
            LibFixedPointDecimalScale.scaleDownRoundUp(a, scaleDownBy)
        );
    }

    function testScaleNGt18(uint256 a, uint8 targetDecimals, uint256 flags) public pure {
        // Keep rounding flag
        flags = flags & FLAG_ROUND_UP;
        vm.assume(targetDecimals > FIXED_POINT_DECIMALS);

        uint256 scaleUpBy = targetDecimals - FIXED_POINT_DECIMALS;
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a, scaleUpBy));

        assertEq(
            LibFixedPointDecimalScale.scaleN(a, targetDecimals, flags), LibFixedPointDecimalScale.scaleUp(a, scaleUpBy)
        );
    }

    function testScaleNGt18Overflow(uint256 a, uint8 targetDecimals, uint256 flags) public {
        // Keep rounding flag
        flags = flags & FLAG_ROUND_UP;
        vm.assume(targetDecimals > FIXED_POINT_DECIMALS);

        uint256 scaleUpBy = targetDecimals - FIXED_POINT_DECIMALS;
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a, scaleUpBy));

        vm.expectRevert(stdError.arithmeticError);
        this.scaleNExternal(a, targetDecimals, flags);
    }

    function testScaleNGt18Saturate(uint256 a, uint8 targetDecimals, uint256 flags) public pure {
        // Keep rounding flag
        flags = FLAG_SATURATE | flags & FLAG_ROUND_UP;
        vm.assume(targetDecimals > FIXED_POINT_DECIMALS);

        uint256 scaleUpBy = targetDecimals - FIXED_POINT_DECIMALS;

        assertEq(
            LibFixedPointDecimalScale.scaleUpSaturating(a, scaleUpBy),
            LibFixedPointDecimalScale.scaleN(a, targetDecimals, flags)
        );
    }
}
