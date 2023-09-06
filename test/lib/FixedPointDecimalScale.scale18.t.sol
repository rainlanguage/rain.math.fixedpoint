// SPDX-License-Identifier: CAL
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "src/lib/LibWillOverflow.sol";
import "src/lib/LibFixedPointDecimalScale.sol";
import "./LibFixedPointDecimalScaleSlow.sol";

contract FixedPointDecimalScaleTestScale18 is Test {
    function testScale18ReferenceImplementation(uint256 a, uint256 decimals, uint256 flags) public {
        vm.assume(flags <= FLAG_MAX_INT);
        vm.assume(!LibWillOverflow.scale18WillOverflow(a, decimals, flags));

        assertEq(
            LibFixedPointDecimalScaleSlow.scale18Slow(a, decimals, flags),
            LibFixedPointDecimalScale.scale18(a, decimals, flags)
        );
    }

    function testScale1818(uint256 a, uint256 flags) public {
        vm.assume(flags <= FLAG_MAX_INT);
        assertEq(a, LibFixedPointDecimalScale.scale18(a, FIXED_POINT_DECIMALS, flags));
    }

    function testScale18Lt(uint256 a, uint256 decimals, uint256 flags) public {
        // Only keep rounding flags.
        flags = flags & FLAG_ROUND_UP;
        vm.assume(decimals < FIXED_POINT_DECIMALS);

        uint256 scaleUpBy = FIXED_POINT_DECIMALS - decimals;
        vm.assume(!LibWillOverflow.scaleUpWillOverflow(a, scaleUpBy));

        assertEq(
            LibFixedPointDecimalScale.scaleUp(a, scaleUpBy), LibFixedPointDecimalScale.scale18(a, decimals, flags)
        );
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
        LibFixedPointDecimalScale.scale18(a, decimals, flags);
    }

    function testScale18LtSaturate(uint256 a, uint256 decimals, uint256 flags) public {
        // Keep rounding flags.
        flags = FLAG_SATURATE | (flags & FLAG_ROUND_UP);
        vm.assume(decimals < FIXED_POINT_DECIMALS);

        uint256 scaleUpBy = FIXED_POINT_DECIMALS - decimals;

        assertEq(
            LibFixedPointDecimalScale.scaleUpSaturating(a, scaleUpBy),
            LibFixedPointDecimalScale.scale18(a, decimals, flags)
        );
    }

    function testScale18Gt(uint256 a, uint8 decimals, uint256 flags) public {
        // Keep saturate flags.
        flags = flags & FLAG_SATURATE;
        vm.assume(decimals > FIXED_POINT_DECIMALS);

        uint256 scaleDownBy = decimals - FIXED_POINT_DECIMALS;

        assertEq(
            LibFixedPointDecimalScale.scaleDown(a, scaleDownBy),
            LibFixedPointDecimalScale.scale18(a, decimals, flags)
        );
    }

    function testScale18GtRoundUp(uint256 a, uint8 decimals, uint256 flags) public {
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
