// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test, stdError} from "forge-std/Test.sol";
import {LibWillOverflow, FLAG_MAX_INT} from "src/lib/LibWillOverflow.sol";
import {
    LibFixedPointDecimalScale,
    FLAG_SATURATE,
    FIXED_POINT_DECIMALS,
    FLAG_ROUND_UP
} from "src/lib/LibFixedPointDecimalScale.sol";
import {LibFixedPointDecimalScaleSlow} from "test/lib/LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScale18 is Test {
    function scale18External(uint256 a, uint256 decimals, uint256 flags) external pure returns (uint256) {
        return LibFixedPointDecimalScale.scale18(a, decimals, flags);
    }

    function testScale18ReferenceImplementation(uint256 a, uint256 decimals, uint256 flags) public pure {
        vm.assume(flags <= FLAG_MAX_INT);
        vm.assume(!LibWillOverflow.scale18WillOverflow(a, decimals, flags));

        assertEq(
            LibFixedPointDecimalScaleSlow.scale18Slow(a, decimals, flags),
            LibFixedPointDecimalScale.scale18(a, decimals, flags)
        );
    }

    function testScale1818(uint256 a, uint256 flags) public pure {
        vm.assume(flags <= FLAG_MAX_INT);
        assertEq(a, LibFixedPointDecimalScale.scale18(a, FIXED_POINT_DECIMALS, flags));
    }

    function testScale18Lt(uint256 a, uint256 decimals, uint256 flags) public pure {
        // Only keep rounding flags.
        flags = flags & FLAG_ROUND_UP;
        vm.assume(decimals < FIXED_POINT_DECIMALS);

        uint256 scaleUpBy = FIXED_POINT_DECIMALS - decimals;
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a, scaleUpBy));

        assertEq(LibFixedPointDecimalScale.scaleUp(a, scaleUpBy), LibFixedPointDecimalScale.scale18(a, decimals, flags));
        assertEq(
            LibFixedPointDecimalScale.scaleUpSaturating(a, scaleUpBy),
            LibFixedPointDecimalScale.scale18(a, decimals, flags)
        );
    }

    function testScale18LtOverflow(uint256 a, uint8 decimals, uint256 flags) public {
        // Only keep rounding flags.
        flags = flags & FLAG_ROUND_UP;
        vm.assume(decimals < FIXED_POINT_DECIMALS);

        uint256 scaleUpBy = FIXED_POINT_DECIMALS - decimals;
        vm.assume(LibWillOverflow.scaleUpWillOverflow(a, scaleUpBy));

        vm.expectRevert(stdError.arithmeticError);
        this.scale18External(a, decimals, flags);
    }

    function testScale18LtSaturate(uint256 a, uint256 decimals, uint256 flags) public pure {
        // Keep rounding flags.
        flags = FLAG_SATURATE | (flags & FLAG_ROUND_UP);
        vm.assume(decimals < FIXED_POINT_DECIMALS);

        uint256 scaleUpBy = FIXED_POINT_DECIMALS - decimals;

        assertEq(
            LibFixedPointDecimalScale.scaleUpSaturating(a, scaleUpBy),
            LibFixedPointDecimalScale.scale18(a, decimals, flags)
        );
    }

    function testScale18Gt(uint256 a, uint8 decimals, uint256 flags) public pure {
        // Keep saturate flags.
        flags = flags & FLAG_SATURATE;
        vm.assume(decimals > FIXED_POINT_DECIMALS);

        uint256 scaleDownBy = decimals - FIXED_POINT_DECIMALS;

        assertEq(
            LibFixedPointDecimalScale.scaleDown(a, scaleDownBy), LibFixedPointDecimalScale.scale18(a, decimals, flags)
        );
    }

    function testScale18GtRoundUp(uint256 a, uint8 decimals, uint256 flags) public pure {
        // Keep saturate flags.
        flags = FLAG_ROUND_UP | (flags & FLAG_SATURATE);
        vm.assume(decimals > FIXED_POINT_DECIMALS);

        uint256 scaleDownBy = decimals - FIXED_POINT_DECIMALS;

        assertEq(
            LibFixedPointDecimalScale.scaleDownRoundUp(a, scaleDownBy),
            LibFixedPointDecimalScale.scale18(a, decimals, flags)
        );
    }
}
